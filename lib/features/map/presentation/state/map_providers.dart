import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/cluster.dart';
import 'package:halal_map_polskie/core/map/map_config.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

import 'map_filter_notifier.dart';
import 'map_view_notifier.dart';
import 'sort.dart';

/// Resolved custom warm style JSON (with the MapTiler key injected), keyed by
/// brightness. Overridden in widget tests to avoid asset loading.
final mapStyleProvider = FutureProvider.family<String, bool>(
  (ref, isDark) => MapConfig.loadStyle(isDark: isDark),
);

/// Places shown on the map: all loaded places intersected with the active
/// category filter (empty filter = all). Feeds the pin/cluster layer + the
/// sheet/list. Empty while loading/error. (003-map-screen FR-011)
final categoryFilteredProvider = Provider<List<Place>>((ref) {
  final places = ref.watch(placesProvider).value ?? const <Place>[];
  final active = ref.watch(activeCategoriesProvider);
  if (active.isEmpty) return places;
  return places
      .where((Place p) => active.contains(p.category))
      .toList(growable: false);
});

/// Current map zoom, updated by [MapView] on camera idle. Drives clustering.
class MapZoom extends Notifier<double> {
  @override
  double build() => kDefaultZoom;
  void set(double zoom) => state = zoom;
}

final mapZoomProvider = NotifierProvider<MapZoom, double>(MapZoom.new);

/// The overlay items (single pins + clusters) for the current zoom (R4).
final clusterLayerProvider = Provider<List<MapItem>>((ref) {
  final places = ref.watch(categoryFilteredProvider);
  final zoom = ref.watch(mapZoomProvider);
  return clusterPlaces(places, zoom);
});

/// Places for the bottom sheet + Lista: category-filtered, then ordered by the
/// active [sortModeProvider] (`nearest` degrades to alphabetical without a
/// location). The Lista view applies its inline text filter on top of this.
/// (003-map-screen FR-007/FR-015/FR-020)
final visiblePlacesProvider = Provider<List<Place>>((ref) {
  final places = [...ref.watch(categoryFilteredProvider)];
  final user = ref.watch(userLatLngProvider);
  final mode = ref.watch(sortModeProvider);
  places.sort(comparatorFor(mode, user: user));
  return places;
});

/// Distance in metres from the user to [place], or null when no location
/// (003-map-screen FR-009). The widget layer formats it locale-aware.
final distanceMetersForProvider = Provider.family<double?, Place>((ref, place) {
  final user = ref.watch(userLatLngProvider);
  if (user == null) return null;
  return distanceMeters(user.lat, user.lng, place.lat, place.lng);
});
