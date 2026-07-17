import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/distance.dart';

void main() {
  group('distanceMeters (haversine)', () {
    test('zero for the same point', () {
      expect(distanceMeters(52.0, 21.0, 52.0, 21.0), 0);
    });

    test('~1.11 km per 0.01° of latitude', () {
      final d = distanceMeters(52.0, 21.0, 52.01, 21.0);
      expect(d, closeTo(1112, 30));
    });

    test('symmetric', () {
      final a = distanceMeters(52.0, 21.0, 52.2, 21.1);
      final b = distanceMeters(52.2, 21.1, 52.0, 21.0);
      expect(a, closeTo(b, 0.001));
    });
  });

  group('formatDistance', () {
    test('whole tens of metres under 1 km', () {
      expect(formatDistance(347, 'pl'), '350 m');
      expect(formatDistance(120, 'en'), '120 m');
      expect(formatDistance(0, 'pl'), '0 m');
    });

    test('km with one decimal at/above 1 km, locale separator', () {
      expect(formatDistance(1234, 'en'), '1.2 km');
      expect(formatDistance(1234, 'pl'), '1,2 km');
      expect(formatDistance(4700, 'en'), '4.7 km');
    });
  });
}
