import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

void main() {
  group('UrlMapsLauncher.placeUri', () {
    test('builds a Google Maps coordinate URL', () {
      final p = Place.fromParts(
        name: 'Centrum',
        category: Category.masjid,
        lat: 52.174,
        lng: 21.078,
      );
      final uri = UrlMapsLauncher.placeUri(p);
      expect(uri.host, 'www.google.com');
      expect(uri.queryParameters['query'], '52.174,21.078');
      expect(uri.queryParameters['api'], '1');
    });

    test('URL-encodes the coordinate query', () {
      final p = Place.fromParts(
        name: 'X',
        category: Category.shop,
        lat: 50.0,
        lng: 19.5,
      );
      // The comma in "lat,lng" is percent-encoded in the raw query string.
      expect(UrlMapsLauncher.placeUri(p).toString(), contains('50.0%2C19.5'));
    });
  });
}
