import 'dart:async';

import 'package:fin_track_ai/core/providers/clock_provider.dart';
import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/domain/repositories/currency_repository.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/transactions/data/repositories/firestore_transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/period_totals_provider.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_filters_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';

class FixedTxRepository extends Fake implements TransactionRepository {
  FixedTxRepository(this.transactions);

  final List<TransactionModel> transactions;

  @override
  Stream<List<TransactionModel>> getTransactionsStream() =>
      Stream.value(transactions);
}

class FixedCurrencyRepository extends Fake implements CurrencyRepository {
  FixedCurrencyRepository(this.base);

  final String base;

  @override
  Stream<String> watchBaseCurrency() => Stream.value(base);
}

class FakeRateService extends Fake implements ExchangeRateService {
  FakeRateService({this.rates = const {}});

  Map<(String, String), double> rates;

  @override
  Future<void> ensureLoaded() async {}

  @override
  double rateBetween(String from, String to) {
    final rate = rates[(from, to)];
    if (rate == null) throw Exception('Unsupported $from -> $to');
    return rate;
  }
}

TransactionModel makeTx({
  required String id,
  required DateTime date,
  required TransactionType type,
  int amountMinor = 100,
  AppCurrency currency = AppCurrency.usd,
}) {
  return TransactionModel(
    id: id,
    amountMinor: amountMinor,
    currency: currency,
    type: type,
    category: TransactionCategory.other,
    title: 'test tx',
    date: date,
    walletId: 'w1',
  );
}

