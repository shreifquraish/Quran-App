import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primaryDark = Color(0xFF0A2E24);
  static const primary = Color(0xFF1B5E4B);
  static const primaryLight = Color(0xFF2E7D62);
  static const accent = Color(0xFFD4AF37);
  static const accentSoft = Color(0xFFE8C872);
  static const surfaceDark = Color(0xFF0F1F1A);
  static const surface = Color(0xFF152821);
  static const card = Color(0xFF1E3A32);
  static const cardLight = Color(0xFFF5F0E6);
  static const textPrimary = Color(0xFFF5F0E6);
  static const textSecondary = Color(0xFFB8C9C0);
  static const textDark = Color(0xFF1A2E28);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      cardColor: AppColors.card,
      dividerColor: AppColors.primaryLight.withOpacity(0.2),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.amiri(
          fontSize: 36,
          height: 2.2,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withOpacity(0.35),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 26);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: GoogleFonts.cairo(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: GoogleFonts.cairo(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: AppColors.accent,
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardLight,
        onPrimary: Colors.white,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textDark,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF7F0),
      cardColor: Colors.white,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.amiri(
          fontSize: 36,
          height: 2.2,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static BoxDecoration gradientBackground({bool dark = true}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? [
                AppColors.primaryDark,
                AppColors.surfaceDark,
                const Color(0xFF0B1814),
              ]
            : [
                const Color(0xFFE8F5E9),
                const Color(0xFFFAF7F0),
                const Color(0xFFF5F0E6),
              ],
      ),
    );
  }

  static BoxDecoration cardDecoration({bool dark = true}) {
    return BoxDecoration(
      color: dark ? AppColors.card : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (dark ? AppColors.primaryLight : AppColors.primary)
            .withOpacity(0.15),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.25 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
