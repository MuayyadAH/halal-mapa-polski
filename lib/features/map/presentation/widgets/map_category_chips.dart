import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/map_filter_notifier.dart';

/// Horizontal, single-select category chip row (design "Category filter
/// chips"): "Wszystko" + a chip per category present. Chips are quick
/// shortcuts into the shared `activeCategories` set; when 2+ categories are
/// selected (via the filter sheet) no single chip is active. (FR-011)
class MapCategoryChips extends ConsumerWidget {
  const MapCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(availableCategoriesProvider);
    final active = ref.watch(activeCategoriesProvider);
    final single = active.length == 1 ? active.first : null;
    final notifier = ref.read(activeCategoriesProvider.notifier);

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: l10n.chipAll,
            active: active.isEmpty,
            onTap: notifier.clear,
          ),
          for (final c in categories) ...[
            const SizedBox(width: 8),
            _Chip(
              label: c.label(l10n),
              glyph: c.glyph,
              active: single == c,
              onTap: () => notifier.selectOnly(c),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.glyph,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final String? glyph;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? HmpColors.cocoa800 : const Color(0xF2FBF8EF),
          borderRadius: BorderRadius.circular(HmpRadii.pill),
          boxShadow: active ? null : HmpShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              Text(glyph!, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: active ? HmpColors.cream50 : HmpColors.cocoa800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
