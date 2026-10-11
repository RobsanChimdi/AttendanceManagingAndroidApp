import 'package:flutter/material.dart';

/// Professional spacing system for consistent layouts
/// Based on 4px base unit
class AppSpacing {
  // Base unit
  static const double unit = 4.0;
  
  // Spacing scale
  static const double xs = unit;          // 4px
  static const double sm = unit * 2;      // 8px
  static const double md = unit * 3;      // 12px
  static const double lg = unit * 4;      // 16px
  static const double xl = unit * 6;      // 24px
  static const double xxl = unit * 8;     // 32px
  static const double xxxl = unit * 12;   // 48px
  
  // Component-specific spacing
  static const double cardPadding = lg;
  static const double sectionSpacing = xl;
  static const double itemSpacing = md;
  static const double iconSpacing = sm;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  
  // Border radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 999.0;
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;
  static const double elevationXl = 8.0;
}
