import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// App theme — Material 3 light, "Sentinel Assurance" design tokens.
///
/// Public Sans for headlines (governmental, official feel).
/// Inter for body / labels (high legibility for analytical data).
class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme base) {
    final headline = GoogleFonts.publicSansTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);
    return base.copyWith(
      // Headlines / display — Public Sans, semi-bold.
      displayLarge: headline.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      ),
      headlineLarge: headline.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: headline.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: headline.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: headline.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // Title medium / body / label — Inter.
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.riskHigh,
      onError: Colors.white,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.publicSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.riskHigh, width: 2),
        ),
      ),
      // Pill-shaped primary actions per design system.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    const bgDark = Color(0xFF121214);
    const surfaceDark = Color(0xFF1E1E22);
    const textPrimaryDark = Color(0xFFE8E8EC);
    const textSecondaryDark = Color(0xFFA8A8B0);
    const borderDark = Color(0xFF333338);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7B8CFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF7B8CFF),
      onPrimary: const Color(0xFF000767),
      primaryContainer: const Color(0xFF1A237E),
      onPrimaryContainer: const Color(0xFFE0E0FF),
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      error: AppColors.riskHigh,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgDark,
      textTheme: _buildDarkTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: textSecondaryDark,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.riskHigh, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B8CFF),
          foregroundColor: Color(0xFF000767),
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7B8CFF),
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: borderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF7B8CFF),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme(TextTheme base) {
    const textPrimaryDark = Color(0xFFE8E8EC);
    const textSecondaryDark = Color(0xFFA8A8B0);
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: textPrimaryDark,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge?.copyWith(color: textPrimaryDark),
      headlineMedium: base.headlineMedium?.copyWith(color: textPrimaryDark),
      headlineSmall: base.headlineSmall?.copyWith(color: textPrimaryDark),
      titleLarge: base.titleLarge?.copyWith(color: textPrimaryDark),
      titleMedium: base.titleMedium?.copyWith(
        color: textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: textPrimaryDark),
      bodyMedium: base.bodyMedium?.copyWith(color: textPrimaryDark),
      bodySmall: base.bodySmall?.copyWith(color: textSecondaryDark),
      labelLarge: base.labelLarge?.copyWith(color: textPrimaryDark),
      labelMedium: base.labelMedium?.copyWith(color: textPrimaryDark),
      labelSmall: base.labelSmall?.copyWith(color: textSecondaryDark),
    );
  }
}
