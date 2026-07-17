import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Presentation mapping for a [Category]: brand color, glyph, and localized
/// label. Kept out of the core enum so the domain stays UI-free.
///
/// Promoted to `lib/core/places/presentation/` by 003-map-screen so the Map's
/// pins/cards/rows reuse the exact colour/glyph/label mapping Home uses
/// (no duplication, no feature→feature import).
extension CategoryStyle on Category {
  Color get color => switch (this) {
        Category.restaurant => HmpColors.catRest,
        Category.masjid => HmpColors.catMosque,
        Category.grocer => HmpColors.catGroc,
        Category.butcher => HmpColors.catRest,
        Category.shop => HmpColors.catShop,
        Category.cemetery => HmpColors.catCem,
      };

  /// Emoji glyph used on chips, badges, and map pins (handoff §4.3/§4.4).
  String get glyph => switch (this) {
        Category.restaurant => '🍴',
        Category.masjid => '🕌',
        Category.grocer => '🛒',
        Category.butcher => '🥩',
        Category.shop => '🛍',
        Category.cemetery => '✦',
      };

  String label(AppLocalizations l10n) => switch (this) {
        Category.restaurant => l10n.chipRestaurant,
        Category.masjid => l10n.chipMasjid,
        Category.grocer => l10n.chipGrocer,
        Category.butcher => l10n.chipButcher,
        Category.shop => l10n.chipShop,
        Category.cemetery => l10n.chipCemetery,
      };
}
