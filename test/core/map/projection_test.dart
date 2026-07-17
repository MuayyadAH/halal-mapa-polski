import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/map/projection.dart';

void main() {
  const size = Size(800, 600);
  const camera =
      CameraSnapshot(centerLat: 52.2297, centerLng: 21.0122, zoom: 12);

  test('the camera centre projects to the viewport centre', () {
    final o = latLngToScreen(camera, 52.2297, 21.0122, size);
    expect(o.dx, closeTo(400, 0.001));
    expect(o.dy, closeTo(300, 0.001));
  });

  test('a point east is to the right; a point north is higher', () {
    final east = latLngToScreen(camera, 52.2297, 21.05, size);
    final north = latLngToScreen(camera, 52.26, 21.0122, size);
    expect(east.dx, greaterThan(400));
    expect(east.dy, closeTo(300, 0.001));
    expect(north.dy, lessThan(300)); // smaller y = higher on screen
    expect(north.dx, closeTo(400, 0.001));
  });

  test('higher zoom spreads the same delta further apart', () {
    const far =
        CameraSnapshot(centerLat: 52.2297, centerLng: 21.0122, zoom: 10);
    const near =
        CameraSnapshot(centerLat: 52.2297, centerLng: 21.0122, zoom: 14);
    final dxFar = (latLngToScreen(far, 52.2297, 21.05, size).dx - 400).abs();
    final dxNear = (latLngToScreen(near, 52.2297, 21.05, size).dx - 400).abs();
    expect(dxNear, greaterThan(dxFar));
  });
}
