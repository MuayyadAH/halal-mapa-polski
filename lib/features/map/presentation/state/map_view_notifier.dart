import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sort.dart';

/// Which view of the Map tab is showing (003-map-screen FR-021).
enum MapViewMode { map, list }

class MapViewModeNotifier extends Notifier<MapViewMode> {
  @override
  MapViewMode build() => MapViewMode.map;

  void show(MapViewMode mode) => state = mode;
  void toggle() =>
      state = state == MapViewMode.map ? MapViewMode.list : MapViewMode.map;
}

final mapViewProvider =
    NotifierProvider<MapViewModeNotifier, MapViewMode>(MapViewModeNotifier.new);

/// Lista sort mode (003-map-screen FR-020). Default `nearest` — which
/// `comparatorFor` degrades to alphabetical when there is no user location, so
/// the default is safe with or without a fix.
class SortModeNotifier extends Notifier<SortMode> {
  @override
  SortMode build() => SortMode.nearest;

  void set(SortMode mode) => state = mode;
}

final sortModeProvider =
    NotifierProvider<SortModeNotifier, SortMode>(SortModeNotifier.new);
