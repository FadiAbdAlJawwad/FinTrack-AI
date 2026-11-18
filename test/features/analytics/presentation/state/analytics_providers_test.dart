import 'package:fin_track_ai/core/error/currency_exception.dart';
import 'package:fin_track_ai/core/providers/clock_provider.dart';
import 'package:fin_track_ai/features/analytics/domain/models/analytics_period.dart';
import 'package:fin_track_ai/features/analytics/presentation/state/analytics_providers.dart';
import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/domain/repositories/currency_repository.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/transactions/data/repositories/firestore_transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/domain/repositories/transaction_repository.dart';
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

class ErrorTxRepository extends Fake implements TransactionRepository {
  ErrorTxRepository(this.error);

  final Object error;

  @override
  Stream<List<TransactionModel>> getTransactionsStream() => Stream.error(error);
}

class FixedCurrencyRepository extends Fake implements CurrencyRepository {
  FixedCurrencyRepository(this.base);

  final String base;

  @override
  Stream<String> watchBaseCurrency() => Stream.value(base);
}

class FakeRateService extends Fake implements ExchangeRateService {
  FakeRateService({this.rates = const {}, this.available = true});

  Map<(String, String), double> rates;
  bool available;

  @override
  Future<void> ensureLoaded() async {}

  @override
  double rateBetween(String from, String to) {
    if (!available) throw NoExchangeRatesAvailableException();
    final rate = rates[(from, to)];
    if (rate == null) throw Exception('Unsupported $from -> $to');
    return rate;
  }
}

TransactionModel makeTx({
  required String id,
  required int amountMinor,
  required AppCurrency currency,
  required TransactionType type,
  required TransactionCategory category,
  required DateTime date,
}) {
  return TransactionModel(
    id: id,
    amountMinor: amountMinor,
    currency: currency,
    type: type,
    category: category,
    title: 'Test',
    date: date,
    walletId: 'w1',
  );
}

ProviderContainer makeContainer({
  required TransactionRepository txRepo,
  required String base,
  required FakeRateService rateService,
  DateTime? now,
}) {
  final container = ProviderContainer(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(txRepo),
      currencyRepositoryProvider.overrideWithValue(
        FixedCurrencyRepository(base),
      ),
      exchangeRateServiceProvider.overrideWithValue(rateService),
      clockProvider.overrideWithValue(() => now ?? DateTime(2026, 10, 14)),
      currentUserProvider.overrideWithValue(
        UserModel(uid: 'u', email: '', fullName: ''),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final now = DateTime(
    2026,
    10,
    14,
  ); // Month: Oct 1..Nov 1. Week: Oct 8..Oct 15.

  group('analyticsSummaryProvider', () {
    test('19. Default period is month; setting analyticsPeriodProvider to week recomputes the summary for that period', () async {
      // Tx 1: Oct 5, 2026 -> inside month, outside week.
      // Tx 2: Oct 10, 2026 -> inside both month and week.
      final tx1 = makeTx(
        id: 'tx1',
        amountMinor: 1000,
        currency: AppCurrency.usd,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2026, 10, 5),
      );
      final tx2 = makeTx(
        id: 'tx2',
        amountMinor: 2000,
        currency: AppCurrency.usd,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: DateTime(2026, 10, 10),
      );

      final container = makeContainer(
        txRepo: FixedTxRepository([tx1, tx2]),
        base: 'USD',
        rateService: FakeRateService(),
        now: now,
      );

      container.listen(analyticsSummaryProvider, (_, _) {});
      await container.read(exchangeRatesBootstrapProvider.future);
      await container.read(currencyControllerProvider.future);
      await container.read(transactionControllerProvider.future);

      // Default period is month
      expect(container.read(analyticsPeriodProvider), AnalyticsPeriod.month);
      final monthSummary = container
          .read(analyticsSummaryProvider)
          .requireValue;
      expect(monthSummary.period, AnalyticsPeriod.month);
      expect(monthSummary.transactionCount, 2);
      expect(monthSummary.expenseMinor, 3000);

      // Switch period to week
      container.read(analyticsPeriodProvider.notifier).state =
          AnalyticsPeriod.week;

      final weekSummary = container.read(analyticsSummaryProvider).requireValue;
      expect(weekSummary.period, AnalyticsPeriod.week);
      expect(weekSummary.transactionCount, 1);
      expect(weekSummary.expenseMinor, 2000);
    });

    test('20. Error state: a repository stream that errors yields AsyncError from analyticsSummaryProvider', () async {
      final container = makeContainer(
        txRepo: ErrorTxRepository(Exception('Database error')),
        base: 'USD',
        rateService: FakeRateService(),
        now: now,
      );

      container.listen(analyticsSummaryProvider, (_, _) {});
      await container.read(exchangeRatesBootstrapProvider.future);
      await container.read(currencyControllerProvider.future);

      // Pump or wait for stream error
      await Future<void>.delayed(Duration.zero);

      final summaryState = container.read(analyticsSummaryProvider);
      expect(summaryState, isA<AsyncError>());
    });

    test('21. Independence: changing transactionDateRangeFilterProvider to a different range does NOT change the analytics summary', () async {
      final tx1 = makeTx(
        id: 'tx1',
        amountMinor: 1000,
        currency: AppCurrency.usd,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(2026, 10, 5),
      );

      final container = makeContainer(
        txRepo: FixedTxRepository([tx1]),
        base: 'USD',
        rateService: FakeRateService(),
        now: now,
      );

      container.listen(analyticsSummaryProvider, (_, _) {});
      await container.read(exchangeRatesBootstrapProvider.future);
      await container.read(currencyControllerProvider.future);
      await container.read(transactionControllerProvider.future);

      final initialSummary = container
          .read(analyticsSummaryProvider)
          .requireValue;
      expect(initialSummary.transactionCount, 1);

      // Change Transactions screen filter to a date range in 2020 that excludes tx1
      container
          .read(transactionDateRangeFilterProvider.notifier)
          .state = DateTimeRange(
        start: DateTime(2020, 1, 1),
        end: DateTime(2020, 1, 31),
      );

      final summaryAfterFilterChange = container
          .read(analyticsSummaryProvider)
          .requireValue;
      expect(summaryAfterFilterChange.transactionCount, 1);
      expect(summaryAfterFilterChange.expenseMinor, 1000);
    });
  });
}
