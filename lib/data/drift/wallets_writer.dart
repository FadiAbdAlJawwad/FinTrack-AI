import 'dart:convert';

import 'app_database.dart';
import 'drift_unit_of_work.dart';

class WalletsWriter {
  WalletsWriter(this._db, this._utcNow);

  final AppDatabase _db;
  final DateTime Function() _utcNow;

  Future<void> create(WalletDto wallet) async {
    assertInUnitOfWork();
    await _db.into(_db.wallets).insertOnConflictUpdate(wallet);

    final data = _walletToSetData(wallet);
    final write = {
      'collection': 'wallets',
      'docId': wallet.id,
      'op': 'set',
      'data': data,
    };
    final keys = ['wallets/${wallet.id}'];

    await _db.into(_db.outbox).insert(
      OutboxCompanion.insert(
        writes: jsonEncode([write]),
        keys: jsonEncode(keys),
        createdAt: _utcNow().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> update(String id, WalletDto wallet) async {
    assertInUnitOfWork();
    if (wallet.id != id) {
      throw ArgumentError('wallet.id (${wallet.id}) does not match id ($id)', 'wallet');
    }
    final existing = await (_db.select(_db.wallets)
          ..where((w) => w.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) {
      throw StateError('Wallet not found: $id');
    }

    if (existing.hasTransactions && !wallet.hasTransactions) {
      throw ArgumentError('hasTransactions cannot be changed from true to false');
    }

    final changed = _walletDiff(existing, wallet);
    if (changed.isEmpty) {
      return;
    }

    await _db.into(_db.wallets).insertOnConflictUpdate(wallet);

    final write = {
      'collection': 'wallets',
      'docId': id,
      'op': 'update',
      'data': changed,
    };
    final keys = ['wallets/$id'];

    await _db.into(_db.outbox).insert(
      OutboxCompanion.insert(
        writes: jsonEncode([write]),
        keys: jsonEncode(keys),
        createdAt: _utcNow().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> _walletToSetData(WalletDto w) {
    final map = <String, dynamic>{
      'name': w.name,
      'kind': w.kind,
      'currency': w.currency,
      'openingBalanceMinor': w.openingBalanceMinor,
      'status': w.status,
      'createdOn': w.createdOn.toIso8601String(),
      'hasTransactions': w.hasTransactions,
      'deleted': w.deleted,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }

  Map<String, dynamic> _walletDiff(WalletDto oldW, WalletDto newW) {
    final changed = <String, dynamic>{};
    if (oldW.name != newW.name) changed['name'] = newW.name;
    if (oldW.kind != newW.kind) changed['kind'] = newW.kind;
    if (oldW.currency != newW.currency) changed['currency'] = newW.currency;
    if (oldW.openingBalanceMinor != newW.openingBalanceMinor) {
      changed['openingBalanceMinor'] = newW.openingBalanceMinor;
    }
    if (oldW.status != newW.status) changed['status'] = newW.status;
    if (oldW.createdOn != newW.createdOn) {
      changed['createdOn'] = newW.createdOn.toIso8601String();
    }
    if (oldW.hasTransactions != newW.hasTransactions) {
      changed['hasTransactions'] = newW.hasTransactions;
    }
    if (oldW.deleted != newW.deleted) changed['deleted'] = newW.deleted;
    return changed;
  }
}
