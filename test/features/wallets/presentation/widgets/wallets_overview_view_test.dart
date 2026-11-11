import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallets_overview.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/features/wallets/presentation/widgets/add_wallet_sheet.dart';
import 'package:fin_track_ai/features/wallets/presentation/widgets/wallets_overview_view.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestWalletController extends WalletController {
  TestWalletController(this.initialWallets);

  final List<WalletModel> initialWallets;

  @override
  Stream<List<WalletModel>> build() async* {
    yield initialWallets;
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
  required WalletsOverview overview,
  List<WalletModel> wallets = const [],
  List<TransactionModel> transactions = const [],
}) {
  return ProviderScope(
    overrides: [
      walletControllerProvider.overrideWith(
        () => TestWalletController(wallets),
      ),
      transactionControllerProvider.overrideWith(
        () => TestTransactionController(transactions),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WalletsOverviewView(overview: overview),
      ),
    ),
  );
}

void main() {
  group('WalletsOverviewView', () {
    testWidgets('9. Tapping a wallet tile opens sheet in EDIT mode (title Edit Wallet, name prefilled)', (tester) async {
      final wallet = const WalletModel(id: 'w1', name: 'Main Checking', icon: 'payments');
      final overview = WalletsOverview(
        totalMinor: 1000,
        currency: AppCurrency.usd,
        wallets: [WalletBalance(wallet: wallet, balanceMinor: 1000)],
        unassignedMinor: 0,
        hasUnassigned: false,
      );

      await tester.pumpWidget(createTestApp(
        overview: overview,
        wallets: [wallet],
      ));

      await tester.tap(find.text('Main Checking'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Wallet'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, equals('Main Checking'));
    });

    testWidgets('10. The unassigned tile is not tappable: ListTile has onTap == null, tapping opens nothing', (tester) async {
      final overview = const WalletsOverview(
        totalMinor: 500,
        currency: AppCurrency.usd,
        wallets: [],
        unassignedMinor: 500,
        hasUnassigned: true,
      );

      await tester.pumpWidget(createTestApp(overview: overview));

      final unassignedTileFinder = find.widgetWithText(ListTile, 'Unassigned transactions');
      expect(unassignedTileFinder, findsOneWidget);

      final tileWidget = tester.widget<ListTile>(unassignedTileFinder);
      expect(tileWidget.onTap, isNull);

      await tester.tap(unassignedTileFinder);
      await tester.pumpAndSettle();

      expect(find.byType(AddWalletSheet), findsNothing);
    });

    testWidgets('11. Tapping second of two wallets opens sheet prefilled with THAT wallet name', (tester) async {
      final wallet1 = const WalletModel(id: 'w1', name: 'Wallet One', icon: 'payments');
      final wallet2 = const WalletModel(id: 'w2', name: 'Wallet Two', icon: 'savings');
      final overview = WalletsOverview(
        totalMinor: 3000,
        currency: AppCurrency.usd,
        wallets: [
          WalletBalance(wallet: wallet1, balanceMinor: 1000),
          WalletBalance(wallet: wallet2, balanceMinor: 2000),
        ],
        unassignedMinor: 0,
        hasUnassigned: false,
      );

      await tester.pumpWidget(createTestApp(
        overview: overview,
        wallets: [wallet1, wallet2],
      ));

      await tester.tap(find.text('Wallet Two'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Wallet'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, equals('Wallet Two'));
    });
  });
}
