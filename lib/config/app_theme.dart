import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppTheme {
  /// Light theme for the application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.deepNavy,
      scaffoldBackgroundColor: AppColors.lightGrey,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.deepNavy,
        secondary: AppColors.constructionGold,
        tertiary: AppColors.slateGrey,
        surface: AppColors.white,
        error: AppColors.errorRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.deepNavy,
        onSurface: AppColors.deepNavy,
        onError: AppColors.white,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepNavy,
        foregroundColor: AppColors.white,
        elevation: AppSpacing.elevationMd,
        centerTitle: false,
        titleTextStyle: _getTextStyle(
          fontSize: AppTypography.fontSize18,
          weight: AppTypography.bold,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),

      // Button themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.deepNavy,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md16,
            vertical: AppSpacing.sm12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _getTextStyle(
            fontSize: AppTypography.fontSize16,
            weight: AppTypography.semiBold,
          ),
          elevation: AppSpacing.elevationSm,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepNavy,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md16,
            vertical: AppSpacing.sm12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _getTextStyle(
            fontSize: AppTypography.fontSize16,
            weight: AppTypography.semiBold,
          ),
          elevation: AppSpacing.elevationMd,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepNavy,
          side: const BorderSide(color: AppColors.deepNavy, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md16,
            vertical: AppSpacing.sm12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _getTextStyle(
            fontSize: AppTypography.fontSize16,
            weight: AppTypography.semiBold,
          ),
        ),
      ),

      // TextField theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.slateGrey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightGrey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.deepNavy, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md16,
          vertical: AppSpacing.md16,
        ),
        labelStyle: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.medium,
          color: AppColors.slateGrey,
        ),
        hintStyle: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.regular,
          color: AppColors.slateGrey,
        ),
        errorStyle: _getTextStyle(
          fontSize: AppTypography.fontSize12,
          weight: AppTypography.regular,
          color: AppColors.errorRed,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: AppSpacing.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.md16),
      ),

      // Text themes
      textTheme: TextTheme(
        displayLarge: _getTextStyle(
          fontSize: AppTypography.fontSize32,
          weight: AppTypography.bold,
          color: AppColors.deepNavy,
        ),
        displayMedium: _getTextStyle(
          fontSize: AppTypography.fontSize28,
          weight: AppTypography.bold,
          color: AppColors.deepNavy,
        ),
        displaySmall: _getTextStyle(
          fontSize: AppTypography.fontSize24,
          weight: AppTypography.bold,
          color: AppColors.deepNavy,
        ),
        headlineLarge: _getTextStyle(
          fontSize: AppTypography.fontSize24,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        headlineMedium: _getTextStyle(
          fontSize: AppTypography.fontSize20,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        headlineSmall: _getTextStyle(
          fontSize: AppTypography.fontSize18,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        titleLarge: _getTextStyle(
          fontSize: AppTypography.fontSize18,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        titleMedium: _getTextStyle(
          fontSize: AppTypography.fontSize16,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        titleSmall: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        bodyLarge: _getTextStyle(
          fontSize: AppTypography.fontSize16,
          weight: AppTypography.regular,
          color: AppColors.deepNavy,
        ),
        bodyMedium: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.regular,
          color: AppColors.slateGrey,
        ),
        bodySmall: _getTextStyle(
          fontSize: AppTypography.fontSize12,
          weight: AppTypography.regular,
          color: AppColors.slateGrey,
        ),
        labelLarge: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.semiBold,
          color: AppColors.deepNavy,
        ),
        labelMedium: _getTextStyle(
          fontSize: AppTypography.fontSize12,
          weight: AppTypography.semiBold,
          color: AppColors.slateGrey,
        ),
        labelSmall: _getTextStyle(
          fontSize: AppTypography.fontSize10,
          weight: AppTypography.semiBold,
          color: AppColors.slateGrey,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: AppColors.deepNavy, size: 24.0),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGrey,
        thickness: 1.0,
        space: AppSpacing.md16,
      ),

      // BottomNavigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.slateGrey,
        elevation: AppSpacing.elevationMd,
        type: BottomNavigationBarType.fixed,
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.constructionGold,
        foregroundColor: AppColors.deepNavy,
        elevation: AppSpacing.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGrey,
        selectedColor: AppColors.constructionGold,
        labelStyle: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.medium,
          color: AppColors.deepNavy,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepNavy,
        contentTextStyle: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.regular,
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: _getTextStyle(
          fontSize: AppTypography.fontSize20,
          weight: AppTypography.bold,
          color: AppColors.deepNavy,
        ),
        contentTextStyle: _getTextStyle(
          fontSize: AppTypography.fontSize14,
          weight: AppTypography.regular,
          color: AppColors.slateGrey,
        ),
      ),
    );
  }

  /// Dark theme for the application
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.deepNavy,
      scaffoldBackgroundColor: AppColors.darkGrey,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.constructionGold,
        secondary: AppColors.constructionGold,
        tertiary: AppColors.slateGrey,
        surface: AppColors.darkGrey,
        error: AppColors.errorRed,
        onPrimary: AppColors.deepNavy,
        onSecondary: AppColors.deepNavy,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepNavy,
        foregroundColor: AppColors.white,
        elevation: AppSpacing.elevationMd,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.slateGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.slateGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.constructionGold,
            width: 2.0,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: AppSpacing.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  /// Helper method to create consistent text styles
  static TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight weight,
    Color color = AppColors.deepNavy,
    double letterSpacing = 0.0,
    double lineHeight = 1.5,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: lineHeight,
      decoration: decoration,
      fontFamily: 'Inter', // Primary font
      package: null,
    );
  }
}
