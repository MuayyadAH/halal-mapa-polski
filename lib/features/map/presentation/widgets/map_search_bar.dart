import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../state/map_search_notifier.dart';

/// Translucent top search bar (design "Top search bar"). In the map view it is
/// a tappable bar that opens the search overlay; in the Lista view it is an
/// inline filter field. Trailing filter glyph opens the filter sheet. (FR-016)
class MapSearchBar extends ConsumerWidget {
  const MapSearchBar({
    required this.isListView,
    required this.onOpenSearch,
    required this.onOpenFilter,
    super.key,
  });

  final bool isListView;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hint = isListView ? l10n.listFilterHint : l10n.mapSearchHint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xF5FBF8EF),
        borderRadius: BorderRadius.circular(HmpRadii.search),
        boxShadow: HmpShadows.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: HmpColors.cocoa800),
          const SizedBox(width: 10),
          Expanded(
            child: isListView
                ? TextField(
                    onChanged: (v) =>
                        ref.read(mapSearchQueryProvider.notifier).set(v),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: 15,
                      color: HmpColors.cocoa900,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontFamily: HmpFonts.ui,
                        fontSize: 15,
                        color: HmpColors.muted,
                      ),
                    ),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onOpenSearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        hint,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 15,
                          color: HmpColors.muted,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: l10n.mapFiltersTitle,
            child: GestureDetector(
              onTap: onOpenFilter,
              child:
                  const Icon(Icons.tune, size: 20, color: HmpColors.cocoa800),
            ),
          ),
        ],
      ),
    );
  }
}
