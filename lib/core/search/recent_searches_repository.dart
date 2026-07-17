import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halal_map_polskie/core/storage/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's recent search queries locally (non-sensitive) so the
/// "Ostatnie" group survives sessions. Most-recent first, de-duplicated, capped.
///
/// Shared across features (Home today, Map next) — promoted to `lib/core/`
/// by 003-map-screen so recents are one unified history (spec FR-018) without
/// a feature→feature import.
abstract class RecentSearchesRepository {
  List<String> load();
  Future<void> save(List<String> queries);
}

class SharedPrefsRecentSearchesRepository implements RecentSearchesRepository {
  SharedPrefsRecentSearchesRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'recent_searches';

  @override
  List<String> load() => _prefs.getStringList(_key) ?? const <String>[];

  @override
  Future<void> save(List<String> queries) =>
      _prefs.setStringList(_key, queries);
}

final recentSearchesRepositoryProvider =
    Provider<RecentSearchesRepository>((ref) {
  return SharedPrefsRecentSearchesRepository(
    ref.watch(sharedPreferencesProvider),
  );
});
