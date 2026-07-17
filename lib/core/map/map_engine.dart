import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

import 'projection.dart';

/// Initial camera target (003-map-screen contracts/map_engine.md).
class CameraTarget {
  const CameraTarget({
    required this.lat,
    required this.lng,
    required this.zoom,
  });
  final double lat;
  final double lng;
  final double zoom;
}

/// Visible map bounds — maplibre-free so callers don't depend on the plugin.
class GeoBounds {
  const GeoBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });
  final double south;
  final double west;
  final double north;
  final double east;
}

/// Thin abstraction over the map engine so the feature depends on an interface
/// (swappable provider, fakeable in widget tests). The public API is
/// **maplibre-free** (plain lat/lng doubles) — only [MapLibreEngine] imports
/// `maplibre_gl`. See contracts/map_engine.md.
abstract class MapEngine {
  /// Build the map surface widget with the custom warm style (light/dark).
  /// [onCameraChanged] fires continuously during pan/zoom (and on settle) so
  /// the overlay can re-project markers synchronously and track smoothly.
  Widget buildMap({
    required CameraTarget initialCamera,
    required String styleJson,
    required void Function(CameraSnapshot camera) onCameraChanged,
    void Function(double lat, double lng)? onTapMap,
  });

  /// Animate the camera to a point (≈ ease). Jumps when [animate] is false
  /// (reduced motion).
  Future<void> flyTo({
    required double lat,
    required double lng,
    double? zoom,
    bool animate = true,
  });

  /// Recenter on the user (locate-me FAB).
  Future<void> recenterOn({
    required double lat,
    required double lng,
    double zoom = 15,
    bool animate = true,
  });

  /// Current camera zoom (for clustering); falls back to the last known value.
  double get zoom;

  /// Current visible bounds (for viewport-culling pins). Null until ready.
  Future<GeoBounds?> visibleBounds();

  /// Show/hide the native user-location dot.
  Future<void> setUserLocationEnabled(bool enabled);

  /// True once the underlying controller is created.
  bool get isReady;
}

/// MapLibre-backed [MapEngine] (003-map-screen R2). The native view cannot
/// render in widget tests, so tests use `FakeMapEngine` instead.
class MapLibreEngine implements MapEngine {
  ml.MapLibreMapController? _controller;
  double _lastZoom = 12;

  @override
  bool get isReady => _controller != null;

  @override
  Widget buildMap({
    required CameraTarget initialCamera,
    required String styleJson,
    required void Function(CameraSnapshot camera) onCameraChanged,
    void Function(double lat, double lng)? onTapMap,
  }) {
    _lastZoom = initialCamera.zoom;
    void emit(ml.CameraPosition pos) {
      _lastZoom = pos.zoom;
      onCameraChanged(
        CameraSnapshot(
          centerLat: pos.target.latitude,
          centerLng: pos.target.longitude,
          zoom: pos.zoom,
        ),
      );
    }

    return ml.MapLibreMap(
      styleString: styleJson,
      initialCameraPosition: ml.CameraPosition(
        target: ml.LatLng(initialCamera.lat, initialCamera.lng),
        zoom: initialCamera.zoom,
      ),
      trackCameraPosition: true,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      onMapCreated: (c) => _controller = c,
      onCameraMove: emit,
      onCameraIdle: () {
        final pos = _controller?.cameraPosition;
        if (pos != null) emit(pos);
      },
      onMapClick: onTapMap == null
          ? null
          : (math.Point<double> _, ml.LatLng coord) =>
              onTapMap(coord.latitude, coord.longitude),
    );
  }

  @override
  Future<void> flyTo({
    required double lat,
    required double lng,
    double? zoom,
    bool animate = true,
  }) async {
    final c = _controller;
    if (c == null) return;
    final update = zoom == null
        ? ml.CameraUpdate.newLatLng(ml.LatLng(lat, lng))
        : ml.CameraUpdate.newLatLngZoom(ml.LatLng(lat, lng), zoom);
    if (animate) {
      await c.animateCamera(update);
    } else {
      await c.moveCamera(update);
    }
  }

  @override
  Future<void> recenterOn({
    required double lat,
    required double lng,
    double zoom = 15,
    bool animate = true,
  }) =>
      flyTo(lat: lat, lng: lng, zoom: zoom, animate: animate);

  @override
  double get zoom => _controller?.cameraPosition?.zoom ?? _lastZoom;

  @override
  Future<GeoBounds?> visibleBounds() async {
    final c = _controller;
    if (c == null) return null;
    final b = await c.getVisibleRegion();
    return GeoBounds(
      south: b.southwest.latitude,
      west: b.southwest.longitude,
      north: b.northeast.latitude,
      east: b.northeast.longitude,
    );
  }

  @override
  Future<void> setUserLocationEnabled(bool enabled) async {
    // The native dot is toggled via MapLibreMap.myLocationEnabled at build
    // time; this hook is reserved for runtime toggling once wired on-device.
  }
}

/// The app's map engine. Overridden with a `FakeMapEngine` in widget tests
/// (003-map-screen R15).
final mapEngineProvider = Provider<MapEngine>((ref) => MapLibreEngine());
