import 'package:flutter/material.dart';

/// Design tokens — see constitution-frontend.md §II.
/// Palette derived from the app icon's cocoa/umber/sand/parchment scheme.
abstract final class HmpColors {
  // Brand palette
  static const cocoa950 = Color(0xFF1A100E);
  static const cocoa900 = Color(0xFF261713);
  static const cocoa800 = Color(0xFF3B2622);
  static const cocoa700 = Color(0xFF4D3530);
  static const cocoa600 = Color(0xFF5D4039);
  static const umber600 = Color(0xFF7A5A3F);
  static const umber500 = Color(0xFF8D6C4D);
  static const sand400 = Color(0xFFD9C5A3);
  static const sand300 = Color(0xFFE6D6B6);
  static const sand200 = Color(0xFFECDFC4);
  static const cream100 = Color(0xFFF4EDE0);
  static const cream50 = Color(0xFFFAF5E9);
  static const parchment = Color(0xFFFBF8EF);
  static const ink = Color(0xFF1A100E);
  static const muted = Color(0xFF6A5147);

  // Functional accents
  static const verify = Color(0xFF5A7A55);
  static const warn = Color(0xFFB67437);
  static const pending = Color(0xFFB69247);
  static const closed = Color(0xFF9A4A3F);

  // Map category tints (share lightness — tonal family)
  static const catRest = Color(0xFF8A4A36);
  static const catMosque = Color(0xFF3F6B5A);
  static const catGroc = Color(0xFFB07A2A);
  static const catShop = Color(0xFF5B4A8A);
  static const catCem = Color(0xFF5A6473);

  // Map screen (003-map-screen). User-location dot + halo (constitution §2.4).
  static const userDot = Color(0xFF2A6FDB);
  static const userDotHalo = Color(0x292A6FDB); // ~16% alpha ring

  // Home screen background gradient (parchment → warm sand). See 002-home-screen R8.
  static const homeBgGradientStart = parchment; // #FBF8EF
  static const homeBgGradientEnd = Color(0xFFE9DDC3);

  const HmpColors._();
}

/// Synthetic mini-map basemap palette (002-home-screen R8; aligns with
/// constitution-frontend §2.4 light basemap intent).
abstract final class HmpMap {
  static const base = Color(0xFFECE1CB);
  static const block = Color(0xFFD4C08E);
  static const park = Color(0xFFB4C89A);
  static const river = Color(0xFFA8C2C5);
  static const road = Color(0xFFF6ECD5);

  const HmpMap._();
}

abstract final class HmpFonts {
  static const ui = 'PlusJakartaSans';
  static const display = 'Lora';
  static const arabic = 'Amiri';
  static const mono = 'JetBrainsMono';

  const HmpFonts._();
}

abstract final class HmpRadii {
  static const card = 22.0;
  static const cardCompact = 18.0;
  static const search = 18.0;
  static const button = 16.0;
  static const pill = 999.0;
  static const tile = 14.0;
  static const sheetTop = 24.0;
  static const iconSm = 12.0;

  const HmpRadii._();
}

abstract final class HmpSpacing {
  static const base = 4.0;
  static const screenH = 20.0;
  static const cardPad = 18.0;
  static const sectionGap = 20.0;
  static const tabBarH = 110.0;

  /// Vertical padding inside primary CTA buttons.
  static const buttonV = 14.0;

  /// Vertical padding around top/bottom screen chrome (skip link, language
  /// picker row).
  static const chromeV = 12.0;

  /// Minimum touch-target size (WCAG 2.1 AA hit area).
  static const minTapTarget = 44.0;

  const HmpSpacing._();
}

abstract final class HmpShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0A261713), offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x2E261713),
      offset: Offset(0, 12),
      blurRadius: 30,
      spreadRadius: -16,
    ),
  ];
  static const pop = <BoxShadow>[
    BoxShadow(
      color: Color(0x47261713),
      offset: Offset(0, 6),
      blurRadius: 22,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Color(0x59261713),
      offset: Offset(0, 30),
      blurRadius: 60,
      spreadRadius: -30,
    ),
  ];

  const HmpShadows._();
}

abstract final class HmpType {
  static const h1 = 32.0;
  static const h2 = 22.0;
  static const body = 17.0;
  static const meta = 15.0;
  static const tiny = 13.0;

  /// Oversized display number (e.g., Onboard 3 community stat "147").
  static const statDisplay = 56.0;

  // Home screen sizes (handoff "@1x mobile"; see 002-home-screen R8).
  static const homeH1 = 26.0; // Lora 500 H1 title
  static const homeH2 = 19.0; // Lora 500 section title
  static const cardTitle = 14.0; // place-card name
  static const chip = 13.0; // category chip label

  static const h1Tight = -0.01;
  static const h1Tightest = -0.015;
  static const kickerSpread = 0.18;

  const HmpType._();
}
