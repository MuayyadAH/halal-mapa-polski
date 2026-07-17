import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/map/cluster.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

void main() {
  Place at(String n, double lat, double lng) =>
      Place.fromParts(name: n, category: Category.shop, lat: lat, lng: lng);

  test('empty in → empty out', () {
    expect(clusterPlaces(const [], 12), isEmpty);
  });

  test('far-apart points stay single at high zoom', () {
    final items = clusterPlaces([at('a', 52.0, 21.0), at('b', 52.5, 21.5)], 16);
    expect(items.whereType<SinglePlace>().length, 2);
    expect(items.whereType<PlaceCluster>(), isEmpty);
  });

  test('co-located points cluster at low zoom (centroid + count)', () {
    final items = clusterPlaces(
      [at('a', 52.2001, 21.0001), at('b', 52.2003, 21.0003)],
      3,
    );
    expect(items.length, 1);
    expect(items.first, isA<PlaceCluster>());
    final c = items.first as PlaceCluster;
    expect(c.count, 2);
    expect(c.lat, closeTo(52.2002, 1e-4));
  });
}
