import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qibla math + device-heading access. The bearing is pure trigonometry
/// (great-circle initial bearing to the Kaaba); the heading comes from the
/// platform compass behind a provider so tests can fake it.
const double kKaabaLat = 21.422487;
const double kKaabaLng = 39.826206;

/// Initial great-circle bearing from ([lat], [lng]) to the Kaaba, in degrees
/// clockwise from true north, normalized to 0..360.
double qiblaBearing(double lat, double lng) {
  final phi1 = _rad(lat);
  final phi2 = _rad(kKaabaLat);
  final dLng = _rad(kKaabaLng - lng);
  final y = math.sin(dLng) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(dLng);
  final deg = _deg(math.atan2(y, x));
  return (deg + 360) % 360;
}

double _rad(double deg) => deg * (math.pi / 180.0);
double _deg(double rad) => rad * (180.0 / math.pi);

/// Device compass heading in degrees clockwise from north. Emits null when
/// the device has no usable compass sensor (the UI falls back to a static
/// bearing readout).
abstract class CompassService {
  Stream<double?> headings();
}

class FlutterCompassService implements CompassService {
  const FlutterCompassService();

  @override
  Stream<double?> headings() {
    final events = FlutterCompass.events;
    if (events == null) return Stream<double?>.value(null);
    return events.map((e) => e.heading);
  }
}

final compassServiceProvider =
    Provider<CompassService>((ref) => const FlutterCompassService());

final headingProvider = StreamProvider<double?>((ref) {
  return ref.watch(compassServiceProvider).headings();
});
