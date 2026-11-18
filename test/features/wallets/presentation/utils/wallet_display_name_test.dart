import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/presentation/utils/wallet_display_name.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('walletDisplayName', () {
    testWidgets('returns localized name for seeded wallets under en and ar', (
      tester,
    ) async {
      late AppLocalizations locEn;
      late AppLocalizations locAr;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              locEn = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              locAr = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      const cash = WalletModel(
        id: 'cash',
        name: 'Cash',
        icon: 'payments',
        isDefault: true,
      );
      const bank = WalletModel(
        id: 'bank',
        name: 'Bank Account',
        icon: 'account_balance',
      );
      const paypal = WalletModel(
        id: 'paypal',
        name: 'PayPal',
        icon: 'account_balance_wallet',
      );
      const other = WalletModel(id: 'other', name: 'Other', icon: 'more_horiz');

      expect(walletDisplayName(locEn, cash), 'Cash');
      expect(walletDisplayName(locAr, cash), 'نقدي');

      expect(walletDisplayName(locEn, bank), 'Bank Account');
      expect(walletDisplayName(locAr, bank), 'حساب بنكي');

      expect(walletDisplayName(locEn, paypal), 'PayPal');
      expect(walletDisplayName(locAr, paypal), 'PayPal');

      expect(walletDisplayName(locEn, other), 'Other');
      expect(walletDisplayName(locAr, other), 'أخرى');
    });

    testWidgets('returns stored name if seeded wallet was renamed', (
      tester,
    ) async {
      late AppLocalizations locAr;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              locAr = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      const renamedCash = WalletModel(
        id: 'cash',
        name: 'My Custom Cash',
        icon: 'payments',
      );
      expect(walletDisplayName(locAr, renamedCash), 'My Custom Cash');
    });

    testWidgets('returns stored name for non-seeded wallet id', (tester) async {
      late AppLocalizations locAr;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              locAr = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      const userWallet = WalletModel(
        id: 'custom_123',
        name: 'Investments',
        icon: 'savings',
      );
      expect(walletDisplayName(locAr, userWallet), 'Investments');
    });

    testWidgets(
      'legacy default with random id shows Arabic name, non-default Cash with random id is not localized, renamed default is unchanged',
      (tester) async {
        late AppLocalizations locAr;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                locAr = AppLocalizations.of(context);
                return const SizedBox();
              },
            ),
          ),
        );

        const legacyDefaultRandomId = WalletModel(
          id: 'random_xyz_999',
          name: 'Cash',
          icon: 'payments',
          isDefault: true,
        );
        expect(walletDisplayName(locAr, legacyDefaultRandomId), 'نقدي');

        const nonDefaultCashRandomId = WalletModel(
          id: 'random_abc_123',
          name: 'Cash',
          icon: 'payments',
          isDefault: false,
        );
        expect(walletDisplayName(locAr, nonDefaultCashRandomId), 'Cash');

        const renamedDefaultRandomId = WalletModel(
          id: 'random_xyz_999',
          name: 'My Custom Cash',
          icon: 'payments',
          isDefault: true,
        );
        expect(
          walletDisplayName(locAr, renamedDefaultRandomId),
          'My Custom Cash',
        );
      },
    );
  });
}
