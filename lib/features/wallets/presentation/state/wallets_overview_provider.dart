import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../currency/data/services/exchange_rate_service.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../../transactions/presentation/state/transaction_controller.dart';
import '../../domain/models/wallets_overview.dart';
import '../../domain/usecases/build_wallets_overview_usecase.dart';
import 'wallet_controller.dart';

final walletsOverviewProvider =
    Provider.autoDispose<AsyncValue<WalletsOverview>>((ref) {
      final transactionsAsync = ref.watch(transactionControllerProvider);
      final walletsAsync = ref.watch(walletControllerProvider);

      final appCurrency = appCurrencyFromCode(
        ref.watch(currencyControllerProvider).valueOrNull ?? 'USD',
      );

      // Watched only to recompute once rates finish loading.
      ref.watch(exchangeRatesBootstrapProvider);
      final rateService = ref.watch(exchangeRateServiceProvider);

      if (transactionsAsync is AsyncError) {
        return AsyncError(
          transactionsAsync.error!,
          transactionsAsync.stackTrace!,
        );
      }
      if (walletsAsync is AsyncError) {
        return AsyncError(walletsAsync.error!, walletsAsync.stackTrace!);
      }

      if (!transactionsAsync.hasValue || !walletsAsync.hasValue) {
        return const AsyncLoading();
      }

      final transactions = transactionsAsync.requireValue;
      final wallets = walletsAsync.requireValue;

      final overview = buildWalletsOverview(
        wallets: wallets,
        transactions: transactions,
        target: appCurrency,
        rateBetween: (from, to) => rateService.rateBetween(from.code, to.code),
      );

      return AsyncData(overview);
    });
