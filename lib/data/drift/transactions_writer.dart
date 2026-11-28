import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'drift_unit_of_work.dart';

class TransactionsWriter {
  TransactionsWriter(this._db, this._utcNow);

  final AppDatabase _db;
  final DateTime Function() _utcNow;

  Future<void> saveTransfer(
    TransactionDto transfer,
    TransactionDto? fee,
  ) async {
    assertInUnitOfWork();

    if (transfer.kind != 'transfer') {
      throw ArgumentError('transfer.kind must be "transfer"');
    }

    if (fee != null) {
      if (fee.kind != 'expense') {
        throw ArgumentError('fee.kind must be "expense"');
      }
      if (fee.transferId != transfer.id) {
        throw ArgumentError('fee.transferId must match transfer.id');
      }
      if (fee.walletId != transfer.fromWalletId) {
        throw ArgumentError('fee.walletId must match transfer.fromWalletId');
      }
      if (fee.categoryId == null) {
        throw ArgumentError('fee.categoryId must not be null');
      }
    }

    final existingTransfer = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(transfer.id))).getSingleOrNull();

    final existingFee =
        await (_db.select(_db.transactions)..where(
              (t) =>
                  t.transferId.equals(transfer.id) &
                  t.id.equals(transfer.id).not(),
            ))
            .getSingleOrNull();

    if (existingFee != null && fee == null) {
      throw UnsupportedError('Fee removal is not supported');
    }

    final writes = <Map<String, dynamic>>[];
    final keySet = <String>{};

    if (existingTransfer == null) {
      await _db.into(_db.transactions).insertOnConflictUpdate(transfer);
      writes.add({
        'collection': 'transactions',
        'docId': transfer.id,
        'op': 'set',
        'data': _transactionToSetData(transfer),
      });
    } else {
      final changed = _transactionDiff(existingTransfer, transfer);
      if (changed.isNotEmpty) {
        await _db.into(_db.transactions).insertOnConflictUpdate(transfer);
        writes.add({
          'collection': 'transactions',
          'docId': transfer.id,
          'op': 'update',
          'data': changed,
        });
      }
    }
    keySet.add('transactions/${transfer.id}');
    if (transfer.fromWalletId != null) {
      keySet.add('wallets/${transfer.fromWalletId}');
    }
    if (transfer.toWalletId != null) {
      keySet.add('wallets/${transfer.toWalletId}');
    }

    if (fee != null) {
      if (existingFee == null) {
        await _db.into(_db.transactions).insertOnConflictUpdate(fee);
        writes.add({
          'collection': 'transactions',
          'docId': fee.id,
          'op': 'set',
          'data': _transactionToSetData(fee),
        });
      } else {
        final changed = _transactionDiff(existingFee, fee);
        if (changed.isNotEmpty) {
          await _db.into(_db.transactions).insertOnConflictUpdate(fee);
          writes.add({
            'collection': 'transactions',
            'docId': fee.id,
            'op': 'update',
            'data': changed,
          });
        }
      }
      keySet.add('transactions/${fee.id}');
      if (fee.walletId != null) {
        keySet.add('wallets/${fee.walletId}');
      }
      if (fee.categoryId != null) {
        keySet.add('categories/${fee.categoryId}');
      }
    }

    if (writes.isNotEmpty) {
      final keysList = keySet.toList()..sort();
      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              writes: jsonEncode(writes),
              keys: jsonEncode(keysList),
              createdAt: _utcNow().millisecondsSinceEpoch,
            ),
          );
    }
  }

  Future<void> deleteTransfer(String transferId) async {
    assertInUnitOfWork();

    final storedTransfer = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(transferId))).getSingleOrNull();

    if (storedTransfer == null || storedTransfer.kind != 'transfer') {
      throw StateError('Transfer not found or not a transfer: $transferId');
    }

    final storedFee =
        await (_db.select(_db.transactions)..where(
              (t) =>
                  t.transferId.equals(transferId) &
                  t.id.equals(transferId).not(),
            ))
            .getSingleOrNull();

    final transferNeedsDelete = !storedTransfer.deleted;
    final feeNeedsDelete = storedFee != null && !storedFee.deleted;

    if (!transferNeedsDelete && !feeNeedsDelete) {
      return;
    }

    final writes = <Map<String, dynamic>>[];
    final keySet = <String>{};

    if (transferNeedsDelete) {
      final updatedTransfer = storedTransfer.copyWith(deleted: true);
      await _db.into(_db.transactions).insertOnConflictUpdate(updatedTransfer);
      writes.add({
        'collection': 'transactions',
        'docId': storedTransfer.id,
        'op': 'update',
        'data': {'deleted': true},
      });
    }
    keySet.add('transactions/${storedTransfer.id}');
    if (storedTransfer.fromWalletId != null) {
      keySet.add('wallets/${storedTransfer.fromWalletId}');
    }
    if (storedTransfer.toWalletId != null) {
      keySet.add('wallets/${storedTransfer.toWalletId}');
    }

    if (storedFee != null) {
      if (feeNeedsDelete) {
        final updatedFee = storedFee.copyWith(deleted: true);
        await _db.into(_db.transactions).insertOnConflictUpdate(updatedFee);
        writes.add({
          'collection': 'transactions',
          'docId': storedFee.id,
          'op': 'update',
          'data': {'deleted': true},
        });
      }
      keySet.add('transactions/${storedFee.id}');
      if (storedFee.walletId != null) {
        keySet.add('wallets/${storedFee.walletId}');
      }
      if (storedFee.categoryId != null) {
        keySet.add('categories/${storedFee.categoryId}');
      }
    }

    if (writes.isNotEmpty) {
      final keysList = keySet.toList()..sort();
      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              writes: jsonEncode(writes),
              keys: jsonEncode(keysList),
              createdAt: _utcNow().millisecondsSinceEpoch,
            ),
          );
    }
  }

  Map<String, dynamic> _transactionToSetData(TransactionDto t) {
    final map = <String, dynamic>{
      'kind': t.kind,
      'date': t.date.toIso8601String(),
      'note': t.note,
      'walletId': t.walletId,
      'categoryId': t.categoryId,
      'amountMinor': t.amountMinor,
      'currency': t.currency,
      'transferId': t.transferId,
      'fromWalletId': t.fromWalletId,
      'toWalletId': t.toWalletId,
      'amountSentMinor': t.amountSentMinor,
      'sentCurrency': t.sentCurrency,
      'amountReceivedMinor': t.amountReceivedMinor,
      'receivedCurrency': t.receivedCurrency,
      'deleted': t.deleted,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }

  Map<String, dynamic> _transactionDiff(
    TransactionDto oldT,
    TransactionDto newT,
  ) {
    final changed = <String, dynamic>{};
    if (oldT.kind != newT.kind) changed['kind'] = newT.kind;
    if (oldT.date != newT.date) changed['date'] = newT.date.toIso8601String();
    if (oldT.note != newT.note) changed['note'] = newT.note;
    if (oldT.walletId != newT.walletId) changed['walletId'] = newT.walletId;
    if (oldT.categoryId != newT.categoryId)
      changed['categoryId'] = newT.categoryId;
    if (oldT.amountMinor != newT.amountMinor)
      changed['amountMinor'] = newT.amountMinor;
    if (oldT.currency != newT.currency) changed['currency'] = newT.currency;
    if (oldT.transferId != newT.transferId)
      changed['transferId'] = newT.transferId;
    if (oldT.fromWalletId != newT.fromWalletId)
      changed['fromWalletId'] = newT.fromWalletId;
    if (oldT.toWalletId != newT.toWalletId)
      changed['toWalletId'] = newT.toWalletId;
    if (oldT.amountSentMinor != newT.amountSentMinor) {
      changed['amountSentMinor'] = newT.amountSentMinor;
    }
    if (oldT.sentCurrency != newT.sentCurrency)
      changed['sentCurrency'] = newT.sentCurrency;
    if (oldT.amountReceivedMinor != newT.amountReceivedMinor) {
      changed['amountReceivedMinor'] = newT.amountReceivedMinor;
    }
    if (oldT.receivedCurrency != newT.receivedCurrency) {
      changed['receivedCurrency'] = newT.receivedCurrency;
    }
    if (oldT.deleted != newT.deleted) changed['deleted'] = newT.deleted;
    return changed;
  }
}
