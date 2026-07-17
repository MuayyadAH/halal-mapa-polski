import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/features/map/presentation/state/sort.dart';

Place _p(String name, double lat, double lng, [Category c = Category.shop]) =>
    Place.fromParts(name: name, category: c, lat: lat, lng: lng);

void main() {
  group('comparatorFor', () {
    test('alphabetical (case-insensitive)', () {
      final list = [_p('Zeta', 0, 0), _p('alpha', 0, 0)]
        ..sort(comparatorFor(SortMode.alphabetical));
      expect(list.map((e) => e.name), ['alpha', 'Zeta']);
    });

    test('nearest with a user location', () {
      const user = (lat: 52.0, lng: 21.0);
      final list = [_p('Far', 52.5, 21.5), _p('Near', 52.01, 21.0)]
        ..sort(comparatorFor(SortMode.nearest, user: user));
      expect(list.first.name, 'Near');
    });

    test('nearest without a user falls back to alphabetical', () {
      final list = [_p('B', 52.5, 21.5), _p('A', 52.01, 21.0)]
        ..sort(comparatorFor(SortMode.nearest));
      expect(list.map((e) => e.name), ['A', 'B']);
    });

    test('by category (canonical order) then name', () {
      final list = [
        _p('M', 0, 0, Category.masjid), // index 1
        _p('R', 0, 0, Category.restaurant), // index 0
      ]..sort(comparatorFor(SortMode.category));
      expect(list.first.category, Category.restaurant);
    });
  });

  group('visiblePlacesProvider', () {
    test('nearest-first when located', () {
      final container = ProviderContainer(
        overrides: [
          categoryFilteredProvider.overrideWithValue(
            [_p('Far', 52.5, 21.5), _p('Near', 52.01, 21.0)],
          ),
          userLatLngProvider.overrideWithValue((lat: 52.0, lng: 21.0)),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(visiblePlacesProvider).first.name, 'Near');
    });

    test('alphabetical when no location', () {
      final container = ProviderContainer(
        overrides: [
          categoryFilteredProvider.overrideWithValue(
            [_p('Zeta', 52.5, 21.5), _p('alpha', 52.01, 21.0)],
          ),
          userLatLngProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      expect(
        container.read(visiblePlacesProvider).map((e) => e.name),
        ['alpha', 'Zeta'],
      );
    });
  });
}
