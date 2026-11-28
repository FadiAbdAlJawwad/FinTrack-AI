import 'package:fin_track_ai/data/drift/app_database.dart';
import 'package:fin_track_ai/data/drift/database_factory.dart';
import 'package:fin_track_ai/data/sync/outbox_reader.dart';
import 'package:fin_track_ai/data/sync/pulled_doc.dart';
import 'package:fin_track_ai/data/sync/pulled_doc_applier.dart';
import 'package:fin_track_ai/domain/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

WalletDto _sampleWallet({required String id}) {
  return WalletDto(
    id: id,
    name: 'Wallet $id',
    kind: 'bank',
    currency: 'USD',
    openingBalanceMinor: 1000,
    status: 'active',
    createdOn: LocalDate(2026, 1, 1),
    hasTransactions: false,
    deleted: false,
  );
}

TransactionDto _sampleTransfer({required String id}) {
  return TransactionDto(
    id: id,
    kind: 'transfer',
    date: LocalDate(2026, 1, 1),
    fromWalletId: 'w1',
    toWalletId: 'w2',
    amountSentMinor: 1000,
    sentCurrency: 'USD',
    amountReceivedMinor: 1000,
    receivedCurrency: 'USD',
    deleted: false,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = openInMemory();
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'ADR-0010/6: Pull-apply path writes N documents -> outbox count unchanged',
    () async {
      final w1 = _sampleWallet(id: 'w1');
      final w2 = _sampleWallet(id: 'w2');
      final w3 = _sampleWallet(id: 'w3');
      final t1 = _sampleTransfer(id: 't1');
      final t2 = _sampleTransfer(id: 't2');

      final applier = PulledDocApplier(db);
      await applier.apply([
        PulledWallet(w1),
        PulledWallet(w2),
        PulledWallet(w3),
        PulledTransaction(t1),
        PulledTransaction(t2),
      ]);

      expect(await db.select(db.wallets).get(), hasLength(3));
      expect(await db.select(db.transactions).get(), hasLength(2));
      expect(await db.select(db.outbox).get(), isEmpty);
    },
  );

  test('ADR-0002 order: Outbox rows read back in seq order regardless of instant values', () async {
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(writes: '[]', keys: '[]', createdAt: 3000),
        );
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(writes: '[]', keys: '[]', createdAt: 2000),
        );
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(writes: '[]', keys: '[]', createdAt: 1000),
        );

    final reader = OutboxReader(db);
    final entries = await reader.readAll();

    expect(entries, hasLength(3));
    expect(entries.map((e) => e.seq).toList(), equals([1, 2, 3]));
  });
}
