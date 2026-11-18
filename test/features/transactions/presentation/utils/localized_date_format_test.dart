import 'package:fin_track_ai/features/transactions/presentation/utils/localized_date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('en', null);
  });

  group('localized_date_format tests', () {
    test('1. toWesternDigits maps Arabic-Indic digits to 0123456789', () {
      expect(toWesternDigits('٠١٢٣٤٥٦٧٨٩'), equals('0123456789'));
    });

    test('2. toWesternDigits maps Persian digits and preserves Latin digits, letters, punctuation', () {
      expect(
        toWesternDigits('۰۱۲۳۴۵۶۷۸۹ ABC abc 123 !@#'),
        equals('0123456789 ABC abc 123 !@#'),
      );
    });

    testWidgets('3. English: formatLocalizedDate returns Oct 14, 03:30 PM', (
      tester,
    ) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: Builder(
            builder: (context) {
              result = formatLocalizedDate(
                context,
                'MMM dd, hh:mm a',
                DateTime(2026, 10, 14, 15, 30),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, equals('Oct 14, 03:30 PM'));
    });

    testWidgets(
      '4. Arabic: formatLocalizedDate contains October in Arabic, Latin digits, and no Arabic-Indic digits',
      (tester) async {
        late String result;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: Builder(
              builder: (context) {
                result = formatLocalizedDate(
                  context,
                  'MMM dd, hh:mm a',
                  DateTime(2026, 10, 14, 15, 30),
                );
                return const SizedBox();
              },
            ),
          ),
        );
        expect(result.contains('أكتوبر'), isTrue);
        expect(result.contains('14'), isTrue);
        expect(result.contains('03:30'), isTrue);
        for (final char in result.runes) {
          expect(char >= 0x0660 && char <= 0x0669, isFalse);
        }
      },
    );

    testWidgets(
      '5. With no Localizations ancestor it does not throw and equals English output',
      (tester) async {
        late String result;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                result = formatLocalizedDate(
                  context,
                  'MMM dd, hh:mm a',
                  DateTime(2026, 10, 14, 15, 30),
                );
                return const SizedBox();
              },
            ),
          ),
        );
        expect(result, equals('Oct 14, 03:30 PM'));
      },
    );

    testWidgets(
      '6. Arabic date output contains Arabic comma (U+060C) and no ASCII comma',
      (tester) async {
        late String result;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ar')],
            home: Builder(
              builder: (context) {
                result = formatLocalizedDate(
                  context,
                  'MMM dd, hh:mm a',
                  DateTime(2026, 10, 14, 15, 30),
                );
                return const SizedBox();
              },
            ),
          ),
        );
        expect(result.contains('،'), isTrue);
        expect(result.contains(','), isFalse);
      },
    );
  });
}
