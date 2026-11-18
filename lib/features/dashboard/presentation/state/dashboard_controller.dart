import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../currency/data/services/exchange_rate_service.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../../transactions/domain/transaction_limits.dart';
import '../../../transactions/presentation/state/transaction_controller.dart';
import '../../../transactions/domain/usecases/group_transactions_usecase.dart';
import '../../../transactions/domain/usecases/calculate_totals_usecase.dart';
import '../../../transactions/domain/usecases/convert_totals_usecase.dart';
import '../states/dashboard_state.dart';

final dashboardControllerProvider =
    Provider.autoDispose<AsyncValue<DashboardState>>((ref) {
      final transactionsAsync = ref.watch(transactionControllerProvider);
      final appCurrency = appCurrencyFromCode(
        ref.watch(currencyControllerProvider).valueOrNull ?? 'USD',
      );
      // Watched only to recompute once rates finish loading (or are retried
      // from the gate screen); the value itself is not used.
      ref.watch(exchangeRatesBootstrapProvider);
      final rateService = ref.watch(exchangeRateServiceProvider);
      final now = ref.watch(clockProvider)();

      return transactionsAsync.whenData((transactions) {
        final totals = convertTotals(
          calculateTotals(transactions),
          appCurrency,
          (from, to) => rateService.rateBetween(from.code, to.code),
        );

        final recent =
            (transactions.where((t) => !t.date.isAfter(now)).toList()
                  ..sort((a, b) => b.date.compareTo(a.date)))
                .take(homeRecentCount)
                .toList();

        return DashboardState(
          groupedTransactions: groupTransactions(recent, now: now),
          currency: appCurrency,
          incomeMinor: totals.incomeMinor,
          expenseMinor: totals.expenseMinor,
        );
      });
    });
