import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

// Recents are shared app-wide (Home + Map): re-exported from core so existing
// Home imports of `recentSearchesProvider` via this file keep working.
export 'package:halal_map_polskie/core/search/recent_searches.dart'
    show RecentSearches, recentSearchesProvider, kRecentLimit;

/// Max number of live place suggestions shown in the "Podpowiedzi" group.
const int kSuggestionLimit = 6;

/// Whether the search-active overlay is showing (FR: tap SearchBar → active).
class SearchActive extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;
  void close() => state = false;
}

final searchActiveProvider =
    NotifierProvider<SearchActive, bool>(SearchActive.new);

/// The live query text (updated as the user types).
class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQuery, String>(SearchQuery.new);

/// Case-insensitive place suggestions for the current query (name match).
/// Empty when the query is blank. Capped at [kSuggestionLimit].
final searchSuggestionsProvider = Provider<List<Place>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];
  final places = ref.watch(placesProvider).value ?? const <Place>[];
  return places
      .where((Place p) => p.name.toLowerCase().contains(query))
      .take(kSuggestionLimit)
      .toList(growable: false);
});
