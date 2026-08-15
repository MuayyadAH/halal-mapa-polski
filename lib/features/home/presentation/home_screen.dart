import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';

import 'state/home_notifier.dart';
import 'state/search_notifier.dart';
import 'widgets/category_chips.dart';
import 'widgets/home_error_state.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_skeletons.dart';
import 'widgets/mini_map.dart';
import 'widgets/place_card.dart';
import 'widgets/prayer_pill.dart';
import 'widgets/search_view.dart';
import 'widgets/section_header.dart';

/// The Strona (Home) screen — a vertical scroll inside the app's 5-tab shell.
/// Lean v1: header, search, category chips, live mini-map, and an auto-featured
/// place row. No own bottom dock (FR-001).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, EntranceController<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final count = ref.watch(totalPlaceCountProvider);
    final searchActive = ref.watch(searchActiveProvider);

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HmpColors.homeBgGradientStart,
              HmpColors.homeBgGradientEnd,
            ],
          ),
        ),
        child: searchActive
            ? const SearchView()
            : RefreshIndicator(
                onRefresh: () => ref.refresh(placesProvider.future),
                color: HmpColors.cocoa800,
                backgroundColor: HmpColors.parchment,
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 104),
                    children: [
                      FadeRiseIn(
                        controller: entrance,
                        start: 0.0,
                        end: 0.40,
                        child: const HomeHeader(),
                      ),
                      const SizedBox(height: 18),
                      FadeRiseIn(
                        controller: entrance,
                        start: 0.08,
                        end: 0.50,
                        child: HomeSearchBar(
                          onTap: () =>
                              ref.read(searchActiveProvider.notifier).open(),
                        ),
                      ),
                      // The pill spaces itself (top padding) so nothing
                      // doubles up when it hides.
                      FadeRiseIn(
                        controller: entrance,
                        start: 0.10,
                        end: 0.52,
                        child: const PrayerPill(),
                      ),
                      const SizedBox(height: 18),
                      FadeRiseIn(
                        controller: entrance,
                        start: 0.12,
                        end: 0.55,
                        child: const CategoryChips(),
                      ),
                      const SizedBox(height: 20),
                      FadeRiseIn(
                        controller: entrance,
                        start: 0.18,
                        end: 0.62,
                        child: MiniMap(
                          placeCount: count,
                          onOpenMap: () => context.go('/map'),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeRiseIn(
                        controller: entrance,
                        start: 0.24,
                        end: 0.70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title:
                                  AppLocalizations.of(context).sectionFeatured,
                            ),
                            const SizedBox(height: 12),
                            const _FeaturedSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    // Check error before loading: Riverpod auto-retries a failed provider, so a
    // permanently-failing fetch stays isLoading==true with hasError==true.
    // Surface the error state (with manual retry) rather than an endless skeleton.
    if (places.hasError) {
      return HomeErrorState(onRetry: () => ref.invalidate(placesProvider));
    }
    if (places.isLoading) return const FeaturedSkeletonRow();
    final featured = ref.watch(featuredVisibleProvider);
    if (featured.isEmpty) return const HomeEmptyCategory();
    return SizedBox(
      height: 184,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: HmpSpacing.screenH,
        ),
        itemCount: featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => PlaceCard(place: featured[i]),
      ),
    );
  }
}
