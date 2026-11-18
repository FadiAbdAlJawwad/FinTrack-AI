import 'package:fin_track_ai/features/transactions/domain/transaction_limits.dart';
import 'package:fin_track_ai/features/transactions/presentation/widgets/transaction_metadata_row.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestWidget({
  required TextEditingController notesController,
  required DateTime selectedDate,
  required VoidCallback onDateTap,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: TransactionMetadataRow(
        selectedDate: selectedDate,
        notesController: notesController,
        onDateTap: onDateTap,
      ),
    ),
  );
}

void main() {
  group('TransactionMetadataRow notes length limit tests', () {
    testWidgets(
      'a) enterText of 150 "a" characters caps controller text to maxNoteLength',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestWidget(
            notesController: controller,
            selectedDate: DateTime(2025, 1, 1),
            onDateTap: () {},
          ),
        );

        final input150 = 'a' * 150;
        await tester.enterText(find.byType(TextField), input150);
        await tester.pump();

        expect(controller.text.length, equals(maxNoteLength));
      },
    );

    testWidgets(
      'b) enterText of (maxNoteLength + 5) copies of emoji "😀" caps to maxNoteLength graphemes with no broken graphemes',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestWidget(
            notesController: controller,
            selectedDate: DateTime(2025, 1, 1),
            onDateTap: () {},
          ),
        );

        final emojiInput = '😀' * (maxNoteLength + 5);
        await tester.enterText(find.byType(TextField), emojiInput);
        await tester.pump();

        expect(controller.text.characters.length, equals(maxNoteLength));

        for (final rune in controller.text.runes) {
          expect(rune, equals('😀'.runes.single));
        }
      },
    );

    testWidgets(
      'c) enterText of Arabic text longer than 100 characters is capped at maxNoteLength',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestWidget(
            notesController: controller,
            selectedDate: DateTime(2025, 1, 1),
            onDateTap: () {},
          ),
        );

        final arabicInput =
            'ملاحظات المعاملة المالية الخاصة بالشراء والبيع ' * 5;
        expect(arabicInput.characters.length, greaterThan(maxNoteLength));

        await tester.enterText(find.byType(TextField), arabicInput);
        await tester.pump();

        expect(controller.text.characters.length, equals(maxNoteLength));
      },
    );
  });
}
