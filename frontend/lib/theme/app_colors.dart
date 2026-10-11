import 'package:flutter/material.dart';

/// Professional education/government technology color palette
/// Designed for accessibility, trust, and clarity
class AppColors {
  // Primary - Professional Blue
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  
  // Secondary - Professional Teal
  static const Color secondary = Color(0xFF00796B);
  static const Color secondaryLight = Color(0xFF48A999);
  static const Color secondaryDark = Color(0xFF004C40);
  
  // Semantic Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color info = Color(0xFF0288D1);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  
  // Status Colors
  static const Color statusPresent = Color(0xFF2E7D32);
  static const Color statusAbsent = Color(0xFFD32F2F);
  static const Color statusCritical = Color(0xFFC62828);
  static const Color statusUnknown = Color(0xFF757575);
  
  // Method Colors
  static const Color methodFace = Color(0xFF1976D2);
  static const Color methodQR = Color(0xFF00796B);
  static const Color methodManual = Color(0xFF616161);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFF5F5F5);
  
  // Input Colors
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputFocusedBorder = Color(0xFF1976D2);
  static const Color inputErrorBorder = Color(0xFFD32F2F);
  
  // Divider Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFEEEEEE);
  
  // Shadow Colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0D000000);
}

/// Material 3 Color Scheme
class AppColorScheme {
  static ColorScheme get light => const ColorScheme(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryLight,
    error: AppColors.error,
    errorContainer: AppColors.errorLight,
    surface: AppColors.surface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    onSurface: AppColors.textPrimary,
    brightness: Brightness.light,
  );
  
  static ColorScheme get dark => const ColorScheme(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondaryLight,
    secondaryContainer: AppColors.secondaryDark,
    error: AppColors.errorLight,
    errorContainer: AppColors.error,
    surface: Color(0xFF121212),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onError: Colors.black,
    onSurface: Colors.white,
    brightness: Brightness.dark,
  );
}
