import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/core/widgets/app_chip_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppChipSelector', () {
    testWidgets('1. LTR: first chip left edge equals scroll area left edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppChipSelector<String>(
              items: const ['Chip 1', 'Chip 2'],
              isSelected: (item) => item == 'Chip 1',
              labelBuilder: (item) => item,
              onSelect: (_) {},
            ),
          ),
        ),
      );

      final scrollViewRect = tester.getRect(find.byType(SingleChildScrollView));
      final firstChipRect = tester.getRect(find.byType(ChoiceChip).first);

      expect(firstChipRect.left, equals(scrollViewRect.left));
    });

    testWidgets('2. RTL: first chip right edge equals scroll area right edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: AppChipSelector<String>(
                items: const ['Chip 1', 'Chip 2'],
                isSelected: (item) => item == 'Chip 1',
                labelBuilder: (item) => item,
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      );

      final scrollViewRect = tester.getRect(find.byType(SingleChildScrollView));
      final firstChipRect = tester.getRect(find.byType(ChoiceChip).first);

      expect(firstChipRect.right, equals(scrollViewRect.right));
    });

    testWidgets(
      '3. Gap between adjacent chips is 8 logical pixels in LTR and RTL',
      (tester) async {
        // LTR test
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppChipSelector<String>(
                items: const ['Chip 1', 'Chip 2'],
                isSelected: (item) => item == 'Chip 1',
                labelBuilder: (item) => item,
                onSelect: (_) {},
              ),
            ),
          ),
        );

        final chip1RectLTR = tester.getRect(find.byType(ChoiceChip).at(0));
        final chip2RectLTR = tester.getRect(find.byType(ChoiceChip).at(1));
        expect(chip2RectLTR.left - chip1RectLTR.right, equals(8.0));

        // RTL test
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: AppChipSelector<String>(
                  items: const ['Chip 1', 'Chip 2'],
                  isSelected: (item) => item == 'Chip 1',
                  labelBuilder: (item) => item,
                  onSelect: (_) {},
                ),
              ),
            ),
          ),
        );

        final chip1RectRTL = tester.getRect(find.byType(ChoiceChip).at(0));
        final chip2RectRTL = tester.getRect(find.byType(ChoiceChip).at(1));
        expect(chip1RectRTL.left - chip2RectRTL.right, equals(8.0));
      },
    );

    testWidgets('4. Selected chip label color equals ColorManager.white', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppChipSelector<String>(
              items: const ['Selected', 'Unselected'],
              isSelected: (item) => item == 'Selected',
              labelBuilder: (item) => item,
              onSelect: (_) {},
            ),
          ),
        ),
      );

      final choiceChip = tester.widget<ChoiceChip>(
        find.byType(ChoiceChip).first,
      );
      expect(choiceChip.labelStyle?.color, equals(ColorManager.white));
    });
  });
}
