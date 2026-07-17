import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../permissions/permissions_service.dart';

/// A geographic point (maplibre-free, app-wide).
typedef LatLng = ({double lat, double lng});

/// Device location for the Map (003-map-screen R5). **Approximate** accuracy,
/// only-while-using (constitution §1.7); session-only, never persisted, never
/// sent off-device.
abstract class LocationService {
  /// One-shot current position, or null if permission denied, location
  /// services are off, or a fix can't be obtained. Never throws.
  Future<LatLng?> currentLatLng();
}

class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService(this._permissions);

  final PermissionsService _permissions;

  @override
  Future<LatLng?> currentLatLng() async {
    final granted = await _permissions.requestLocationWhenInUse();
    if (!granted) return null;
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.reduced,
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(ref.watch(permissionsServiceProvider)),
);

/// Resolves once on Map open. Null = denied/unavailable → Warsaw fallback.
final locationProvider = FutureProvider<LatLng?>(
  (ref) => ref.watch(locationServiceProvider).currentLatLng(),
);

/// Current user position (derived); null while loading or unavailable.
final userLatLngProvider = Provider<LatLng?>(
  (ref) => ref.watch(locationProvider).value,
);
