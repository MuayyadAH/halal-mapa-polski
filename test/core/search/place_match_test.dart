import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/search/place_match.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations_pl.dart';

void main() {
  final l10n = AppLocalizationsPl();
  Place p(String name, Category c, {String? comment}) => Place.fromParts(
        name: name,
        category: c,
        lat: 0,
        lng: 0,
        comment: comment,
      );

  group('foldPl', () {
    test('lowercases and strips Polish diacritics', () {
      expect(foldPl('Łazienki'), 'lazienki');
      expect(foldPl('ŻŹĆĘĄŚŃÓ'), 'zzceasno');
    });
  });

  group('matchesQuery', () {
    test('accent- and case-insensitive name match', () {
      expect(
        matchesQuery(p('Meczet Łazienki', Category.masjid), 'lazienki', l10n),
        isTrue,
      );
      expect(
        matchesQuery(p('Bistro Karim', Category.restaurant), 'KARIM', l10n),
        isTrue,
      );
    });

    test('matches category label and comment', () {
      expect(matchesQuery(p('X', Category.masjid), 'meczet', l10n), isTrue);
      expect(
        matchesQuery(
          p('X', Category.restaurant, comment: 'Kuchnia turecka'),
          'turecka',
          l10n,
        ),
        isTrue,
      );
    });

    test('empty query and non-matches are false', () {
      expect(matchesQuery(p('X', Category.shop), '', l10n), isFalse);
      expect(matchesQuery(p('X', Category.shop), 'zzz', l10n), isFalse);
    });
  });
}
