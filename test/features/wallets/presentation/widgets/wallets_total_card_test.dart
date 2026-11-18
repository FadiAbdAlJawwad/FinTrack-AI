import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/currency/presentation/utils/money_format.dart';
import 'package:fin_track_ai/features/wallets/presentation/widgets/wallets_total_card.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletsTotalCard', () {
    testWidgets(
      'renders total amount Text with LTR textDirection in Arabic locale for negative amount',
      (tester) async {
        const totalMinor = -1200;
        const currency = AppCurrency.usd;
        final expectedAmountText = formatMoney(totalMinor, currency);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: const Scaffold(
              body: WalletsTotalCard(
                totalMinor: totalMinor,
                currency: currency,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final amountTextFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == expectedAmountText &&
              widget.textDirection == TextDirection.ltr,
        );

        expect(amountTextFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(amountTextFinder);
        expect(textWidget.data, equals(expectedAmountText));
        expect(textWidget.textDirection, equals(TextDirection.ltr));
      },
    );
  });
}
