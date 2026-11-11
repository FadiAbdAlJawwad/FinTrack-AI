import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestWalletController extends WalletController {
  TestWalletController(this.initialWallets, {this.onUpdateWallet, this.onDeleteWallet});

  final List<WalletModel> initialWallets;
  final Future<void> Function(WalletModel wallet)? onUpdateWallet;
  final Future<void> Function(String id)? onDeleteWallet;

  @override
  Stream<List<WalletModel>> build() async* {
    yield initialWallets;
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    if (onUpdateWallet != null) {
      await onUpdateWallet!(wallet);
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    if (onDeleteWallet != null) {
      await onDeleteWallet!(id);
    }
  }
}

class TestTransactionController extends TransactionController {
  TestTransactionController(this.transactions);

  final List<TransactionModel> transactions;

  @override
  Stream<List<TransactionModel>> build() async* {
    yield transactions;
  }
}

Widget createTestApp({
  required List<WalletModel> wallets,
  List<TransactionModel> transactions = const [],
  Future<void> Function(WalletModel wallet)? onUpdateWallet,
  Future<void> Function(String id)? onDeleteWallet,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      walletControllerProvider.overrideWith(
        () => TestWalletController(
          wallets,
          onUpdateWallet: onUpdateWallet,
          onDeleteWallet: onDeleteWallet,
        ),
      ),
      transactionControllerProvider.overrideWith(
        () => TestTransactionController(transactions),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAddWalletSheet(context, wallet: wallets.isNotEmpty ? wallets.first : null),
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Wallet Edit Sheet', () {
    testWidgets('8. Tapping a wallet opens sheet in edit mode: title "Edit Wallet", name prefilled, icon selected', (tester) async {
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'savings');
      await tester.pumpWidget(createTestApp(wallets: [wallet]));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Wallet'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, 'My Wallet');

      final selectedIcon = tester.widget<Container>(
        find.descendant(of: find.byKey(const ValueKey('wallet_icon_savings')), matching: find.byType(Container)),
      );
      final decoration = selectedIcon.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('10. Seeded wallet in Arabic locale shows translated name; saving after changing icon stores ORIGINAL name', (tester) async {
      WalletModel? updatedWallet;
      final wallet = const WalletModel(id: 'cash', name: 'Cash', icon: 'payments');
      await tester.pumpWidget(createTestApp(
        wallets: [wallet],
        locale: const Locale('ar'),
        onUpdateWallet: (w) async { updatedWallet = w; },
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, 'نقدي'); // Arabic for Cash

      // Change icon
      await tester.tap(find.byKey(const ValueKey('wallet_icon_savings')));
      await tester.pumpAndSettle();

      // Tap save
      final saveBtn = find.widgetWithText(ElevatedButton, 'حفظ التغييرات');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(updatedWallet, isNotNull);
      expect(updatedWallet!.name, 'Cash'); // Original name
      expect(updatedWallet!.icon, 'savings');
    });

    testWidgets('11. Renaming a seeded wallet stores the new trimmed name', (tester) async {
      WalletModel? updatedWallet;
      final wallet = const WalletModel(id: 'w1', name: 'Old Name', icon: 'payments');
      await tester.pumpWidget(createTestApp(
        wallets: [wallet],
        onUpdateWallet: (w) async { updatedWallet = w; },
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, ' New Name ');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(updatedWallet!.name, 'New Name');
    });

    testWidgets('12. Edited wallets own name is not a duplicate; another wallets name is', (tester) async {
      final wallets = [
        const WalletModel(id: 'w1', name: 'Main Wallet', icon: 'payments'),
        const WalletModel(id: 'w2', name: 'Savings', icon: 'savings'),
      ];
      await tester.pumpWidget(createTestApp(wallets: wallets));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Test with own name (should be valid)
      await tester.enterText(find.byType(TextField).first, 'main wallet');
      await tester.pumpAndSettle();
      expect(find.text('A wallet with this name already exists.'), findsNothing);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed, isNotNull);

      // Test with other wallet's name
      await tester.enterText(find.byType(TextField).first, ' savings ');
      await tester.pumpAndSettle();
      expect(find.text('A wallet with this name already exists.'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed, isNull);
    });

    testWidgets('13. Save is disabled in edit mode until name or icon changes', (tester) async {
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'payments');
      await tester.pumpWidget(createTestApp(wallets: [wallet]));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // No changes yet
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed, isNull);

      // Change name
      await tester.enterText(find.byType(TextField).first, 'My Wallet 2');
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed, isNotNull);

      // Change back
      await tester.enterText(find.byType(TextField).first, 'My Wallet');
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed, isNull);

      // Change icon
      await tester.tap(find.byKey(const ValueKey('wallet_icon_savings')));
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed, isNotNull);
    });

    testWidgets('14. Save calls updateWallet once with the same id, new values, original isDefault', (tester) async {
      WalletModel? updatedWallet;
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'payments', isDefault: true);
      await tester.pumpWidget(createTestApp(
        wallets: [wallet],
        onUpdateWallet: (w) async { updatedWallet = w; },
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Wallet');
      await tester.tap(find.byKey(const ValueKey('wallet_icon_savings')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(updatedWallet, isNotNull);
      expect(updatedWallet!.id, 'w1');
      expect(updatedWallet!.name, 'Updated Wallet');
      expect(updatedWallet!.icon, 'savings');
      expect(updatedWallet!.isDefault, true);
    });

    testWidgets('15. Delete button hidden for default wallet, visible for non-default, absent in create mode', (tester) async {
      // Default Wallet
      await tester.pumpWidget(createTestApp(
        wallets: [const WalletModel(id: 'w1', name: 'Def', icon: 'payments', isDefault: true)],
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextButton, 'Delete Wallet'), findsNothing);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Non-Default Wallet
      await tester.pumpWidget(createTestApp(
        wallets: [const WalletModel(id: 'w2', name: 'NonDef', icon: 'payments', isDefault: false)],
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextButton, 'Delete Wallet'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Create Mode
      await tester.pumpWidget(createTestApp(wallets: []));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextButton, 'Delete Wallet'), findsNothing);
    });

    testWidgets('16. Delete with transactions shows walletHasTransactionsMessage and calls nothing', (tester) async {
      bool deleteCalled = false;
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'payments', isDefault: false);
      final transaction = TransactionModel(
        id: 't1',
        walletId: 'w1',
        amountMinor: 100,
        currency: AppCurrency.usd,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        title: 'Lunch',
        date: DateTime(2023, 1, 1),
      );
      await tester.pumpWidget(createTestApp(
        wallets: [wallet],
        transactions: [transaction],
        onDeleteWallet: (id) async { deleteCalled = true; },
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final dbBtn = find.widgetWithText(TextButton, 'Delete Wallet');
      await tester.ensureVisible(dbBtn);
      await tester.tap(dbBtn);
      await tester.pumpAndSettle();

      expect(deleteCalled, isFalse);
      expect(find.textContaining('This wallet has transactions in the last'), findsOneWidget);
      expect(find.byType(AddWalletSheet), findsOneWidget); // Sheet stays open
    });

    testWidgets('17. Delete without transactions shows confirmation dialog. Cancel calls nothing, Delete calls deleteWallet exactly once and closes sheet.', (tester) async {
      int deleteCallCount = 0;
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'payments', isDefault: false);
      await tester.pumpWidget(createTestApp(
        wallets: [wallet],
        transactions: [],
        onDeleteWallet: (id) async { deleteCallCount++; },
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Cancel
      final dbBtn = find.widgetWithText(TextButton, 'Delete Wallet');
      await tester.ensureVisible(dbBtn);
      await tester.tap(dbBtn);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(deleteCallCount, 0);
      expect(find.byType(AddWalletSheet), findsOneWidget);

      // Confirm Delete
      final dbBtn2 = find.widgetWithText(TextButton, 'Delete Wallet');
      await tester.ensureVisible(dbBtn2);
      await tester.tap(dbBtn2);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(deleteCallCount, 1);
      expect(find.byType(AddWalletSheet), findsNothing);
    });

    testWidgets('18. A failing delete shows an error SnackBar and keeps the sheet open', (tester) async {
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'payments', isDefault: false);
      await tester.pumpWidget(createTestApp(
        wallets: [wallet],
        onDeleteWallet: (id) async { throw WalletException(WalletErrorType.networkError); },
      ));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final dbBtn = find.widgetWithText(TextButton, 'Delete Wallet');
      await tester.ensureVisible(dbBtn);
      await tester.tap(dbBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(AddWalletSheet), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Network error. Please check your connection.'), findsOneWidget);
    });

    testWidgets('19. Redesign checks: no 0/50 counter, plain WALLET NAME Text, close icon pops sheet', (tester) async {
      final wallet = const WalletModel(id: 'w1', name: 'My Wallet', icon: 'payments', isDefault: false);
      await tester.pumpWidget(createTestApp(wallets: [wallet]));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('0/50'), findsNothing);
      expect(find.text('WALLET NAME'), findsOneWidget);

      // Check WALLET NAME is plain Text
      final texts = tester.widgetList<Text>(find.byType(Text)).map((e) => e.data).toList();
      expect(texts, contains('WALLET NAME'));

      // Check close icon pops sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(AddWalletSheet), findsNothing);
    });

    testWidgets('20. Icon tiles: tapping ValueKey(wallet_icon_savings) selects it (border primaryBlue)', (tester) async {
      await tester.pumpWidget(createTestApp(wallets: [])); // Create mode
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final savingsKey = const ValueKey('wallet_icon_savings');
      
      // Before tap: unselected
      final initialIcon = tester.widget<Container>(
        find.descendant(of: find.byKey(savingsKey), matching: find.byType(Container)),
      );
      expect((initialIcon.decoration as BoxDecoration).border, isNull);

      // Tap
      await tester.tap(find.byKey(savingsKey));
      await tester.pumpAndSettle();

      // After tap: selected
      final selectedIcon = tester.widget<Container>(
        find.descendant(of: find.byKey(savingsKey), matching: find.byType(Container)),
      );
      final border = (selectedIcon.decoration as BoxDecoration).border as Border;
      expect(border.top.color, ColorManager.primaryBlue);
    });

    testWidgets('21. Arabic locale renders the edit sheet with a long name without overflow exceptions', (tester) async {
      final wallet = const WalletModel(id: 'w1', name: 'This is a very long wallet name to test overflow', icon: 'payments', isDefault: false);
      await tester.pumpWidget(createTestApp(wallets: [wallet], locale: const Locale('ar')));
      
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle(); // Will throw an exception if there's an overflow during layout
      
      expect(tester.takeException(), isNull);
    });
  });
}
