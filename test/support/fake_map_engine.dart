import 'package:flutter/widgets.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/map/projection.dart';

/// Headless [MapEngine] for widget tests — renders a plain box and records
/// camera calls, so pin/overlay/selection logic can be tested without the
/// native MapLibre view (003-map-screen R15). Marker positions are computed by
/// the synchronous projector ([latLngToScreen]) from the initial camera.
class FakeMapEngine implements MapEngine {
  FakeMapEngine({double zoom = 12, this.bounds}) : _zoom = zoom;

  final flyToCalls = <({double lat, double lng, double? zoom})>[];
  final recenterCalls = <({double lat, double lng})>[];
  bool userLocationEnabled = false;
  GeoBounds? bounds;
  void Function(CameraSnapshot camera)? lastOnCameraChanged;
  void Function(double lat, double lng)? lastTapHandler;
  double _zoom;

  @override
  bool get isReady => true;

  @override
  Widget buildMap({
    required CameraTarget initialCamera,
    required String styleJson,
    required void Function(CameraSnapshot camera) onCameraChanged,
    void Function(double lat, double lng)? onTapMap,
  }) {
    lastOnCameraChanged = onCameraChanged;
    lastTapHandler = onTapMap;
    _zoom = initialCamera.zoom;
    return const SizedBox.expand(key: ValueKey('fake-map-surface'));
  }

  @override
  Future<void> flyTo({
    required double lat,
    required double lng,
    double? zoom,
    bool animate = true,
  }) async {
    flyToCalls.add((lat: lat, lng: lng, zoom: zoom));
    if (zoom != null) _zoom = zoom;
  }

  @override
  Future<void> recenterOn({
    required double lat,
    required double lng,
    double zoom = 15,
    bool animate = true,
  }) async {
    recenterCalls.add((lat: lat, lng: lng));
    _zoom = zoom;
  }

  @override
  double get zoom => _zoom;

  @override
  Future<GeoBounds?> visibleBounds() async => bounds;

  @override
  Future<void> setUserLocationEnabled(bool enabled) async =>
      userLocationEnabled = enabled;
}
