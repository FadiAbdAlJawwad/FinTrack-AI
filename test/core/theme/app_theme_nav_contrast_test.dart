import 'dart:math' as math;

import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double relativeLuminance(Color color) {
  double channelLuminance(double normalized) {
    return normalized <= 0.03928
        ? normalized / 12.92
        : math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channelLuminance(color.r);
  final g = channelLuminance(color.g);
  final b = channelLuminance(color.b);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color color1, Color color2) {
  final l1 = relativeLuminance(color1);
  final l2 = relativeLuminance(color2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppTheme Navigation Bar Contrast', () {
    test('5. Light theme: inactive navigation label color has contrast >= 4.5 against lightSurface', () {
      final lightTheme = AppTheme.lightTheme('en');
      final navTheme = lightTheme.navigationBarTheme;
      final inactiveLabelStyle = navTheme.labelTextStyle?.resolve({});
      final inactiveLabelColor = inactiveLabelStyle?.color;

      expect(inactiveLabelColor, isNotNull);
      final ratio = contrastRatio(
        inactiveLabelColor!,
        ColorManager.lightSurface,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('6. Light theme: inactive navigation icon color has contrast >= 4.5 against lightSurface', () {
      final lightTheme = AppTheme.lightTheme('en');
      final navTheme = lightTheme.navigationBarTheme;
      final inactiveIconTheme = navTheme.iconTheme?.resolve({});
      final inactiveIconColor = inactiveIconTheme?.color;

      expect(inactiveIconColor, isNotNull);
      final ratio = contrastRatio(
        inactiveIconColor!,
        ColorManager.lightSurface,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('7. Dark theme: inactive label and icon colors are still ColorManager.secondaryColor', () {
      final darkTheme = AppTheme.darkTheme('en');
      final navTheme = darkTheme.navigationBarTheme;

      final inactiveLabelColor = navTheme.labelTextStyle?.resolve({})?.color;
      final inactiveIconColor = navTheme.iconTheme?.resolve({})?.color;

      expect(inactiveLabelColor, equals(ColorManager.secondaryColor));
      expect(inactiveIconColor, equals(ColorManager.secondaryColor));
    });

    test(
      '8. Both themes: SELECTED label/icon styles are unchanged in color',
      () {
        final selectedStates = {WidgetState.selected};

        for (final theme in [
          AppTheme.lightTheme('en'),
          AppTheme.darkTheme('en'),
        ]) {
          final navTheme = theme.navigationBarTheme;
          final selectedIconTheme = navTheme.iconTheme?.resolve(selectedStates);
          expect(selectedIconTheme?.color, equals(ColorManager.white));
          expect(navTheme.indicatorColor, equals(ColorManager.primaryBlue));
        }
      },
    );
  });
}
