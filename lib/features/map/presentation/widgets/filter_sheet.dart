import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../state/map_filter_notifier.dart';

/// Opens the category filter sheet (design "Filter glyph"). Multi-selects the
/// shared `activeCategories` set; no "open now" toggle (no hours data). (FR-012)
Future<void> showMapFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: HmpColors.cream50,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => const FilterSheet(),
  );
}

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(availableCategoriesProvider);
    final active = ref.watch(activeCategoriesProvider);
    final notifier = ref.read(activeCategoriesProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.mapFiltersTitle,
                    style: const TextStyle(
                      fontFamily: HmpFonts.display,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: HmpColors.cocoa900,
                    ),
                  ),
                ),
                if (active.isNotEmpty)
                  TextButton(
                    onPressed: notifier.clear,
                    child: Text(
                      l10n.chipAll,
                      style: const TextStyle(
                        fontFamily: HmpFonts.ui,
                        fontWeight: FontWeight.w700,
                        color: HmpColors.umber600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  FilterChip(
                    selected: active.contains(c),
                    label: Text('${c.glyph}  ${c.label(l10n)}'),
                    onSelected: (_) => notifier.toggle(c),
                    showCheckmark: false,
                    backgroundColor: HmpColors.cream100,
                    selectedColor: c.color.withValues(alpha: 0.18),
                    labelStyle: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: HmpColors.cocoa800,
                    ),
                    shape: const StadiumBorder(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
