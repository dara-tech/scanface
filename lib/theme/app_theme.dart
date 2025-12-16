import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primary = Color(0xFF1A1A1A); // Near black
  static const Color _secondary = Color(0xFF666666); // Medium gray
  static const Color _accent = Color(0xFF0EA5E9); // Cyan accent
  static const Color _surfaceLight = Color(0xFFFAFAFA);
  static const Color _surfaceDark = Color(0xFF121212);

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme baseScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? _accent : _primary,
      secondary: _secondary,
      surface: isDark ? const Color(0xFF1A1A1A) : _surfaceLight,
      background: isDark ? _surfaceDark : Colors.white,
      tertiary: _accent,
      onSurface: isDark ? Colors.white : _primary,
      onBackground: isDark ? Colors.white : _primary,
    );

    // Try to load Hanuman font, fallback to system font if it fails
    TextTheme baseTextTheme;
    try {
      baseTextTheme = GoogleFonts.hanumanTextTheme();
    } catch (e) {
      // Fallback to default text theme if font loading fails
      baseTextTheme = Typography.material2021(platform: defaultTargetPlatform).black;
    }

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: baseScheme.background,
      textTheme: _brandTextTheme(baseTextTheme, brightness),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark
            ? Colors.transparent
            : baseScheme.background.withOpacity(0.9),
        foregroundColor: baseScheme.onBackground,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? _accent : _primary,
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.9) : baseScheme.onSurface.withOpacity(0.6),
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isDark ? _accent : _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _getButtonTextStyle(),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : _primary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
    );
  }

  static TextStyle _getButtonTextStyle() {
    try {
      return GoogleFonts.inter().copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.5,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
      );
    } catch (e) {
      return const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.5,
        fontFamilyFallback: ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
      );
    }
  }

  static TextTheme _brandTextTheme(TextTheme base, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    
    // Try to load Inter font, fallback to system font
    TextStyle display;
    try {
      display = GoogleFonts.inter().copyWith(
        fontWeight: FontWeight.w700,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      );
    } catch (e) {
      display = TextStyle(
        fontWeight: FontWeight.w700,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      );
    }

    return base.copyWith(
      headlineLarge: display.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.2,
        color: textColor,
      ),
      headlineMedium: display.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: textColor,
      ),
      headlineSmall: display.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: textColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        fontSize: 20,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        letterSpacing: 0.15,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.6,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.5,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
      bodySmall: base.bodySmall?.copyWith(
        height: 1.4,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontSize: 14,
        fontFamilyFallback: const ['Hanuman', 'Noto Sans Khmer', 'Khmer', 'sans-serif'],
        color: textColor,
      ),
    );
  }
}
