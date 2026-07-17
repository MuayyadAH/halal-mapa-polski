import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/search/recent_searches_repository.dart';
import 'package:halal_map_polskie/features/home/presentation/state/search_notifier.dart';

import '../../../../helpers/pump_app.dart';

ProviderContainer _container() {
  final c = ProviderContainer(
    overrides: [
      placesProvider.overrideWith((ref) async => kSamplePlaces),
      recentSearchesRepositoryProvider
          .overrideWithValue(FakeRecentSearchesRepository()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('searchSuggestionsProvider', () {
    test('is empty when query is blank', () async {
      final c = _container();
      await c.read(placesProvider.future);
      expect(c.read(searchSuggestionsProvider), isEmpty);
    });

    test('matches place names case-insensitively', () async {
      final c = _container();
      await c.read(placesProvider.future);
      c.read(searchQueryProvider.notifier).set('bar');
      final names = c.read(searchSuggestionsProvider).map((p) => p.name);
      expect(names, contains('Bar Halal'));
      expect(names, isNot(contains('Mizar'))); // "mizar" contains no "bar"
    });

    test('respects the suggestion limit', () async {
      final c = _container();
      await c.read(placesProvider.future);
      c.read(searchQueryProvider.notifier).set('e'); // matches many
      expect(
        c.read(searchSuggestionsProvider).length,
        lessThanOrEqualTo(kSuggestionLimit),
      );
    });
  });

  group('RecentSearches', () {
    test('add prepends, de-duplicates, and caps', () {
      final c = ProviderContainer(
        overrides: [
          recentSearchesRepositoryProvider
              .overrideWithValue(FakeRecentSearchesRepository()),
        ],
      );
      addTearDown(c.dispose);
      final notifier = c.read(recentSearchesProvider.notifier);

      notifier.add('kebab');
      notifier.add('meczet');
      notifier.add('kebab'); // duplicate → moves to front, no dupe

      expect(c.read(recentSearchesProvider), ['kebab', 'meczet']);

      for (var i = 0; i < kRecentLimit + 3; i++) {
        notifier.add('q$i');
      }
      expect(c.read(recentSearchesProvider).length, kRecentLimit);
    });

    test('blank queries are ignored', () {
      final c = ProviderContainer(
        overrides: [
          recentSearchesRepositoryProvider
              .overrideWithValue(FakeRecentSearchesRepository()),
        ],
      );
      addTearDown(c.dispose);
      c.read(recentSearchesProvider.notifier).add('   ');
      expect(c.read(recentSearchesProvider), isEmpty);
    });
  });
}
