import 'package:flutter/material.dart';

import '../constant/color_manager.dart';

class AppTheme {
  // 1. Shape Tokens (Visual Estimation)
  static final BorderRadius _inputRadius = BorderRadius.circular(12.0);
  static final BorderRadius _cardRadius = BorderRadius.circular(16.0);

  // 2. Dynamic Typography
  static String _getFontFamily(String languageCode) {
    return languageCode == 'ar' ? 'Cairo' : 'Inter';
  }

  static TextTheme _buildTextTheme(String fontFamily, Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorManager.secondaryColor,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(
    TextTheme textTheme,
    Color background,
    Color inactiveColor,
  ) {
    return NavigationBarThemeData(
      backgroundColor: background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: ColorManager.primaryBlue,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: ColorManager.white, size: 24);
        }
        return IconThemeData(color: inactiveColor, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);
        }
        return textTheme.labelSmall?.copyWith(color: inactiveColor);
      }),
    );
  }

  static SwitchThemeData _switchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? ColorManager.white : null,
      ),
    );
  }

  // ------------------ Dark Theme ------------------
  static ThemeData darkTheme(String languageCode) {
    final textTheme = _buildTextTheme(
      _getFontFamily(languageCode),
      ColorManager.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _getFontFamily(languageCode),
      scaffoldBackgroundColor: ColorManager.darkBackground,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: ColorManager.primaryBlue,
        surface: ColorManager.darkSurface,
        onSurface: ColorManager.white,
        error: ColorManager.errorColor,
        outlineVariant: ColorManager.darkBorder,
      ),
      navigationBarTheme: _navigationBarTheme(
        textTheme,
        ColorManager.darkSurface,
        ColorManager.secondaryColor,
      ),
      switchTheme: _switchTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorManager.white),
        titleTextStyle: textTheme.titleSmall?.copyWith(fontSize: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColorManager.primaryBlue,
          foregroundColor: ColorManager.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 54),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 54),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorManager.darkSurface,
        labelStyle: textTheme.labelLarge,
        hintStyle: textTheme.bodyMedium?.copyWith(color: ColorManager.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(
            color: ColorManager.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: ColorManager.errorColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorManager.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: ColorManager.primaryBlue,
          textStyle: textTheme.labelLarge?.copyWith(
            color: ColorManager.secondaryButtonTextColor,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryBlue,
          foregroundColor: ColorManager.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 54),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }

  // ------------------ Light Theme ------------------
  static ThemeData lightTheme(String languageCode) {
    final textTheme = _buildTextTheme(
      _getFontFamily(languageCode),
      ColorManager.lightText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _getFontFamily(languageCode),
      scaffoldBackgroundColor: ColorManager.lightBackground,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: ColorManager.primaryBlue,
        secondary: ColorManager.lightSecondary,
        surface: ColorManager.lightSurface,
        onSurface: ColorManager.lightText,
        error: ColorManager.errorColor,
        outlineVariant: ColorManager.lightBorder,
      ),
      navigationBarTheme: _navigationBarTheme(
        textTheme,
        ColorManager.lightSurface,
        ColorManager.lightSecondary,
      ),
      switchTheme: _switchTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorManager.lightText),
        titleTextStyle: textTheme.titleSmall?.copyWith(fontSize: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColorManager.primaryBlue,
          foregroundColor: ColorManager.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 54),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 54),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        iconColor: ColorManager.secondaryColor,
        filled: true,
        fillColor: ColorManager.lightSurface,
        labelStyle: textTheme.labelLarge,
        suffixIconColor: ColorManager.secondaryColor,
        prefixIconColor: ColorManager.secondaryColor,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ColorManager.lightSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: ColorManager.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: ColorManager.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(
            color: ColorManager.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: ColorManager.errorColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorManager.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: ColorManager.primaryBlue,
          textStyle: textTheme.labelLarge?.copyWith(
            color: ColorManager.secondaryButtonTextColor,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryBlue,
          foregroundColor: ColorManager.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 54),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
}
