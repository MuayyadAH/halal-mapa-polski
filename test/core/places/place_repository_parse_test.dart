import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';

void main() {
  group('parsePlacesCsv', () {
    test('parses a well-formed sheet', () {
      const csv = 'Longitude,Latitude,Name,Category,Comment,Mawaqit Link\n'
          '21.078,52.174,Centrum Kultury Islamu,Meczet,,\n'
          '19.94,50.06,Bar Halal,Restauracja,Smaczne,\n';
      final places = parsePlacesCsv(csv);
      expect(places, hasLength(2));
      expect(places.first.name, 'Centrum Kultury Islamu');
      expect(places.first.category, Category.masjid);
      expect(places.first.lat, 52.174);
      expect(places.first.lng, 21.078);
      expect(places[1].category, Category.restaurant);
      expect(places[1].comment, 'Smaczne');
      // Stable derived id.
      expect(places.first.id, 'Centrum Kultury Islamu|52.174|21.078');
    });

    test('skips malformed rows (blank name, bad coords, unknown category)', () {
      const csv = 'Longitude,Latitude,Name,Category,Comment,Mawaqit Link\n'
          ',,,,,\n' // all blank
          'x,y,Bad Coords,Meczet,,\n' // unparseable coords
          '21.0,52.0,Unknown Cat,Hotel,,\n' // unknown category
          '21.0,52.0,Good One,Sklep,,\n';
      final places = parsePlacesCsv(csv);
      expect(places, hasLength(1));
      expect(places.single.name, 'Good One');
      expect(places.single.category, Category.shop);
    });

    test('tolerates reordered columns', () {
      const csv = 'Name,Category,Latitude,Longitude,Comment,Mawaqit Link\n'
          'Mizar,Cmentarz,53.17,23.81,,\n';
      final places = parsePlacesCsv(csv);
      expect(places.single.category, Category.cemetery);
      expect(places.single.lat, 53.17);
    });

    test('handles quoted fields with commas', () {
      const csv = 'Longitude,Latitude,Name,Category,Comment,Mawaqit Link\n'
          '21.0,52.0,"Sklep Orient, Centrum",Sklep,"Dużo, naprawdę",\n';
      final places = parsePlacesCsv(csv);
      expect(places.single.name, 'Sklep Orient, Centrum');
      expect(places.single.comment, 'Dużo, naprawdę');
    });

    test('returns empty for blank input', () {
      expect(parsePlacesCsv(''), isEmpty);
      expect(parsePlacesCsv('   '), isEmpty);
    });
  });
}
