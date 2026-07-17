import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

/// Lista / sheet ordering (003-map-screen FR-020). `nearest` needs the user
/// location (hidden in the UI otherwise); `openNow` is intentionally absent
/// (no opening-hours data).
enum SortMode { nearest, alphabetical, category }

int _byName(Place a, Place b) =>
    a.name.toLowerCase().compareTo(b.name.toLowerCase());

/// A comparator for [mode]. `nearest` falls back to alphabetical when [user]
/// is null; ties always break alphabetically for a stable order.
int Function(Place, Place) comparatorFor(SortMode mode, {LatLng? user}) {
  switch (mode) {
    case SortMode.nearest:
      if (user == null) return _byName;
      return (a, b) {
        final da = distanceMeters(user.lat, user.lng, a.lat, a.lng);
        final db = distanceMeters(user.lat, user.lng, b.lat, b.lng);
        final c = da.compareTo(db);
        return c != 0 ? c : _byName(a, b);
      };
    case SortMode.alphabetical:
      return _byName;
    case SortMode.category:
      return (a, b) {
        final c = a.category.index.compareTo(b.category.index);
        return c != 0 ? c : _byName(a, b);
      };
  }
}
