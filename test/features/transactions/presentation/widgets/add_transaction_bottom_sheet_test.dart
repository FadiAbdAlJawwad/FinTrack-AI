import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/transactions/presentation/widgets/add_transaction_bottom_sheet.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallets_overview.dart';
import 'package:fin_track_ai/features/wallets/domain/usecases/build_wallets_overview_usecase.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallets_overview_provider.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestWalletController extends WalletController {
  TestWalletController(this.wallets);
  final List<WalletModel> wallets;

  @override
  Stream<List<WalletModel>> build() => Stream.value(wallets);
}

class TestTransactionController extends TransactionController {
  TestTransactionController(this.transactions, {this.onAddTransaction});

  final List<TransactionModel> transactions;
  final Future<void> Function(TransactionModel transaction)? onAddTransaction;

  @override
  Stream<List<TransactionModel>> build() => Stream.value(transactions);

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    if (onAddTransaction != null) {
      await onAddTransaction!(transaction);
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    if (onAddTransaction != null) {
      await onAddTransaction!(transaction);
    }
  }
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
  required List<WalletModel> wallets,
  List<TransactionModel> transactions = const [],
  Future<void> Function(TransactionModel transaction)? onAddTransaction,
  TransactionModel? existingTransaction,
}) {
  final overview = buildWalletsOverview(
    wallets: wallets,
    transactions: transactions,
    target: AppCurrency.usd,
    rateBetween: (from, to) => 1.0,
  );

  return ProviderScope(
    overrides: [
      walletControllerProvider.overrideWith(() => TestWalletController(wallets)),
      transactionControllerProvider.overrideWith(
        () => TestTransactionController(transactions, onAddTransaction: onAddTransaction),
      ),
      currencyControllerProvider.overrideWith(FakeCurrencyController.new),
      exchangeRatesBootstrapProvider.overrideWith((ref) async {}),
      exchangeRateServiceProvider.overrideWithValue(FakeRateService()),
      walletsOverviewProvider.overrideWithValue(AsyncData(overview)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddTransactionBottomSheet(
                existingTransaction: existingTransaction,
              ),
            ),
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final defaultWallet = const WalletModel(
    id: 'w1',
    name: 'Cash',
    icon: 'payments',
    isDefault: true,
    type: WalletType.cash,
    openingBalanceMinor: 1000, // $10.00
    openingBalanceCurrency: AppCurrency.usd,
  );

  group('AddTransactionBottomSheet balance check', () {
    testWidgets('expense above balance shows SnackBar and does not call add',
        (tester) async {
      int addCallCount = 0;

      await tester.pumpWidget(
        createTestApp(
          wallets: [defaultWallet],
          onAddTransaction: (tx) async {
            addCallCount++;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter amount higher than balance: 15.00 ($15.00 > $10.00)
      await tester.enterText(find.byType(TextField).first, '15.00');
      await tester.pumpAndSettle();

      // Select category
      final categoryFinder = find.text('Food');
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Transaction');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(addCallCount, 0);
      expect(find.text('Insufficient balance'), findsOneWidget);
      expect(find.byType(AddTransactionBottomSheet), findsOneWidget);
    });

    testWidgets('expense within balance saves', (tester) async {
      int addCallCount = 0;

      await tester.pumpWidget(
        createTestApp(
          wallets: [defaultWallet],
          onAddTransaction: (tx) async {
            addCallCount++;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter amount within balance: 5.00 ($5.00 <= $10.00)
      await tester.enterText(find.byType(TextField).first, '5.00');
      await tester.pumpAndSettle();

      // Select category
      final categoryFinder = find.text('Food');
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Transaction');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(addCallCount, 1);
      expect(find.byType(AddTransactionBottomSheet), findsNothing);
    });

    testWidgets('income above balance saves', (tester) async {
      int addCallCount = 0;

      await tester.pumpWidget(
        createTestApp(
          wallets: [defaultWallet],
          onAddTransaction: (tx) async {
            addCallCount++;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Select Income
      final incomeFinder = find.text('Income');
      await tester.ensureVisible(incomeFinder);
      await tester.tap(incomeFinder);
      await tester.pumpAndSettle();

      // Enter amount 50.00
      await tester.enterText(find.byType(TextField).first, '50.00');
      await tester.pumpAndSettle();

      // Select category Salary
      final categoryFinder = find.text('Salary');
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Transaction');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(addCallCount, 1);
      expect(find.byType(AddTransactionBottomSheet), findsNothing);
    });

    testWidgets('null balance saves', (tester) async {
      int addCallCount = 0;

      const nullBalanceWallet = WalletModel(
        id: 'w2',
        name: 'Bank',
        icon: 'account_balance',
        isDefault: true,
        type: WalletType.bank,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(() => TestWalletController([nullBalanceWallet])),
            transactionControllerProvider.overrideWith(
              () => TestTransactionController([], onAddTransaction: (tx) async => addCallCount++),
            ),
            currencyControllerProvider.overrideWith(FakeCurrencyController.new),
            exchangeRatesBootstrapProvider.overrideWith((ref) async {}),
            exchangeRateServiceProvider.overrideWithValue(FakeRateService()),
            walletsOverviewProvider.overrideWithValue(
              const AsyncData(
                WalletsOverview(
                  currency: AppCurrency.usd,
                  wallets: [
                    WalletBalance(wallet: nullBalanceWallet, balanceMinor: null),
                  ],
                  unassignedMinor: null,
                  hasUnassigned: false,
                  totalMinor: null,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddTransactionBottomSheet(),
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter amount 50.00
      await tester.enterText(find.byType(TextField).first, '50.00');
      await tester.pumpAndSettle();

      // Select category Food
      final categoryFinder = find.text('Food');
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Transaction');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(addCallCount, 1);
      expect(find.byType(AddTransactionBottomSheet), findsNothing);
    });

    testWidgets(
        'edit mode of expense in SAME wallet passes when new amount <= balance + old amount and fails above',
        (tester) async {
      int updateCallCount = 0;

      final wallet = const WalletModel(
        id: 'w1',
        name: 'Cash',
        icon: 'payments',
        isDefault: true,
        type: WalletType.cash,
        openingBalanceMinor: 1000,
      );

      final existingExpense = TransactionModel(
        id: 't1',
        amountMinor: 600, // $6.00
        currency: AppCurrency.usd,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        title: 'Lunch',
        date: DateTime.now(),
        walletId: 'w1',
      );

      // Current balance in overview is 500 ($5.00).
      // Replaced amount in base is 600 ($6.00).
      // Available = 500 + 600 = 1100 ($11.00).
      final overview = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          WalletBalance(wallet: wallet, balanceMinor: 500),
        ],
        unassignedMinor: null,
        hasUnassigned: false,
        totalMinor: 500,
      );

      Widget buildApp() {
        return ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(
              () => TestWalletController([wallet]),
            ),
            transactionControllerProvider.overrideWith(
              () => TestTransactionController(
                [existingExpense],
                onAddTransaction: (tx) async {
                  updateCallCount++;
                },
              ),
            ),
            currencyControllerProvider.overrideWith(FakeCurrencyController.new),
            exchangeRatesBootstrapProvider.overrideWith((ref) async {}),
            exchangeRateServiceProvider.overrideWithValue(FakeRateService()),
            walletsOverviewProvider.overrideWithValue(AsyncData(overview)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddTransactionBottomSheet(
                      existingTransaction: existingExpense,
                    ),
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        );
      }

      // 1) Test above $11.00 ($12.00) -> fails
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '12.00');
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Edit Transaction');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(updateCallCount, 0);
      expect(find.text('Insufficient balance'), findsOneWidget);

      // 2) Test <= $11.00 ($10.00) -> passes
      await tester.enterText(find.byType(TextField).first, '10.00');
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(updateCallCount, 1);
      expect(find.byType(AddTransactionBottomSheet), findsNothing);
    });

    testWidgets(
        'wallet with balance 0 and no history allows expense under policy [A]',
        (tester) async {
      int addCallCount = 0;

      const noHistoryWallet = WalletModel(
        id: 'w_no_hist',
        name: 'New Wallet',
        icon: 'wallet',
        isDefault: true,
        type: WalletType.cash,
        openingBalanceMinor: null,
      );

      final overview = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          WalletBalance(wallet: noHistoryWallet, balanceMinor: 0),
        ],
        unassignedMinor: null,
        hasUnassigned: false,
        totalMinor: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(
              () => TestWalletController([noHistoryWallet]),
            ),
            transactionControllerProvider.overrideWith(
              () => TestTransactionController(
                [],
                onAddTransaction: (tx) async => addCallCount++,
              ),
            ),
            currencyControllerProvider.overrideWith(FakeCurrencyController.new),
            exchangeRatesBootstrapProvider.overrideWith((ref) async {}),
            exchangeRateServiceProvider.overrideWithValue(FakeRateService()),
            walletsOverviewProvider.overrideWithValue(AsyncData(overview)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddTransactionBottomSheet(),
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter amount 5.00
      await tester.enterText(find.byType(TextField).first, '5.00');
      await tester.pumpAndSettle();

      // Select category Food
      final categoryFinder = find.text('Food');
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Transaction');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(addCallCount, 1);
      expect(find.byType(AddTransactionBottomSheet), findsNothing);
    });
  });
}
