import 'package:flutter/material.dart';

/// Professional color palette for Civil Construction Task Management App
class AppColors {
  // Primary Colors
  static const Color deepNavy = Color(0xFF0A192F); // Deep Navy - Primary
  static const Color constructionGold = Color(
    0xFFFFB400,
  ); // Construction Gold - Accent
  static const Color slateGrey = Color(0xFF475569); // Slate Grey - Secondary

  // Extended Palette
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color darkGrey = Color(0xFF1E293B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFF3B82F6);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityCritical = Color(0xFFEF4444);

  // Task Status Colors
  static const Color statusPending = Color(0xFF94A3B8);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusVerification = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  // Shadows
  static const shadowColor = Color(0x1A000000);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, Color(0xFF1E3A5F)],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [constructionGold, Color(0xFFFFD166)],
  );
}

/// Typography styles and sizes
class AppTypography {
  // Font sizes
  static const double fontSize8 = 8.0;
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;

  // Font weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Letter spacing
  static const double tightLetterSpacing = -0.5;
  static const double normalLetterSpacing = 0.0;
  static const double wideLetterSpacing = 0.5;
  static const double extraWideLetterSpacing = 1.0;

  // Line heights
  static const double tightLineHeight = 1.2;
  static const double normalLineHeight = 1.5;
  static const double relaxedLineHeight = 1.75;
  static const double looseLineHeight = 2.0;
}

/// Spacing and sizing constants
class AppSpacing {
  // Small
  static const double xs8 = 8.0;
  static const double sm12 = 12.0;
  static const double md16 = 16.0;

  // Medium
  static const double lg20 = 20.0;
  static const double xl24 = 24.0;

  // Large
  static const double xxl32 = 32.0;
  static const double xxxl40 = 40.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusCircle = 50.0;

  // Elevation/Shadow
  static const double elevationXs = 2.0;
  static const double elevationSm = 4.0;
  static const double elevationMd = 8.0;
  static const double elevationLg = 12.0;
  static const double elevationXl = 16.0;
}

/// Animation durations
class AppAnimations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration quick = Duration(milliseconds: 300);
  static const Duration normal = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1200);
}

/// Animation curves
class AppCurves {
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve snappy = Curves.fastOutSlowIn;
}

/// Break points for responsive design
class AppBreakpoints {
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 412;
  static const double tablet = 768;
  static const double web = 1024;
  static const double desktop = 1280;
  static const double ultraWide = 1920;
}
