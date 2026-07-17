import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/home_notifier.dart';

/// Single-select category chip row. "Wszystko" plus one chip per category
/// present in the data; selecting filters the Featured row in place (FR-005/
/// FR-006). Mini-map is unaffected. Horizontal scroll, hidden scrollbar.
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(availableCategoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final notifier = ref.read(selectedCategoryProvider.notifier);

    final chips = <Widget>[
      _Chip(
        label: l10n.chipAll,
        active: selected == null,
        onTap: () => notifier.select(null),
      ),
      for (final c in categories)
        _Chip(
          label: c.label(l10n),
          glyph: c.glyph,
          tileColor: c.color,
          active: selected == c,
          onTap: () => notifier.select(c),
        ),
    ];

    return SizedBox(
      height: HmpSpacing.minTapTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: HmpSpacing.screenH,
        ),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Center(child: chips[i]),
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
    this.tileColor,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final String? glyph;
  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: active ? HmpColors.cocoa800 : const Color(0xD9FFFDF7),
          borderRadius: BorderRadius.circular(HmpRadii.tile - 1),
          border: Border.all(color: const Color(0x0F261713)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null && !active) ...[
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(glyph!, style: const TextStyle(fontSize: 10)),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w600,
                fontSize: HmpType.chip,
                color: active ? HmpColors.cream50 : HmpColors.cocoa800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
