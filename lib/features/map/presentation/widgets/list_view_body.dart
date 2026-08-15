import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:halal_map_polskie/core/routing/app_router.dart';
import 'package:halal_map_polskie/core/search/place_match.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';

import '../state/map_providers.dart';
import '../state/map_search_notifier.dart';
import '../state/map_view_notifier.dart';
import 'list_row.dart';

/// The Lista view (design "List view"): a scrollable list of all visible places
/// over the warm gradient, with the inline text filter applied on top of the
/// category filter + sort. Rows cascade in (fade-up stagger) each time the
/// Lista view is shown; "Brak wyników" when the filter matches nothing.
/// (FR-015/FR-019, ANIMATIONS.md §5)
class ListViewBody extends ConsumerStatefulWidget {
  const ListViewBody({super.key});

  @override
  ConsumerState<ListViewBody> createState() => _ListViewBodyState();
}

class _ListViewBodyState extends ConsumerState<ListViewBody>
    with TickerProviderStateMixin {
  // Window long enough for the header + a screenful of staggered rows.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _replay() {
    if (MediaQuery.of(context).disableAnimations) {
      _entrance.value = 1;
    } else {
      _entrance.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final places = ref.watch(visiblePlacesProvider);
    final query = ref.watch(mapSearchQueryProvider);
    final filtered = query.trim().isEmpty
        ? places
        : places
            .where((p) => matchesQuery(p, query, l10n))
            .toList(growable: false);

    // Replay the stagger whenever the Lista view becomes visible.
    ref.listen<MapViewMode>(mapViewProvider, (prev, next) {
      if (next == MapViewMode.list) _replay();
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HmpColors.parchment, HmpColors.homeBgGradientEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top padding clears the shared search bar + toggle/sort chrome.
            const SliverPadding(padding: EdgeInsets.only(top: 96)),
            SliverToBoxAdapter(
              child: FadeRiseIn(
                controller: _entrance,
                start: 0.15,
                end: 0.55,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mapAllPlacesTitle,
                        style: const TextStyle(
                          fontFamily: HmpFonts.display,
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: HmpColors.cocoa900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mapPlacesCount(filtered.length),
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 12,
                          color: HmpColors.cocoa700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      l10n.searchNoResults,
                      style: const TextStyle(
                        fontFamily: HmpFonts.ui,
                        fontSize: 15,
                        color: HmpColors.muted,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0x14261713),
                ),
                itemBuilder: (context, i) {
                  final place = filtered[i];
                  final start = (0.18 + i * 0.05).clamp(0.0, 0.7);
                  return FadeRiseIn(
                    controller: _entrance,
                    start: start,
                    end: (start + 0.3).clamp(0.0, 1.0),
                    child: ListRow(
                      place: place,
                      onTap: () => context.push(placeDetailLocation(place.id)),
                    ),
                  );
                },
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
