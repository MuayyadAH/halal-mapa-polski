import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(brightness: Brightness.light);
  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? HmpColors.sand400 : HmpColors.cocoa800,
      onPrimary: isDark ? HmpColors.cocoa900 : HmpColors.cream50,
      secondary: HmpColors.umber600,
      onSecondary: HmpColors.cream50,
      surface: isDark ? HmpColors.cocoa950 : HmpColors.cream50,
      onSurface: isDark ? HmpColors.cream50 : HmpColors.cocoa900,
      error: HmpColors.closed,
      onError: HmpColors.cream50,
    );

    final ink = isDark ? HmpColors.cream50 : HmpColors.cocoa900;
    final body = isDark ? HmpColors.sand300 : HmpColors.cocoa700;
    final meta = isDark ? HmpColors.sand400 : HmpColors.muted;

    // Amiri fallback ensures Arabic glyphs render with a proper script font
    // even when the primary family (Lora / Plus Jakarta Sans) lacks coverage.
    const arabicFallback = <String>[HmpFonts.arabic];

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: HmpFonts.ui,
      fontFamilyFallback: arabicFallback,
      shadowColor: HmpColors.cocoa950,
      textTheme: TextTheme(
        displayMedium: TextStyle(
          fontFamily: HmpFonts.display,
          fontFamilyFallback: arabicFallback,
          fontSize: HmpType.h1,
          fontWeight: FontWeight.w500,
          letterSpacing: HmpType.h1Tightest,
          color: ink,
          height: 1.15,
        ),
        headlineSmall: TextStyle(
          fontFamily: HmpFonts.ui,
          fontFamilyFallback: arabicFallback,
          fontSize: HmpType.h2,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: HmpFonts.ui,
          fontFamilyFallback: arabicFallback,
          fontSize: HmpType.body,
          height: 1.4,
          color: body,
        ),
        bodyMedium: TextStyle(
          fontFamily: HmpFonts.ui,
          fontFamilyFallback: arabicFallback,
          fontSize: HmpType.meta,
          color: meta,
        ),
        labelSmall: TextStyle(
          fontFamily: HmpFonts.ui,
          fontFamilyFallback: arabicFallback,
          fontSize: HmpType.tiny,
          fontWeight: FontWeight.w600,
          letterSpacing: HmpType.kickerSpread,
          color: meta,
        ),
      ),
    );
  }

  const AppTheme._();
}
