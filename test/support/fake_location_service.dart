import 'package:halal_map_polskie/core/location/location_service.dart';

/// Scripted [LocationService] for tests: returns a fixed position, or null to
/// simulate denied / services-off / no-fix.
class FakeLocationService implements LocationService {
  FakeLocationService(this.result);

  final LatLng? result;

  @override
  Future<LatLng?> currentLatLng() async => result;
}
