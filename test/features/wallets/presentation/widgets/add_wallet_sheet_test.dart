import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestWalletController extends WalletController {
  TestWalletController(this.initialWallets, {this.onAddWallet});

  final List<WalletModel> initialWallets;
  final Future<void> Function(WalletModel wallet)? onAddWallet;

  @override
  Stream<List<WalletModel>> build() async* {
    yield initialWallets;
  }

  @override
  Future<void> addWallet(WalletModel wallet) async {
    if (onAddWallet != null) {
      await onAddWallet!(wallet);
    }
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    // For test use, reuse onAddWallet if we don't need a separate callback
    if (onAddWallet != null) {
      await onAddWallet!(wallet);
    }
  }
}

class FakeCurrencyController extends CurrencyController {
  @override
  Stream<String> build() async* {
    yield 'USD';
  }
}

Widget createTestApp({
  required List<WalletModel> wallets,
  Future<void> Function(WalletModel wallet)? onAddWallet,
  WalletModel? walletToEdit,
}) {
  return ProviderScope(
    overrides: [
      walletControllerProvider.overrideWith(
        () => TestWalletController(wallets, onAddWallet: onAddWallet),
      ),
      currencyControllerProvider.overrideWith(FakeCurrencyController.new),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAddWalletSheet(context, wallet: walletToEdit),
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('AddWalletSheet', () {
    testWidgets(
        '14. Create button is disabled while name is empty or whitespace only',
        (tester) async {
      await tester.pumpWidget(createTestApp(wallets: []));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Create Wallet');
      expect(buttonFinder, findsOneWidget);

      final buttonWidgetInitial = tester.widget<ElevatedButton>(buttonFinder);
      expect(buttonWidgetInitial.onPressed, isNull);

      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.pumpAndSettle();

      final buttonWidgetWhitespace =
          tester.widget<ElevatedButton>(buttonFinder);
      expect(buttonWidgetWhitespace.onPressed, isNull);
    });

    testWidgets(
        '15. duplicate name (case-insensitive, trimmed) shows walletNameExists and keeps Create disabled',
        (tester) async {
      final existingWallets = [
        const WalletModel(
          id: 'cash',
          name: 'Cash',
          icon: 'payments',
          isDefault: true,
        ),
      ];

      await tester.pumpWidget(createTestApp(wallets: existingWallets));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '   cAsH  ');
      await tester.pumpAndSettle();

      expect(
        find.text('A wallet with this name already exists.'),
        findsOneWidget,
      );

      final buttonWidget = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Wallet'),
      );
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets(
        '16. valid name and icon calls addWallet once with trimmed name and closes sheet',
        (tester) async {
      WalletModel? addedWallet;
      int addCallCount = 0;

      await tester.pumpWidget(
        createTestApp(
          wallets: [],
          onAddWallet: (wallet) async {
            addCallCount++;
            addedWallet = wallet;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '  Vacation Fund  ');
      await tester.pumpAndSettle();

      // Tap 'savings' icon in the selector
      await tester.tap(find.byIcon(Icons.savings));
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(ElevatedButton, 'Create Wallet');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(addCallCount, 1);
      expect(addedWallet, isNotNull);
      expect(addedWallet!.name, 'Vacation Fund');
      expect(addedWallet!.icon, 'savings');
      expect(addedWallet!.isDefault, false);

      // Sheet is closed
      expect(find.byType(AddWalletSheet), findsNothing);
    });

    testWidgets('17. when addWallet throws, sheet stays open and error SnackBar is shown',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          wallets: [],
          onAddWallet: (wallet) async {
            throw WalletException(
              WalletErrorType.networkError,
              message: 'Network failed',
            );
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Emergency Fund');
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(ElevatedButton, 'Create Wallet');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Sheet stays open
      expect(find.byType(AddWalletSheet), findsOneWidget);

      // SnackBar shown with translated error message
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
        'add sheet saves the selected type',
        (tester) async {
      WalletModel? addedWallet;
      await tester.pumpWidget(
        createTestApp(
          wallets: [],
          onAddWallet: (wallet) async {
            addedWallet = wallet;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Bank');
      await tester.pumpAndSettle();

      // Tap 'Bank Account' chip
      await tester.tap(find.text('Bank Account'));
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(ElevatedButton, 'Create Wallet');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(addedWallet, isNotNull);
      expect(addedWallet!.type, WalletType.bank);
    });

    testWidgets(
        'edit sheet enables Save when only the type changes',
        (tester) async {
      final existingWallet = const WalletModel(
        id: '1',
        name: 'My Wallet',
        icon: 'payments',
        type: WalletType.cash,
        isDefault: false,
      );

      WalletModel? updatedWallet;
      await tester.pumpWidget(
        createTestApp(
          wallets: [existingWallet],
          walletToEdit: existingWallet,
          onAddWallet: (wallet) async {
            updatedWallet = wallet;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Changes');
      
      // Initially, nothing changed, so Save is disabled
      final buttonInitial = tester.widget<ElevatedButton>(saveButtonFinder);
      expect(buttonInitial.onPressed, isNull);

      // Tap 'E-Wallet' chip
      await tester.tap(find.text('E-Wallet'));
      await tester.pumpAndSettle();

      // Now Save should be enabled
      final buttonChanged = tester.widget<ElevatedButton>(saveButtonFinder);
      expect(buttonChanged.onPressed, isNotNull);

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(updatedWallet, isNotNull);
      expect(updatedWallet!.type, WalletType.eWallet);
      // Other fields should remain the same
      expect(updatedWallet!.name, 'My Wallet');
    });

    testWidgets(
        'add sheet saves 12.345 JOD as openingBalanceMinor 12345 with JOD',
        (tester) async {
      WalletModel? addedWallet;
      await tester.pumpWidget(
        createTestApp(
          wallets: [],
          onAddWallet: (wallet) async {
            addedWallet = wallet;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Bank');
      await tester.pumpAndSettle();

      // Enter balance
      await tester.enterText(find.byType(TextField).at(1), '12.345');
      await tester.pumpAndSettle();

      // Tap JOD chip
      final jodChip = find.text('JOD (JD)');
      await tester.ensureVisible(jodChip);
      await tester.tap(jodChip);
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(ElevatedButton, 'Create Wallet');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(addedWallet, isNotNull);
      expect(addedWallet!.openingBalanceMinor, 12345);
      expect(addedWallet!.openingBalanceCurrency, AppCurrency.jod);
    });

    testWidgets(
        'empty balance field saves nulls',
        (tester) async {
      WalletModel? addedWallet;
      await tester.pumpWidget(
        createTestApp(
          wallets: [],
          onAddWallet: (wallet) async {
            addedWallet = wallet;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Bank');
      await tester.pumpAndSettle();

      // Balance field is empty by default

      final createButton = find.widgetWithText(ElevatedButton, 'Create Wallet');
      await tester.ensureVisible(createButton);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(addedWallet, isNotNull);
      expect(addedWallet!.openingBalanceMinor, isNull);
      expect(addedWallet!.openingBalanceCurrency, isNull);
    });

    testWidgets(
        'invalid balance text keeps Save disabled',
        (tester) async {
      await tester.pumpWidget(createTestApp(wallets: []));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Bank');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), '12.345.67');
      await tester.pumpAndSettle();

      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Wallet'),
      );
      expect(createButton.onPressed, isNull);
    });

    testWidgets(
        'edit mode changing only the opening balance enables Save',
        (tester) async {
      const existingWallet = WalletModel(
        id: '1',
        name: 'Bank',
        icon: 'account_balance',
        isDefault: false,
        type: WalletType.bank,
        openingBalanceMinor: 1000,
        openingBalanceCurrency: AppCurrency.usd,
      );

      WalletModel? updatedWallet;
      await tester.pumpWidget(
        createTestApp(
          wallets: [existingWallet],
          walletToEdit: existingWallet,
          onAddWallet: (wallet) async {
            updatedWallet = wallet;
          },
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Changes');

      // Initially Save is disabled
      expect(tester.widget<ElevatedButton>(saveButtonFinder).onPressed, isNull);

      // Change balance
      await tester.enterText(find.byType(TextField).at(1), '20.00');
      await tester.pumpAndSettle();

      // Save is enabled
      expect(tester.widget<ElevatedButton>(saveButtonFinder).onPressed, isNotNull);

      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(updatedWallet, isNotNull);
      expect(updatedWallet!.openingBalanceMinor, 2000);
      expect(updatedWallet!.openingBalanceCurrency, AppCurrency.usd);
    });
  });
}
