import 'dart:async';

import 'package:fin_track_ai/core/error/currency_exception.dart';
import 'package:fin_track_ai/core/providers/clock_provider.dart';
import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/domain/repositories/currency_repository.dart';
import 'package:fin_track_ai/features/dashboard/presentation/state/dashboard_controller.dart';
import 'package:fin_track_ai/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:fin_track_ai/features/transactions/domain/usecases/convert_totals_usecase.dart';
import 'package:fin_track_ai/features/transactions/data/repositories/firestore_transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/domain/usecases/calculate_totals_usecase.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
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

/// Rates are expressed as "1 unit of from = rate units of to".
class FakeRateService extends Fake implements ExchangeRateService {
  FakeRateService({this.rates = const {}, this.available = true});

  Map<(String, String), double> rates;
  bool available;
  final calls = <(String, String)>[];

  @override
  Future<void> ensureLoaded() async {}

  @override
  double rateBetween(String from, String to) {
    calls.add((from, to));
    if (!available) throw NoExchangeRatesAvailableException();
    final rate = rates[(from, to)];
    if (rate == null) throw Exception('Unsupported $from -> $to');
    return rate;
  }
}

TransactionModel tx(
  TransactionType type,
  int amountMinor,
  AppCurrency currency,
) => TransactionModel(
  id: '$type-$amountMinor-${currency.code}',
  amountMinor: amountMinor,
  currency: currency,
  type: type,
  category: TransactionCategory.other,
  title: 't',
  date: DateTime(2024, 5, 15),
  walletId: 'w',
);

TransactionModel txOn(String id, DateTime date) => TransactionModel(
  id: id,
  amountMinor: 100,
  currency: AppCurrency.usd,
  type: TransactionType.expense,
  category: TransactionCategory.other,
  title: 't',
  date: date,
  walletId: 'w',
);

const income = TransactionType.income;
const expense = TransactionType.expense;

Future<DashboardState> readDashboard(ProviderContainer container) async {
  container.listen(dashboardControllerProvider, (_, _) {});
  await container.read(exchangeRatesBootstrapProvider.future);
  await container.read(currencyControllerProvider.future);
  await container.read(transactionControllerProvider.future);
  return container.read(dashboardControllerProvider).requireValue;
}

