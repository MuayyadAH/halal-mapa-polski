import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';

import 'presentation/state/map_providers.dart';
import 'presentation/state/map_search_notifier.dart';
import 'presentation/state/map_selection_notifier.dart';
import 'presentation/state/map_view_notifier.dart';
import 'presentation/widgets/filter_sheet.dart';
import 'presentation/widgets/list_view_body.dart';
import 'presentation/widgets/locate_me_fab.dart';
import 'presentation/widgets/map_category_chips.dart';
import 'presentation/widgets/map_empty_error.dart';
import 'presentation/widgets/map_search_bar.dart';
import 'presentation/widgets/map_search_overlay.dart';
import 'presentation/widgets/map_view.dart';
import 'presentation/widgets/place_sheet.dart';
import 'presentation/widgets/sort_pill.dart';
import 'presentation/widgets/view_toggle.dart';

/// The Mapa tab (003-map-screen). Renders full-bleed inside the existing 5-tab
/// shell — no own dock (FR-001). Composes the basemap + markers, the bottom
/// sheet, the Lista view, and the shared top chrome (search bar, Map/Lista
/// toggle, category chips / sort), cross-fading between the two views.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const Duration _crossFade = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styleAsync = ref.watch(mapStyleProvider(isDark));
    final placesAsync = ref.watch(placesProvider);
    final isList = ref.watch(mapViewProvider) == MapViewMode.list;
    final searchActive = ref.watch(mapSearchActiveProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final crossFade = reduceMotion ? Duration.zero : _crossFade;

    return Scaffold(
      body: styleAsync.when(
        loading: () => const ColoredBox(color: HmpColors.parchment),
        error: (_, __) => const ColoredBox(color: HmpColors.parchment),
        data: (style) {
          final hasNoData =
              placesAsync.hasError && (placesAsync.value?.isEmpty ?? true);
          return Stack(
            children: [
              // Map content — kept mounted (preserves the native map) and
              // cross-faded with the list.
              AnimatedOpacity(
                opacity: isList ? 0 : 1,
                duration: crossFade,
                child: IgnorePointer(
                  ignoring: isList,
                  child: Stack(
                    children: [
                      MapView(
                        initialLat: kWarsawLat,
                        initialLng: kWarsawLng,
                        initialZoom: kDefaultZoom,
                        styleJson: style,
                        onPinTap: (place) => ref
                            .read(selectedPlaceIdProvider.notifier)
                            .select(place.id),
                        onMapTap: () => ref
                            .read(selectedPlaceIdProvider.notifier)
                            .select(null),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 226,
                        child: LocateMeFab(onTap: () => _locateMe(ref)),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: PlaceSheet(
                          onShowList: () => ref
                              .read(mapViewProvider.notifier)
                              .show(MapViewMode.list),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista content.
              AnimatedOpacity(
                opacity: isList ? 1 : 0,
                duration: crossFade,
                child: IgnorePointer(
                  ignoring: !isList,
                  child: const ListViewBody(),
                ),
              ),

              if (placesAsync.isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    color: HmpColors.cocoa800,
                    backgroundColor: Colors.transparent,
                  ),
                ),

              if (hasNoData)
                Positioned.fill(
                  child: ColoredBox(
                    color: HmpColors.parchment,
                    child: MapEmptyError(
                      onRetry: () => ref.invalidate(placesProvider),
                    ),
                  ),
                ),

              // Shared top chrome (both views).
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Column(
                      children: [
                        MapSearchBar(
                          isListView: isList,
                          onOpenSearch: () =>
                              ref.read(mapSearchActiveProvider.notifier).open(),
                          onOpenFilter: () => showMapFilterSheet(context),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const ViewToggle(),
                            const SizedBox(width: 8),
                            Expanded(
                              child: isList
                                  ? const Align(
                                      alignment: Alignment.centerRight,
                                      child: SortPill(),
                                    )
                                  : const MapCategoryChips(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Map search overlay.
              if (searchActive && !isList)
                const Positioned.fill(child: MapSearchOverlay()),
            ],
          );
        },
      ),
    );
  }

  void _locateMe(WidgetRef ref) {
    final user = ref.read(userLatLngProvider);
    if (user != null) {
      ref.read(mapEngineProvider).recenterOn(lat: user.lat, lng: user.lng);
    } else {
      ref.invalidate(locationProvider);
    }
  }
}
