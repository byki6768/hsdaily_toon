import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens — soft peach-rose journal mood.
abstract final class AppColors {
  static const Color ink = Color(0xFF2F2426);
  static const Color inkSoft = Color(0xFF6B5558);
  static const Color blush = Color(0xFFFFF1EC);
  static const Color blushDeep = Color(0xFFFFE0D6);
  static const Color petal = Color(0xFFE8A0A0);
  static const Color rose = Color(0xFFC45C6A);
  static const Color roseDeep = Color(0xFFA34452);
  static const Color mist = Color(0xFFF7E8E4);
  static const Color panel = Color(0xFFFFFBF9);
  static const Color line = Color(0xFFE8CFC8);
}

/// App-wide theme — warm, emotional "4컷 일기" atmosphere.
///
/// Base theme avoids blocking on remote font fetch; display accents may use
/// Google Fonts where available.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.rose,
      onPrimary: Colors.white,
      secondary: AppColors.petal,
      onSecondary: AppColors.ink,
      surface: AppColors.panel,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.blush,
    );

    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
        bodyColor: AppColors.inkSoft,
        displayColor: AppColors.ink,
      );
    } catch (_) {
      textTheme = base.textTheme.apply(
        bodyColor: AppColors.inkSoft,
        displayColor: AppColors.ink,
      );
    }

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rose,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.roseDeep,
          side: const BorderSide(color: AppColors.rose, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
      ),
    );
  }
}
