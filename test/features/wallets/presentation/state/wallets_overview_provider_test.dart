import 'dart:async';

import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallets_overview_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FakeRateService extends Fake implements ExchangeRateService {
  @override
  double rateBetween(String from, String to) {
    if (from == to) return 1.0;
    return 2.0;
  }
}

class FakeTxController extends TransactionController {
  FakeTxController(this.streamController);
  final StreamController<List<TransactionModel>> streamController;

  @override
  Stream<List<TransactionModel>> build() => streamController.stream;
}

class FakeWalletController extends WalletController {
  FakeWalletController(this.streamController);
  final StreamController<List<WalletModel>> streamController;

  @override
  Stream<List<WalletModel>> build() => streamController.stream;
}

class FakeCurrencyController extends CurrencyController {
  FakeCurrencyController(this.streamController);
  final StreamController<String> streamController;

  @override
  Stream<String> build() => streamController.stream;
}

void main() {
  group('walletsOverviewProvider', () {
    test('yields loading, error, and data states appropriately', () async {
      final txController = StreamController<List<TransactionModel>>();
      final walletController = StreamController<List<WalletModel>>();
      final currencyController = StreamController<String>.broadcast();
      currencyController.add('USD'); // seed value

      final container = ProviderContainer(
        overrides: [
          transactionControllerProvider.overrideWith(
            () => FakeTxController(txController),
          ),
          walletControllerProvider.overrideWith(
            () => FakeWalletController(walletController),
          ),
          currencyControllerProvider.overrideWith(
            () => FakeCurrencyController(currencyController),
          ),
          exchangeRateServiceProvider.overrideWithValue(FakeRateService()),
          exchangeRatesBootstrapProvider.overrideWith((ref) => Future.value()),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(walletsOverviewProvider, (_, _) {});

      expect(container.read(walletsOverviewProvider), isA<AsyncLoading>());

      walletController.add([
        const WalletModel(
          id: 'w1',
          name: 'W1',
          icon: 'wallet',
          isDefault: true,
        ),
      ]);
      await Future.microtask(() {});
      expect(container.read(walletsOverviewProvider), isA<AsyncLoading>());

      txController.add([]);
      await Future.microtask(() {});

      final dataState = container.read(walletsOverviewProvider);
      expect(dataState, isA<AsyncData>());
      expect(dataState.value!.wallets.length, 1);

      txController.addError(Exception('Test error'));
      await Future.microtask(() {});
      expect(container.read(walletsOverviewProvider), isA<AsyncError>());

      await txController.close();
      await walletController.close();
      await currencyController.close();
      sub.close();
    });
  });
}
