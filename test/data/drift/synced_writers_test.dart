import 'dart:convert';

import 'package:fin_track_ai/data/drift/app_database.dart';
import 'package:fin_track_ai/data/drift/database_factory.dart';
import 'package:fin_track_ai/data/drift/drift_unit_of_work.dart';
import 'package:fin_track_ai/data/drift/transactions_writer.dart';
import 'package:fin_track_ai/data/drift/wallets_writer.dart';
import 'package:fin_track_ai/domain/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

WalletDto _sampleWallet({
  required String id,
  String name = 'Test Wallet',
  String kind = 'bank',
  String currency = 'USD',
  int openingBalanceMinor = 1000,
  String status = 'active',
  LocalDate? createdOn,
  bool hasTransactions = false,
  bool deleted = false,
}) {
  return WalletDto(
    id: id,
    name: name,
    kind: kind,
    currency: currency,
    openingBalanceMinor: openingBalanceMinor,
    status: status,
    createdOn: createdOn ?? LocalDate(2026, 1, 1),
    hasTransactions: hasTransactions,
    deleted: deleted,
  );
}

TransactionDto _sampleTransfer({
  required String id,
  LocalDate? date,
  String? note,
  String fromWalletId = 'w1',
  String toWalletId = 'w2',
  int amountSentMinor = 1000,
  String sentCurrency = 'USD',
  int amountReceivedMinor = 1000,
  String receivedCurrency = 'USD',
  bool deleted = false,
}) {
  return TransactionDto(
    id: id,
    kind: 'transfer',
    date: date ?? LocalDate(2026, 1, 1),
    note: note,
    fromWalletId: fromWalletId,
    toWalletId: toWalletId,
    amountSentMinor: amountSentMinor,
    sentCurrency: sentCurrency,
    amountReceivedMinor: amountReceivedMinor,
    receivedCurrency: receivedCurrency,
    deleted: deleted,
  );
}

TransactionDto _sampleFee({
  required String id,
  required String transferId,
  LocalDate? date,
  String walletId = 'w1',
  String categoryId = 'cat-fees',
  int amountMinor = 50,
  String currency = 'USD',
  bool deleted = false,
}) {
  return TransactionDto(
    id: id,
    kind: 'expense',
    date: date ?? LocalDate(2026, 1, 1),
    walletId: walletId,
    categoryId: categoryId,
    amountMinor: amountMinor,
    currency: currency,
    transferId: transferId,
    deleted: deleted,
  );
}

bool _isValidJsonValue(dynamic value) {
  if (value == null || value is bool || value is num || value is String) {
    return true;
  }
  if (value is List) {
    return value.every(_isValidJsonValue);
  }
  if (value is Map<String, dynamic>) {
    if (value.containsKey('serverUpdatedAt')) {
      return false;
    }
    return value.values.every(_isValidJsonValue);
  }
  return false;
}

