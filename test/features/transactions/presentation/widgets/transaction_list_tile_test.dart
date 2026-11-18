import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _buildTestWidget({
  required TransactionModel transaction,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: TransactionListTile(transaction: transaction)),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('en', null);
  });

  final sampleDate = DateTime(2026, 10, 14, 15, 30);

  final expenseTx = TransactionModel(
    id: 'tx1',
    amountMinor: 500,
    currency: AppCurrency.usd,
    type: TransactionType.expense,
    category: TransactionCategory.food,
    title: 'Lunch',
    date: sampleDate,
    walletId: 'cash',
  );

  final incomeTx = TransactionModel(
    id: 'tx2',
    amountMinor: 500,
    currency: AppCurrency.usd,
    type: TransactionType.income,
    category: TransactionCategory.salary,
    title: 'Salary',
    date: sampleDate,
    walletId: 'cash',
  );

  group('TransactionListTile tests', () {
    testWidgets(
      '6. Expense and income amounts have textDirection == TextDirection.ltr',
      (tester) async {
        await tester.pumpWidget(_buildTestWidget(transaction: expenseTx));
        final expenseTextWidget = tester.widget<Text>(find.text('- \$5.00'));
        expect(expenseTextWidget.textDirection, equals(TextDirection.ltr));

        await tester.pumpWidget(_buildTestWidget(transaction: incomeTx));
        final incomeTextWidget = tester.widget<Text>(find.text('+ \$5.00'));
        expect(incomeTextWidget.textDirection, equals(TextDirection.ltr));
      },
    );

    testWidgets(
      '7. Arabic locale: date contains Arabic month and no Arabic-Indic digits; amount is unchanged',
      (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(transaction: expenseTx, locale: const Locale('ar')),
        );
        expect(find.text('- \$5.00'), findsOneWidget);

        final dateFinder = find.byWidgetPredicate((widget) {
          if (widget is Text) {
            final text = widget.data ?? '';
            return text.contains('أكتوبر');
          }
          return false;
        });
        expect(dateFinder, findsOneWidget);

        final dateText = (tester.widget(dateFinder) as Text).data!;
        for (final rune in dateText.runes) {
          expect(rune >= 0x0660 && rune <= 0x0669, isFalse);
        }
      },
    );

    testWidgets('8. English locale: date text equals Oct 14, 03:30 PM', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestWidget(transaction: expenseTx, locale: const Locale('en')),
      );
      expect(find.text('Oct 14, 03:30 PM'), findsOneWidget);
    });
  });
}
