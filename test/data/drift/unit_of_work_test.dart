import 'package:fin_track_ai/data/drift/app_database.dart';
import 'package:fin_track_ai/data/drift/database_factory.dart';
import 'package:fin_track_ai/data/drift/drift_unit_of_work.dart';
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

void main() {
  late AppDatabase db;
  late DriftUnitOfWork uow;
  late WalletsWriter walletsWriter;

  setUp(() {
    db = openInMemory();
    uow = DriftUnitOfWork(db);
    walletsWriter = WalletsWriter(db, DateTime.now);
  });

  tearDown(() async {
    await db.close();
  });

  test('ADR-0002/1: A throw inside run rolls back the record and its outbox row', () async {
    final wallet1 = _sampleWallet(id: 'w1');
    await uow.run(() async {
      await walletsWriter.create(wallet1);
    });
    expect(await db.select(db.wallets).get(), hasLength(1));
    expect(await db.select(db.outbox).get(), hasLength(1));

    final wallet2 = _sampleWallet(id: 'w2');
    await expectLater(
      () => uow.run(() async {
        await walletsWriter.create(wallet2);
        throw Exception('simulated failure');
      }),
      throwsA(isA<Exception>()),
    );
    final wallets = await db.select(db.wallets).get();
    expect(wallets.map((w) => w.id), isNot(contains('w2')));
    final outbox = await db.select(db.outbox).get();
    expect(outbox, hasLength(1));
  });

  test('ADR-0010/11: run inside run throws StateError; outer writes rolled back', () async {
    final wallet1 = _sampleWallet(id: 'w1');
    await uow.run(() async {
      await walletsWriter.create(wallet1);
    });
    expect(await db.select(db.wallets).get(), hasLength(1));

    final wallet2 = _sampleWallet(id: 'w2');
    final wallet3 = _sampleWallet(id: 'w3');
    await expectLater(
      () => uow.run(() async {
        await walletsWriter.create(wallet2);
        await uow.run(() async {
          await walletsWriter.create(wallet3);
        });
      }),
      throwsA(isA<StateError>()),
    );
    final wallets = await db.select(db.wallets).get();
    expect(wallets.map((w) => w.id), isNot(contains('w2')));
  });

  test('ADR-0010/5: Synced-store write outside run throws StateError', () async {
    final wallet1 = _sampleWallet(id: 'w1');
    await uow.run(() async {
      await walletsWriter.create(wallet1);
    });
    expect(await db.select(db.wallets).get(), hasLength(1));

    final wallet2 = _sampleWallet(id: 'w2');
    await expectLater(
      () => walletsWriter.create(wallet2),
      throwsA(isA<StateError>()),
    );
    final wallets = await db.select(db.wallets).get();
    expect(wallets.map((w) => w.id), isNot(contains('w2')));
  });
}
