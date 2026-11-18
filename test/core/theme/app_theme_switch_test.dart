import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('3. switchTheme.thumbColor!.resolve({WidgetState.selected}) equals ColorManager.white for both light and dark themes', () {
    final lightTheme = AppTheme.lightTheme('en');
    final darkTheme = AppTheme.darkTheme('en');

    expect(
      lightTheme.switchTheme.thumbColor!.resolve({WidgetState.selected}),
      ColorManager.white,
    );
    expect(
      darkTheme.switchTheme.thumbColor!.resolve({WidgetState.selected}),
      ColorManager.white,
    );
  });

  test('4. switchTheme.thumbColor!.resolve({}) is null for both light and dark themes', () {
    final lightTheme = AppTheme.lightTheme('en');
    final darkTheme = AppTheme.darkTheme('en');

    expect(lightTheme.switchTheme.thumbColor!.resolve({}), isNull);
    expect(darkTheme.switchTheme.thumbColor!.resolve({}), isNull);
  });
}
