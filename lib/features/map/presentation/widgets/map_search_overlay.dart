import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/search/place_match.dart';
import 'package:halal_map_polskie/core/search/recent_searches.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/map_filter_notifier.dart';
import '../state/map_search_notifier.dart';
import '../state/map_selection_notifier.dart';

/// Full-screen map search overlay (design "Search functionality"): a focused
/// field with "Anuluj", over a parchment panel grouped Ostatnie / Podpowiedzi /
/// Kategorie. Matching is accent-insensitive across the full dataset (ignores
/// the active filter); selecting a result clears the filter if needed, selects
/// the pin, flies the camera, and closes. (FR-016/FR-017)
class MapSearchOverlay extends ConsumerStatefulWidget {
  const MapSearchOverlay({super.key});

  @override
  ConsumerState<MapSearchOverlay> createState() => _MapSearchOverlayState();
}

class _MapSearchOverlayState extends ConsumerState<MapSearchOverlay> {
  static const int _limit = 8;
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(mapSearchQueryProvider));
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    _focus.unfocus();
    ref.read(mapSearchQueryProvider.notifier).clear();
    ref.read(mapSearchActiveProvider.notifier).close();
  }

  void _selectPlace(Place place) {
    ref.read(recentSearchesProvider.notifier).add(_controller.text);
    // Make sure the pin is visible: if its category is filtered out, reset.
    final active = ref.read(activeCategoriesProvider);
    if (active.isNotEmpty && !active.contains(place.category)) {
      ref.read(activeCategoriesProvider.notifier).clear();
    }
    ref.read(selectedPlaceIdProvider.notifier).select(place.id);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    ref.read(mapEngineProvider).flyTo(
          lat: place.lat,
          lng: place.lng,
          zoom: 15,
          animate: !reduceMotion,
        );
    _close();
  }

  void _selectCategory(Category category) {
    ref.read(activeCategoriesProvider.notifier).selectOnly(category);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(mapSearchQueryProvider);
    final recents = ref.watch(recentSearchesProvider);
    final categories = ref.watch(availableCategoriesProvider);
    final allPlaces = ref.watch(placesProvider).value ?? const <Place>[];
    final matches = query.trim().isEmpty
        ? const <Place>[]
        : allPlaces
            .where((p) => matchesQuery(p, query, l10n))
            .take(_limit)
            .toList(growable: false);

    return ColoredBox(
      color: const Color(0xF7FBF8EF),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: _Field(
                controller: _controller,
                focusNode: _focus,
                onChanged: (v) =>
                    ref.read(mapSearchQueryProvider.notifier).set(v),
                onCancel: _close,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  if (query.trim().isEmpty && recents.isNotEmpty) ...[
                    _GroupLabel(l10n.searchGroupRecent),
                    for (final q in recents)
                      _RecentRow(
                        query: q,
                        onTap: () {
                          _controller.text = q;
                          ref.read(mapSearchQueryProvider.notifier).set(q);
                          _focus.requestFocus();
                        },
                      ),
                  ],
                  if (query.trim().isNotEmpty) ...[
                    _GroupLabel(l10n.searchGroupSuggestions),
                    if (matches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          l10n.searchNoResults,
                          style: const TextStyle(
                            fontFamily: HmpFonts.ui,
                            fontSize: 14,
                            color: HmpColors.muted,
                          ),
                        ),
                      )
                    else
                      for (final p in matches)
                        _ResultRow(place: p, onTap: () => _selectPlace(p)),
                  ],
                  _GroupLabel(l10n.searchGroupCategories),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in categories)
                        PressableScale(
                          onTap: () => _selectCategory(c),
                          semanticLabel: c.label(l10n),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x0D261713),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${c.glyph}  ${c.label(l10n)}',
                              style: const TextStyle(
                                fontFamily: HmpFonts.ui,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: HmpColors.cocoa900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HmpRadii.search),
        border: Border.all(color: HmpColors.cocoa800, width: 2),
        boxShadow: HmpShadows.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: HmpColors.cocoa800),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: HmpColors.cocoa800,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 15,
                color: HmpColors.cocoa900,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l10n.mapSearchHint,
                hintStyle: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 15,
                  color: HmpColors.muted,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              l10n.searchCancel,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: HmpColors.cocoa800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.4,
          color: HmpColors.umber600,
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.query, required this.onTap});
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.history, size: 18, color: HmpColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 14,
                  color: HmpColors.cocoa900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.place, required this.onTap});
  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PressableScale(
      onTap: onTap,
      semanticLabel: place.name,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: place.category.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                place.category.glyph,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: HmpColors.cocoa900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.category.label(l10n),
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: 11,
                      color: HmpColors.cocoa700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
