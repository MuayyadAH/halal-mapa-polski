import 'dart:math' as math;

import 'package:halal_map_polskie/core/places/domain/place.dart';

/// A single item on the map overlay: either one place or a cluster of nearby
/// places (003-map-screen R4). Pure data — no Flutter/maplibre imports — so it
/// is unit-testable without a live map.
sealed class MapItem {
  const MapItem();
}

class SinglePlace extends MapItem {
  const SinglePlace(this.place);
  final Place place;
}

class PlaceCluster extends MapItem {
  const PlaceCluster({
    required this.lat,
    required this.lng,
    required this.members,
  });
  final double lat;
  final double lng;
  final List<Place> members;
  int get count => members.length;
}

/// Groups places that fall in the same grid cell at [zoom]. Higher zoom →
/// finer cells → fewer/no clusters; lower zoom → coarser cells → more grouping.
/// Pure and deterministic (bucket order follows first-seen insertion order).
List<MapItem> clusterPlaces(List<Place> places, double zoom) {
  if (places.isEmpty) return const [];
  // Cell size in degrees shrinks as zoom grows.
  final cell = 360.0 / math.pow(2, zoom + 3);
  final buckets = <String, List<Place>>{};
  for (final p in places) {
    final gx = (p.lng / cell).floor();
    final gy = (p.lat / cell).floor();
    (buckets['$gx:$gy'] ??= <Place>[]).add(p);
  }
  final out = <MapItem>[];
  for (final group in buckets.values) {
    if (group.length == 1) {
      out.add(SinglePlace(group.first));
    } else {
      final lat =
          group.map((p) => p.lat).reduce((a, b) => a + b) / group.length;
      final lng =
          group.map((p) => p.lng).reduce((a, b) => a + b) / group.length;
      out.add(PlaceCluster(lat: lat, lng: lng, members: group));
    }
  }
  return out;
}
