import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/home/presentation/state/home_notifier.dart';

Place _p(String n, Category c) =>
    Place.fromParts(name: n, category: c, lat: 1, lng: 1);

void main() {
  group('selectFeatured', () {
    test('is deterministic for a given input', () {
      final places = [
        _p('a', Category.masjid),
        _p('b', Category.restaurant),
        _p('c', Category.shop),
      ];
      expect(
        selectFeatured(places).map((p) => p.name),
        selectFeatured(places).map((p) => p.name),
      );
    });

    test('round-robins across categories for variety', () {
      final places = [
        _p('m1', Category.masjid),
        _p('m2', Category.masjid),
        _p('r1', Category.restaurant),
        _p('s1', Category.shop),
      ];
      final featured = selectFeatured(places, cap: 3);
      final cats = featured.map((p) => p.category).toList();
      // First three picks should span distinct categories before repeating.
      expect(cats.toSet().length, 3);
    });

    test('respects the cap', () {
      final places = List.generate(20, (i) => _p('p$i', Category.shop));
      expect(selectFeatured(places, cap: 5), hasLength(5));
    });

    test('returns empty for empty input', () {
      expect(selectFeatured(const []), isEmpty);
    });
  });
}
