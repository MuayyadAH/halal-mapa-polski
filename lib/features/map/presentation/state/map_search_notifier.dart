import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the map search overlay is showing (003-map-screen FR-016).
class MapSearchActive extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;
  void close() => state = false;
}

final mapSearchActiveProvider =
    NotifierProvider<MapSearchActive, bool>(MapSearchActive.new);

/// The live search/filter query. In the map view it drives the search overlay;
/// in the Lista view it filters rows inline (FR-017/FR-019).
class MapSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

final mapSearchQueryProvider =
    NotifierProvider<MapSearchQuery, String>(MapSearchQuery.new);
