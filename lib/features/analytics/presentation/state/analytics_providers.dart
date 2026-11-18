import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../currency/data/services/exchange_rate_service.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../../transactions/presentation/state/transaction_controller.dart';
import '../../domain/models/analytics_period.dart';
import '../../domain/models/analytics_summary.dart';
import '../../domain/usecases/build_analytics_summary_usecase.dart';

final analyticsPeriodProvider = StateProvider.autoDispose<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.month,
);

final analyticsSummaryProvider =
    Provider.autoDispose<AsyncValue<AnalyticsSummary>>((ref) {
      final transactionsAsync = ref.watch(transactionControllerProvider);
      final appCurrency = appCurrencyFromCode(
        ref.watch(currencyControllerProvider).valueOrNull ?? 'USD',
      );
      ref.watch(exchangeRatesBootstrapProvider);
      final rateService = ref.watch(exchangeRateServiceProvider);
      final now = ref.watch(clockProvider)();
      final period = ref.watch(analyticsPeriodProvider);

      return transactionsAsync.whenData(
        (transactions) => buildAnalyticsSummary(
          transactions: transactions,
          period: period,
          now: now,
          target: appCurrency,
          rateBetween: (from, to) =>
              rateService.rateBetween(from.code, to.code),
        ),
      );
    });