ProviderContainer makeTestContainer({
  required List<TransactionModel> transactions,
  String base = 'USD',
  FakeRateService? rateService,
  DateTime? clockNow,
}) {
  final container = ProviderContainer(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(
        FixedTxRepository(transactions),
      ),
      currencyRepositoryProvider.overrideWithValue(
        FixedCurrencyRepository(base),
      ),
      exchangeRateServiceProvider.overrideWithValue(
        rateService ?? FakeRateService(),
      ),
      clockProvider.overrideWithValue(
        () => clockNow ?? DateTime(2024, 5, 15, 10),
      ),
      currentUserProvider.overrideWithValue(
        UserModel(uid: 'u', email: '', fullName: ''),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> awaitData(ProviderContainer container) async {
  await container.read(exchangeRatesBootstrapProvider.future);
  await container.read(currencyControllerProvider.future);
  await container.read(transactionControllerProvider.future);
}

void main() {
  test('a) default (no date filter): includes May 1 00:00 and May 31 23:59, excludes Apr 30 23:59 and Jun 1 00:00', () async {
    final txs = [
      makeTx(
        id: 'apr_end',
        date: DateTime(2024, 4, 30, 23, 59),
        type: TransactionType.expense,
      ),
      makeTx(
        id: 'may_start',
        date: DateTime(2024, 5, 1, 0, 0),
        type: TransactionType.income,
      ),
      makeTx(
        id: 'may_end',
        date: DateTime(2024, 5, 31, 23, 59),
        type: TransactionType.expense,
      ),
      makeTx(
        id: 'jun_start',
        date: DateTime(2024, 6, 1, 0, 0),
        type: TransactionType.income,
      ),
    ];

    final container = makeTestContainer(
      transactions: txs,
      clockNow: DateTime(2024, 5, 15, 10),
    );
    container.listen(filteredTransactionsProvider, (_, _) {});
    await awaitData(container);

    final filtered = container.read(filteredTransactionsProvider);
    final ids = filtered.values.expand((l) => l).map((t) => t.id).toList();

    expect(ids, containsAll(['may_start', 'may_end']));
    expect(ids, isNot(contains('apr_end')));
    expect(ids, isNot(contains('jun_start')));
  });

  test(
    'b) clock on 2024-06-01: a 2024-05-31 transaction is excluded',
    () async {
      final txs = [
        makeTx(
          id: 'may_end',
          date: DateTime(2024, 5, 31, 23, 59),
          type: TransactionType.expense,
        ),
        makeTx(
          id: 'jun_start',
          date: DateTime(2024, 6, 1, 10, 0),
          type: TransactionType.income,
        ),
      ];

      final container = makeTestContainer(
        transactions: txs,
        clockNow: DateTime(2024, 6, 1, 12, 0),
      );
      container.listen(filteredTransactionsProvider, (_, _) {});
      await awaitData(container);

      final filtered = container.read(filteredTransactionsProvider);
      final ids = filtered.values.expand((l) => l).map((t) => t.id).toList();

      expect(ids, ['jun_start']);
    },
  );

  test('c) date filter set to April 2024 range replaces default', () async {
    final txs = [
      makeTx(
        id: 'apr_tx',
        date: DateTime(2024, 4, 15, 10, 0),
        type: TransactionType.expense,
      ),
      makeTx(
        id: 'may_tx',
        date: DateTime(2024, 5, 15, 10, 0),
        type: TransactionType.income,
      ),
    ];

    final container = makeTestContainer(
      transactions: txs,
      clockNow: DateTime(2024, 5, 15, 10),
    );
    container.listen(filteredTransactionsProvider, (_, _) {});
    await awaitData(container);

    container.read(transactionDateRangeFilterProvider.notifier).state =
        DateTimeRange(start: DateTime(2024, 4, 1), end: DateTime(2024, 4, 30));

    final filtered = container.read(filteredTransactionsProvider);
    final ids = filtered.values.expand((l) => l).map((t) => t.id).toList();

    expect(ids, ['apr_tx']);
  });

  test('d) type filter income keeps only income in the list', () async {
    final txs = [
      makeTx(
        id: 'may_inc',
        date: DateTime(2024, 5, 10),
        type: TransactionType.income,
      ),
      makeTx(
        id: 'may_exp',
        date: DateTime(2024, 5, 12),
        type: TransactionType.expense,
      ),
    ];

    final container = makeTestContainer(
      transactions: txs,
      clockNow: DateTime(2024, 5, 15, 10),
    );
    container.listen(filteredTransactionsProvider, (_, _) {});
    await awaitData(container);

    container.read(transactionTypeFilterProvider.notifier).state =
        TransactionType.income;

    final filtered = container.read(filteredTransactionsProvider);
    final ids = filtered.values.expand((l) => l).map((t) => t.id).toList();

    expect(ids, ['may_inc']);
  });

  test('e) periodTotalsProvider with USD base: totals count current-month transactions and ignore type filter', () async {
    final txs = [
      makeTx(
        id: 'may_inc',
        date: DateTime(2024, 5, 10),
        type: TransactionType.income,
        amountMinor: 100,
      ),
      makeTx(
        id: 'may_exp',
        date: DateTime(2024, 5, 12),
        type: TransactionType.expense,
        amountMinor: 200,
      ),
      makeTx(
        id: 'apr_inc',
        date: DateTime(2024, 4, 10),
        type: TransactionType.income,
        amountMinor: 500,
      ),
    ];

    final container = makeTestContainer(
      transactions: txs,
      clockNow: DateTime(2024, 5, 15, 10),
    );
    container.listen(periodTotalsProvider, (_, _) {});
    await awaitData(container);

    // Set type filter to income
    container.read(transactionTypeFilterProvider.notifier).state =
        TransactionType.income;

    final totals = container.read(periodTotalsProvider).requireValue;

    expect(totals.currency, AppCurrency.usd);
    expect(totals.incomeMinor, 100);
    expect(totals.expenseMinor, 200); // non-zero despite type filter
  });

  test('f) periodTotalsProvider follows date filter', () async {
    final txs = [
      makeTx(
        id: 'may_inc',
        date: DateTime(2024, 5, 10),
        type: TransactionType.income,
        amountMinor: 100,
      ),
      makeTx(
        id: 'apr_inc',
        date: DateTime(2024, 4, 10),
        type: TransactionType.income,
        amountMinor: 300,
      ),
      makeTx(
        id: 'apr_exp',
        date: DateTime(2024, 4, 12),
        type: TransactionType.expense,
        amountMinor: 150,
      ),
    ];

    final container = makeTestContainer(
      transactions: txs,
      clockNow: DateTime(2024, 5, 15, 10),
    );
    container.listen(periodTotalsProvider, (_, _) {});
    await awaitData(container);

    container.read(transactionDateRangeFilterProvider.notifier).state =
        DateTimeRange(start: DateTime(2024, 4, 1), end: DateTime(2024, 4, 30));

    final totals = container.read(periodTotalsProvider).requireValue;

    expect(totals.currency, AppCurrency.usd);
    expect(totals.incomeMinor, 300);
    expect(totals.expenseMinor, 150);
  });
}
