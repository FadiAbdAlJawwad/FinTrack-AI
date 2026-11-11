import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/transactions/presentation/utils/transaction_display_title.dart';
import 'package:fin_track_ai/features/transactions/presentation/widgets/add_transaction_bottom_sheet.dart';
import 'package:fin_track_ai/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallets_overview.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallets_overview_provider.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestWalletController extends WalletController {
  final List<WalletModel> wallets;
  TestWalletController(this.wallets);

  @override
  Stream<List<WalletModel>> build() => Stream.value(wallets);
}

class FakeCurrencyController extends CurrencyController {
  @override
  Stream<String> build() => Stream.value('USD');
}

class FakeRateService extends Fake implements ExchangeRateService {
  @override
  double rateBetween(String from, String to) => 1.0;
}

Widget createTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      currencyControllerProvider.overrideWith(FakeCurrencyController.new),
      exchangeRatesBootstrapProvider.overrideWith((ref) async {}),
      exchangeRateServiceProvider.overrideWithValue(FakeRateService()),
      walletsOverviewProvider.overrideWithValue(
        const AsyncData(
          WalletsOverview(
            currency: AppCurrency.usd,
            wallets: [],
            unassignedMinor: null,
            hasUnassigned: false,
            totalMinor: null,
          ),
        ),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('transaction_display_title tests', () {
    test(
      '1. isAutoTitle is true for empty string, spaces, and category name in EN and AR',
      () {
        final foodEn = TransactionModel(
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          title: 'Food',
          date: DateTime.now(),
          walletId: 'w1',
        );
        final foodAr = foodEn.copyWith(title: 'طعام');
        final foodEmpty = foodEn.copyWith(title: '');
        final foodSpaces = foodEn.copyWith(title: '   ');

        expect(isAutoTitle(foodEn), isTrue);
        expect(isAutoTitle(foodAr), isTrue);
        expect(isAutoTitle(foodEmpty), isTrue);
        expect(isAutoTitle(foodSpaces), isTrue);
      },
    );

    test(
      '2. isAutoTitle is false for custom notes and mismatched category names',
      () {
        final customNote = TransactionModel(
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          title: 'Lunch with Sara',
          date: DateTime.now(),
          walletId: 'w1',
        );
        final foodNameWrongCategory = TransactionModel(
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          title: 'Food',
          date: DateTime.now(),
          walletId: 'w1',
        );

        expect(isAutoTitle(customNote), isFalse);
        expect(isAutoTitle(foodNameWrongCategory), isFalse);
      },
    );

    testWidgets(
      '3. Arabic widget displays طعام for Food title; English widget displays Food for طعام title',
      (tester) async {
        final foodEn = TransactionModel(
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          title: 'Food',
          date: DateTime.now(),
          walletId: 'w1',
        );
        final foodAr = foodEn.copyWith(title: 'طعام');

        late String arResult;
        await tester.pumpWidget(
          createTestApp(
            locale: const Locale('ar'),
            child: Builder(
              builder: (context) {
                arResult = transactionDisplayTitle(context, foodEn);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(arResult, equals('طعام'));

        late String enResult;
        await tester.pumpWidget(
          createTestApp(
            locale: const Locale('en'),
            child: Builder(
              builder: (context) {
                enResult = transactionDisplayTitle(context, foodAr);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(enResult, equals('Food'));
      },
    );

    testWidgets(
      '4. Custom title Lunch with Sara is displayed unchanged in EN and AR',
      (tester) async {
        final customTx = TransactionModel(
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          title: 'Lunch with Sara',
          date: DateTime.now(),
          walletId: 'w1',
        );

        late String enResult;
        await tester.pumpWidget(
          createTestApp(
            locale: const Locale('en'),
            child: Builder(
              builder: (context) {
                enResult = transactionDisplayTitle(context, customTx);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(enResult, equals('Lunch with Sara'));

        late String arResult;
        await tester.pumpWidget(
          createTestApp(
            locale: const Locale('ar'),
            child: Builder(
              builder: (context) {
                arResult = transactionDisplayTitle(context, customTx);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(arResult, equals('Lunch with Sara'));
      },
    );

    testWidgets(
      '5. TransactionListTile in Arabic shows طعام for stored title Food',
      (tester) async {
        final tx = TransactionModel(
          id: '1',
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          title: 'Food',
          date: DateTime(2026, 1, 1),
          walletId: 'w1',
        );

        await tester.pumpWidget(
          createTestApp(
            locale: const Locale('ar'),
            child: TransactionListTile(transaction: tx),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('طعام'), findsOneWidget);
      },
    );

    testWidgets(
      '6. Editing a transaction with auto title opens sheet with empty notes field',
      (tester) async {
        final autoTx = TransactionModel(
          id: '1',
          amountMinor: 1000,
          currency: AppCurrency.usd,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          title: 'Food',
          date: DateTime.now(),
          walletId: 'w1',
        );
        final customTx = autoTx.copyWith(title: 'Lunch with Sara');

        final walletOverride = walletControllerProvider.overrideWith(
          () => TestWalletController([
            const WalletModel(
              id: 'w1',
              name: 'Cash',
              icon: 'payments',
              isDefault: true,
            ),
          ]),
        );

        await tester.pumpWidget(
          createTestApp(
            overrides: [walletOverride],
            child: AddTransactionBottomSheet(
              key: const ValueKey('auto'),
              existingTransaction: autoTx,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final TextField autoTextField = tester.widget(
          find.byType(TextField).last,
        );
        expect(autoTextField.controller?.text, equals(''));

        await tester.pumpWidget(
          createTestApp(
            overrides: [walletOverride],
            child: AddTransactionBottomSheet(
              key: const ValueKey('custom'),
              existingTransaction: customTx,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final TextField customTextField = tester.widget(
          find.byType(TextField).last,
        );
        expect(customTextField.controller?.text, equals('Lunch with Sara'));
      },
    );

    testWidgets(
      '7. Saving a transaction with empty notes stores empty string as title',
      (tester) async {
        TransactionModel? savedTx;
        final mockTxController = _TestAddTransactionController((tx) {
          savedTx = tx;
        });

        final walletOverride = walletControllerProvider.overrideWith(
          () => TestWalletController([
            const WalletModel(
              id: 'w1',
              name: 'Cash',
              icon: 'payments',
              isDefault: true,
            ),
          ]),
        );
        final txControllerOverride = transactionControllerProvider.overrideWith(
          () => mockTxController,
        );

        await tester.pumpWidget(
          createTestApp(
            overrides: [walletOverride, txControllerOverride],
            child: const AddTransactionBottomSheet(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter amount 10.00
        await tester.enterText(find.byType(TextField).first, '10.00');
        await tester.pumpAndSettle();

        // Select category Food
        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        // Tap Save button
        final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Transaction');
        expect(saveButtonFinder, findsOneWidget);
        await tester.tap(saveButtonFinder);
        await tester.pumpAndSettle();

        expect(savedTx, isNotNull);
        expect(savedTx!.title, equals(''));
      },
    );
  });
}

class _TestAddTransactionController extends TransactionController {
  final void Function(TransactionModel) onAdd;
  _TestAddTransactionController(this.onAdd);

  @override
  Stream<List<TransactionModel>> build() => Stream.value([]);

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    onAdd(transaction);
  }
}
