import 'dart:math' as math;

import 'package:flutter/widgets.dart' show Offset, Size;

/// Live camera state needed to project markers synchronously (003-map-screen R3
/// smoothness fix). Updated on every `onCameraMove`.
class CameraSnapshot {
  const CameraSnapshot({
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
  });
  final double centerLat;
  final double centerLng;
  final double zoom;
}

const double _tileSize = 512.0;

double _projX(double lng) => (lng + 180.0) / 360.0;

double _projY(double lat) {
  final s = math.sin(lat * math.pi / 180.0).clamp(-0.9999, 0.9999);
  return 0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi);
}

/// Projects [lat]/[lng] to a screen [Offset] within a [size] viewport for the
/// current north-up [camera] (Web Mercator, 512px tiles — matches MapLibre's
/// projection). Pure and synchronous so markers track the basemap smoothly
/// during pan/zoom without per-marker platform round-trips. Assumes no bearing
/// or pitch (rotation & tilt gestures are disabled on the map).
Offset latLngToScreen(
  CameraSnapshot camera,
  double lat,
  double lng,
  Size size,
) {
  final worldSize = _tileSize * math.pow(2.0, camera.zoom);
  final cx = _projX(camera.centerLng) * worldSize;
  final cy = _projY(camera.centerLat) * worldSize;
  final px = _projX(lng) * worldSize;
  final py = _projY(lat) * worldSize;
  return Offset(size.width / 2 + (px - cx), size.height / 2 + (py - cy));
}