void main() {
  late AppDatabase db;
  late DriftUnitOfWork uow;
  late WalletsWriter walletsWriter;
  late TransactionsWriter transactionsWriter;

  setUp(() {
    db = openInMemory();
    uow = DriftUnitOfWork(db);
    walletsWriter = WalletsWriter(db, DateTime.now);
    transactionsWriter = TransactionsWriter(db, DateTime.now);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'I-08: Transfer + fee -> one outbox row with two writes, or nothing',
    () async {
      final transfer = _sampleTransfer(id: 't1');
      final fee = _sampleFee(id: 'f1', transferId: 't1');

      await uow.run(() => transactionsWriter.saveTransfer(transfer, fee));
      expect(await db.select(db.transactions).get(), hasLength(2));
      final outbox = await db.select(db.outbox).get();
      expect(outbox, hasLength(1));
      final writes = jsonDecode(outbox.single.writes) as List;
      expect(writes, hasLength(2));

      await db
          .into(db.transactions)
          .insert(
            TransactionDto(
              id: 'tx-existing',
              kind: 'expense',
              date: LocalDate(2026, 1, 1),
              transferId: 't2',
              deleted: false,
            ),
          );

      final transfer2 = _sampleTransfer(id: 't2');
      final fee2 = _sampleFee(id: 'f2', transferId: 't2');

      await expectLater(
        () => uow.run(() => transactionsWriter.saveTransfer(transfer2, fee2)),
        throwsA(anything),
      );
      final txs = await db.select(db.transactions).get();
      expect(txs.map((t) => t.id), isNot(contains('t2')));
      expect(await db.select(db.outbox).get(), hasLength(1));
    },
  );

  test('ADR-0010/2: Payload jsonDecode(jsonEncode(x)) == x; no Timestamp, no serverUpdatedAt key', () async {
    final transfer = _sampleTransfer(id: 't1');
    final fee = _sampleFee(id: 'f1', transferId: 't1');

    await uow.run(() => transactionsWriter.saveTransfer(transfer, fee));
    final outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(1));

    final decoded = jsonDecode(outbox.single.writes);
    final reEncodedDecoded = jsonDecode(jsonEncode(decoded));
    expect(reEncodedDecoded, equals(decoded));
    expect(_isValidJsonValue(decoded), isTrue);
    final transferWrite = (decoded as List).firstWhere(
      (w) => w['docId'] == 't1',
    );
    expect(transferWrite['data']['date'], equals('2026-01-01'));
  });

  test('ADR-0010/3: Transfer + fee row: keys = both transaction keys + both wallet keys + category keys', () async {
    final transfer = _sampleTransfer(
      id: 't1',
      fromWalletId: 'w1',
      toWalletId: 'w2',
    );
    final fee = _sampleFee(
      id: 'f1',
      transferId: 't1',
      walletId: 'w1',
      categoryId: 'cat-fees',
    );

    await uow.run(() => transactionsWriter.saveTransfer(transfer, fee));
    final outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(1));

    final keys = (jsonDecode(outbox.single.keys) as List)
        .cast<String>()
        .toSet();
    expect(
      keys,
      equals({
        'transactions/t1',
        'transactions/f1',
        'wallets/w1',
        'wallets/w2',
        'categories/cat-fees',
      }),
    );
  });

  test('ADR-0010/4: create -> set; edit -> update with changed fields only; delete -> update {deleted: true}', () async {
    final w1 = _sampleWallet(id: 'w1', name: 'Original Name');
    await uow.run(() => walletsWriter.create(w1));

    var outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(1));
    var writes = jsonDecode(outbox.last.writes) as List;
    expect(writes[0]['op'], equals('set'));

    final w1Updated = _sampleWallet(id: 'w1', name: 'New Name');
    await uow.run(() => walletsWriter.update('w1', w1Updated));

    outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(2));
    writes = jsonDecode(outbox.last.writes) as List;
    expect(writes[0]['op'], equals('update'));
    final updateData = writes[0]['data'] as Map<String, dynamic>;
    expect(updateData.keys.toSet(), equals({'name'}));

    final transfer = _sampleTransfer(id: 't1');
    final fee = _sampleFee(id: 'f1', transferId: 't1');
    await uow.run(() => transactionsWriter.saveTransfer(transfer, fee));

    await uow.run(() => transactionsWriter.deleteTransfer('t1'));

    outbox = await db.select(db.outbox).get();
    writes = jsonDecode(outbox.last.writes) as List;
    expect(writes, hasLength(2));
    expect(writes[0]['op'], equals('update'));
    expect(
      writes.map((w) => '${w['collection']}/${w['docId']}').toSet(),
      equals({'transactions/t1', 'transactions/f1'}),
    );
    expect(writes[0]['data'], equals({'deleted': true}));
    expect(writes[1]['op'], equals('update'));
    expect(writes[1]['data'], equals({'deleted': true}));
  });

  test('NFR-04 (partial): Same client id saved twice -> one record row (upsert), two outbox rows', () async {
    final w1 = _sampleWallet(id: 'w1', name: 'Wallet First');
    final w1Again = _sampleWallet(id: 'w1', name: 'Wallet Second');

    await uow.run(() => walletsWriter.create(w1));
    await uow.run(() => walletsWriter.create(w1Again));

    expect(await db.select(db.wallets).get(), hasLength(1));
    expect(await db.select(db.outbox).get(), hasLength(2));
  });
}
