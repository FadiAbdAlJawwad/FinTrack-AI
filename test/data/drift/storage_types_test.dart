import 'package:fin_track_ai/data/drift/app_database.dart';
import 'package:fin_track_ai/data/drift/corrupt_stored_value_exception.dart';
import 'package:fin_track_ai/data/drift/database_factory.dart';
import 'package:fin_track_ai/data/drift/drift_unit_of_work.dart';
import 'package:fin_track_ai/data/drift/transactions_writer.dart';
import 'package:fin_track_ai/domain/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionDto _sampleTransfer({
  required String id,
  required LocalDate date,
  String fromWalletId = 'w1',
  String toWalletId = 'w2',
}) {
  return TransactionDto(
    id: id,
    kind: 'transfer',
    date: date,
    fromWalletId: fromWalletId,
    toWalletId: toWalletId,
    amountSentMinor: 1000,
    sentCurrency: 'USD',
    amountReceivedMinor: 1000,
    receivedCurrency: 'USD',
    deleted: false,
  );
}

void main() {
  late AppDatabase db;
  late DriftUnitOfWork uow;

  setUp(() {
    db = openInMemory();
    uow = DriftUnitOfWork(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('ADR-0010/9: LocalDate stored as \'YYYY-MM-DD\'; text order = date order across a year boundary; instant stored as ms UTC', () async {
    final fixedTime = DateTime.utc(2026, 1, 15, 12, 0, 0);
    final customWriter = TransactionsWriter(db, () => fixedTime);

    final t1 = _sampleTransfer(id: 't1', date: LocalDate(2025, 12, 31));
    final t2 = _sampleTransfer(id: 't2', date: LocalDate(2026, 1, 1));

    await uow.run(() => customWriter.saveTransfer(t1, null));
    await uow.run(() => customWriter.saveTransfer(t2, null));

    final rawRows = await db
        .customSelect('SELECT date FROM transactions ORDER BY date')
        .get();
    final dates = rawRows.map((r) => r.read<String>('date')).toList();
    expect(dates, equals(['2025-12-31', '2026-01-01']));

    final outbox = await db.select(db.outbox).get();
    expect(outbox.first.createdAt, equals(fixedTime.millisecondsSinceEpoch));
  });

  test('ADR-0010/10: Raw \'2026-2-1\' inserted with customStatement -> read throws CorruptStoredValueException', () async {
    await db.customStatement(
      "INSERT INTO transactions (id, kind, date, deleted) VALUES ('t1', 'income', '2026-2-1', 0)",
    );

    await expectLater(
      () => db.select(db.transactions).get(),
      throwsA(
        isA<CorruptStoredValueException>()
            .having((e) => e.table, 'table', 'transactions')
            .having((e) => e.column, 'column', 'date')
            .having((e) => e.rawValue, 'rawValue', '2026-2-1'),
      ),
    );
  });
}
