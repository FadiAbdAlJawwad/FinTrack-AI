import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallets_overview.dart';
import 'package:fin_track_ai/features/wallets/presentation/screens/wallets_screen.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallets_overview_provider.dart';
import 'package:fin_track_ai/features/wallets/presentation/widgets/wallets_skeleton.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget createTestApp({
  required AsyncValue<WalletsOverview> overviewState,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      walletsOverviewProvider.overrideWith((ref) => overviewState),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const WalletsScreen(),
    ),
  );
}

void main() {
  group('WalletsScreen', () {
    testWidgets(
        '6. total card shows formatted total, wallet tile shows localized name and balance',
        (tester) async {
      final overview = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          const WalletBalance(
            wallet: WalletModel(
              id: 'cash',
              name: 'Cash',
              icon: 'payments',
              isDefault: true,
            ),
            balanceMinor: 15000, // $150.00
          ),
          const WalletBalance(
            wallet: WalletModel(
              id: 'custom_1',
              name: 'Crypto',
              icon: 'savings',
            ),
            balanceMinor: 5000, // $50.00
          ),
        ],
        unassignedMinor: 0,
        hasUnassigned: false,
        totalMinor: 20000, // $200.00
      );

      await tester
          .pumpWidget(createTestApp(overviewState: AsyncData(overview)));
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget); // Total card
      final cashTile = find.widgetWithText(ListTile, '\$150.00');
      expect(
        find.descendant(of: cashTile, matching: find.text('Cash')),
        findsOneWidget,
      );
      expect(find.text('\$150.00'), findsOneWidget);
      expect(find.text('Crypto'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
    });

    testWidgets(
        '7. negative balance uses errorColor, null balance and null total show em-dash',
        (tester) async {
      final overview = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          const WalletBalance(
            wallet: WalletModel(
              id: 'w1',
              name: 'Negative Wallet',
              icon: 'payments',
            ),
            balanceMinor: -3500, // -$35.00
          ),
          const WalletBalance(
            wallet: WalletModel(
              id: 'w2',
              name: 'Null Wallet',
              icon: 'savings',
            ),
            balanceMinor: null,
          ),
        ],
        unassignedMinor: 0,
        hasUnassigned: false,
        totalMinor: null,
      );

      await tester
          .pumpWidget(createTestApp(overviewState: AsyncData(overview)));
      await tester.pumpAndSettle();

      // Total card shows '—', null balance shows '—'
      expect(find.text('—'), findsNWidgets(2));

      final negTextFinder = find.text('-\$35.00');
      expect(negTextFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(negTextFinder);
      expect(textWidget.style?.color, ColorManager.errorColor);
    });

    testWidgets('8. unassigned tile appears when hasUnassigned is true',
        (tester) async {
      final overviewWithUnassigned = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          const WalletBalance(
            wallet: WalletModel(id: 'cash', name: 'Cash', icon: 'payments'),
            balanceMinor: 1000,
          ),
        ],
        unassignedMinor: 500,
        hasUnassigned: true,
        totalMinor: 1500,
      );

      await tester.pumpWidget(
        createTestApp(overviewState: AsyncData(overviewWithUnassigned)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unassigned transactions'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget);
    });

    testWidgets('8b. unassigned tile appears when hasUnassigned is true and unassignedMinor is 0',
        (tester) async {
      final overviewWithUnassignedZero = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [],
        unassignedMinor: 0,
        hasUnassigned: true,
        totalMinor: 0,
      );

      await tester.pumpWidget(
        createTestApp(overviewState: AsyncData(overviewWithUnassignedZero)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unassigned transactions'), findsOneWidget);
      final unassignedTile = find.widgetWithText(ListTile, 'Unassigned transactions');
      expect(
        find.descendant(of: unassignedTile, matching: find.text('\$0.00')),
        findsOneWidget,
      );
    });

    testWidgets('9. empty overview shows walletsEmpty text when hasUnassigned is false', (tester) async {
      final overviewEmpty = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [],
        unassignedMinor: 0,
        hasUnassigned: false,
        totalMinor: 0,
      );

      await tester
          .pumpWidget(createTestApp(overviewState: AsyncData(overviewEmpty)));
      await tester.pumpAndSettle();

      expect(find.text('No wallets yet. Tap + to add one.'), findsOneWidget);
    });

    testWidgets('10. loading state shows WalletsSkeleton and no CircularProgressIndicator',
        (tester) async {
      await tester
          .pumpWidget(createTestApp(overviewState: const AsyncLoading()));
      await tester.pump();

      expect(find.byType(WalletsSkeleton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('10b. WalletsSkeleton renders in Arabic without overflow exceptions',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          overviewState: const AsyncLoading(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(find.byType(WalletsSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('11. error state shows error message', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          overviewState: AsyncError(
            WalletException(WalletErrorType.networkError),
            StackTrace.empty,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Network error. Please check your connection.'),
        findsOneWidget,
      );
    });

    testWidgets('12. window note shows "Balances cover the last 12 months"',
        (tester) async {
      final overview = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          const WalletBalance(
            wallet: WalletModel(id: 'cash', name: 'Cash', icon: 'payments'),
            balanceMinor: 1000,
          ),
        ],
        unassignedMinor: 0,
        hasUnassigned: false,
        totalMinor: 1000,
      );

      await tester
          .pumpWidget(createTestApp(overviewState: AsyncData(overview)));
      await tester.pumpAndSettle();

      expect(find.text('Balances cover the last 12 months'), findsOneWidget);
    });

    testWidgets(
        '13. Arabic locale renders screen with long wallet names without overflow',
        (tester) async {
      final overview = WalletsOverview(
        currency: AppCurrency.usd,
        wallets: [
          const WalletBalance(
            wallet: WalletModel(
              id: 'w_long',
              name: 'محفظة التوفير الطويلة جدا جدا جدا للاستثمار المستقبلي',
              icon: 'savings',
            ),
            balanceMinor: 99999900,
          ),
        ],
        unassignedMinor: 0,
        hasUnassigned: false,
        totalMinor: 99999900,
      );

      await tester.pumpWidget(
        createTestApp(
          overviewState: AsyncData(overview),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