ProviderContainer makeContainer({
  required List<TransactionModel> transactions,
  required String base,
  required FakeRateService rateService,
  DateTime? now,
}) {
  final container = ProviderContainer(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(
        FixedTxRepository(transactions),
      ),
      currencyRepositoryProvider.overrideWithValue(
        FixedCurrencyRepository(base),
      ),
      exchangeRateServiceProvider.overrideWithValue(rateService),
      clockProvider.overrideWithValue(() => now ?? DateTime(2024, 5, 20)),
      currentUserProvider.overrideWithValue(
        UserModel(uid: 'u', email: '', fullName: ''),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('convertTotals', () {
    double noRate(AppCurrency from, AppCurrency to) =>
        throw NoExchangeRatesAvailableException();

    test('same-currency totals need no rate', () {
      final result = convertTotals(
        {
          AppCurrency.usd: const CurrencyTotals(
            incomeMinor: 5000,
            expenseMinor: 1200,
          ),
        },
        AppCurrency.usd,
        noRate,
      );
      expect(result.incomeMinor, 5000);
      expect(result.expenseMinor, 1200);
    });

    test('empty totals are zero, not null', () {
      final result = convertTotals({}, AppCurrency.jod, noRate);
      expect(result.incomeMinor, 0);
      expect(result.expenseMinor, 0);
    });

    test('converts income and expense separately, then sums', () {
      // 0.005 JOD income and 0.005 JOD expense at rate 1.0 each round to
      // 1 cent. Netting first (0) would give a different balance.
      final result = convertTotals(
        {
          AppCurrency.usd: const CurrencyTotals(
            incomeMinor: 100,
            expenseMinor: 100,
          ),
          AppCurrency.jod: const CurrencyTotals(
            incomeMinor: 5,
            expenseMinor: 5,
          ),
        },
        AppCurrency.usd,
        (from, to) => 1.0,
      );
      expect(result.incomeMinor, 101);
      expect(result.expenseMinor, 101);
    });

    test('a missing rate nulls only the totals that needed it', () {
      final result = convertTotals(
        {
          AppCurrency.usd: const CurrencyTotals(
            incomeMinor: 1000,
            expenseMinor: 0,
          ),
          AppCurrency.ils: const CurrencyTotals(
            incomeMinor: 0,
            expenseMinor: 300,
          ),
        },
        AppCurrency.usd,
        noRate,
      );
      expect(result.incomeMinor, 1000);
      expect(result.expenseMinor, isNull);
    });

    test('the rate is requested once per foreign currency', () {
      var calls = 0;
      convertTotals(
        {
          AppCurrency.jod: const CurrencyTotals(
            incomeMinor: 1000,
            expenseMinor: 500,
          ),
        },
        AppCurrency.usd,
        (from, to) {
          calls++;
          return 1.5;
        },
      );
      expect(calls, 1);
    });
  });

  group('dashboardControllerProvider', () {
    test('same-currency totals work while rates are unavailable', () async {
      final rates = FakeRateService(available: false);
      final container = makeContainer(
        transactions: [
          tx(income, 10000, AppCurrency.usd),
          tx(expense, 2550, AppCurrency.usd),
        ],
        base: 'USD',
        rateService: rates,
      );

      final state = await readDashboard(container);

      expect(state.currency, AppCurrency.usd);
      expect(state.incomeMinor, 10000);
      expect(state.expenseMinor, 2550);
      expect(state.balanceMinor, 7450);
      expect(rates.calls, isEmpty);
    });

    test('foreign-currency totals convert with the rate service', () async {
      final rates = FakeRateService(rates: {('JOD', 'USD'): 1.5});
      final container = makeContainer(
        transactions: [
          tx(income, 2000, AppCurrency.usd),
          // 1.234 JOD * 1.5 = 1.851 USD -> 185 cents.
          tx(income, 1234, AppCurrency.jod),
          // 0.500 JOD * 1.5 = 0.75 USD -> 75 cents.
          tx(expense, 500, AppCurrency.jod),
        ],
        base: 'USD',
        rateService: rates,
      );

      final state = await readDashboard(container);

      expect(state.incomeMinor, 2185);
      expect(state.expenseMinor, 75);
      expect(state.balanceMinor, 2110);
      expect(rates.calls, [('JOD', 'USD')]);
    });

    test('totals follow the app currency, in its minor units', () async {
      final rates = FakeRateService(rates: {('USD', 'JOD'): 0.5});
      final container = makeContainer(
        transactions: [tx(expense, 123, AppCurrency.usd)],
        base: 'JOD',
        rateService: rates,
      );

      final state = await readDashboard(container);

      expect(state.currency, AppCurrency.jod);
      // 1.23 USD * 0.5 = 0.615 JOD -> 615 fils.
      expect(state.expenseMinor, 615);
      expect(state.incomeMinor, 0);
    });

    test('rates unavailable gives null totals and a null balance', () async {
      final container = makeContainer(
        transactions: [
          tx(income, 1000, AppCurrency.ils),
          tx(expense, 400, AppCurrency.ils),
        ],
        base: 'USD',
        rateService: FakeRateService(available: false),
      );

      final state = await readDashboard(container);

      expect(state.incomeMinor, isNull);
      expect(state.expenseMinor, isNull);
      expect(state.balanceMinor, isNull);
    });

    test('an unsupported pair is treated like unavailable rates', () async {
      final container = makeContainer(
        transactions: [tx(income, 1000, AppCurrency.ils)],
        base: 'USD',
        rateService: FakeRateService(),
      );

      final state = await readDashboard(container);

      expect(state.incomeMinor, isNull);
      expect(state.balanceMinor, isNull);
    });

    test('recomputes when rates become available later', () async {
      final rates = FakeRateService(
        available: false,
        rates: {('ILS', 'USD'): 0.25},
      );
      final container = makeContainer(
        transactions: [tx(income, 1000, AppCurrency.ils)],
        base: 'USD',
        rateService: rates,
      );
      expect((await readDashboard(container)).incomeMinor, isNull);

      rates.available = true;
      container.invalidate(exchangeRatesBootstrapProvider);
      await container.read(exchangeRatesBootstrapProvider.future);

      expect(
        container.read(dashboardControllerProvider).requireValue.incomeMinor,
        250,
      );
    });

    test('groups are still provided', () async {
      final container = makeContainer(
        transactions: [tx(income, 1000, AppCurrency.usd)],
        base: 'USD',
        rateService: FakeRateService(),
      );
      final state = await readDashboard(container);
      expect(state.groupedTransactions.values.expand((l) => l), hasLength(1));
    });

    test(
      'shows at most 5 most recent transactions, sorted newest first',
      () async {
        final now = DateTime(2024, 5, 20);
        final transactions = [
          txOn('tx1', DateTime(2024, 5, 10)),
          txOn('tx8', DateTime(2024, 5, 18)),
          txOn('tx3', DateTime(2024, 5, 12)),
          txOn('tx7', DateTime(2024, 5, 17)),
          txOn('tx2', DateTime(2024, 5, 11)),
          txOn('tx5', DateTime(2024, 5, 15)),
          txOn('tx6', DateTime(2024, 5, 16)),
          txOn('tx4', DateTime(2024, 5, 13)),
        ];
        final container = makeContainer(
          transactions: transactions,
          base: 'USD',
          rateService: FakeRateService(),
          now: now,
        );
        final state = await readDashboard(container);
        final shownIds = state.groupedTransactions.values
            .expand((l) => l)
            .map((t) => t.id)
            .toList();
        expect(shownIds, ['tx8', 'tx7', 'tx6', 'tx5', 'tx4']);
      },
    );

    test(
      'excludes future-dated transactions from groupedTransactions',
      () async {
        final now = DateTime(2024, 5, 20);
        final transactions = [
          txOn('past', DateTime(2024, 5, 15)),
          txOn('future', DateTime(2024, 5, 25)),
        ];
        final container = makeContainer(
          transactions: transactions,
          base: 'USD',
          rateService: FakeRateService(),
          now: now,
        );
        final state = await readDashboard(container);
        final shownIds = state.groupedTransactions.values
            .expand((l) => l)
            .map((t) => t.id)
            .toList();
        expect(shownIds, ['past']);
      },
    );

    test('totals include transactions beyond the 5 shown', () async {
      final now = DateTime(2024, 5, 20);
      final transactions = List.generate(
        7,
        (i) => txOn('tx$i', DateTime(2024, 5, 10 + i)),
      );
      final container = makeContainer(
        transactions: transactions,
        base: 'USD',
        rateService: FakeRateService(),
        now: now,
      );
      final state = await readDashboard(container);
      final shownCount = state.groupedTransactions.values
          .expand((l) => l)
          .length;
      expect(shownCount, 5);
      expect(state.expenseMinor, 700);
    });
  });
}
