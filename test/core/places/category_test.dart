import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';

void main() {
  group('Category.parsePolish', () {
    test('maps the four sheet categories', () {
      expect(Category.parsePolish('Meczet'), Category.masjid);
      expect(Category.parsePolish('Restauracja'), Category.restaurant);
      expect(Category.parsePolish('Sklep'), Category.shop);
      expect(Category.parsePolish('Cmentarz'), Category.cemetery);
    });

    test('is case- and whitespace-tolerant', () {
      expect(Category.parsePolish('  meczet '), Category.masjid);
      expect(Category.parsePolish('RESTAURACJA'), Category.restaurant);
    });

    test('returns null for unknown values', () {
      expect(Category.parsePolish('Hotel'), isNull);
      expect(Category.parsePolish(''), isNull);
    });
  });
}
