import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  static const String fontFamily = 'Inter';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: AppColors.bgPrimary,
        secondary: AppColors.zinc200,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.bgPrimary,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 24 / 20,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 24 / 20,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 22 / 16,
          letterSpacing: -0.18,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 22 / 16,
          letterSpacing: -0.18,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 12 / 10,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 24 / 20,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFFFFFF),
        hoverColor: Color(0xFFFFFFFF),
        focusColor: Color(0xFFFFFFFF),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 24 / 20,
        ),
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
    );
  }
}
