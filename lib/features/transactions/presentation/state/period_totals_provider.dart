import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../currency/data/services/exchange_rate_service.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../domain/usecases/calculate_totals_usecase.dart';
import '../../domain/usecases/convert_totals_usecase.dart';
import 'transaction_controller.dart';
import 'transaction_filters_provider.dart';

final periodTotalsProvider =
    Provider.autoDispose<
      AsyncValue<({AppCurrency currency, int? incomeMinor, int? expenseMinor})>
    >((ref) {
      final transactionsAsync = ref.watch(transactionControllerProvider);
      final appCurrency = appCurrencyFromCode(
        ref.watch(currencyControllerProvider).valueOrNull ?? 'USD',
      );
      // Watched only to recompute once rates finish loading (or are retried
      // from the gate screen); the value itself is not used.
      ref.watch(exchangeRatesBootstrapProvider);
      final rateService = ref.watch(exchangeRateServiceProvider);
      final effectivePeriod = ref.watch(transactionEffectivePeriodProvider);

      return transactionsAsync.whenData((transactions) {
        final filtered = transactions.where((tx) {
          return tx.date.isAfter(
                effectivePeriod.start.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(
                effectivePeriod.end.add(const Duration(days: 1)),
              );
        }).toList();

        final totals = convertTotals(
          calculateTotals(filtered),
          appCurrency,
          (from, to) => rateService.rateBetween(from.code, to.code),
        );

        return (
          currency: appCurrency,
          incomeMinor: totals.incomeMinor,
          expenseMinor: totals.expenseMinor,
        );
      });
    });
