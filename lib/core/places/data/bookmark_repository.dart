import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/prefs_provider.dart';

/// Persists the guest bookmark set (place ids) locally. Non-sensitive →
/// `shared_preferences`, never secure storage (constitution §2). The future
/// Saved (Zapisane) tab reads the same key. See contracts/bookmark_repository.md.
abstract class BookmarkRepository {
  /// Current bookmarked place ids (empty on first run). Synchronous — the
  /// SharedPreferences instance is already loaded.
  Set<String> load();

  /// Overwrites the persisted set.
  Future<void> save(Set<String> placeIds);
}

class SharedPrefsBookmarkRepository implements BookmarkRepository {
  SharedPrefsBookmarkRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'bookmarked_place_ids';

  @override
  Set<String> load() =>
      (_prefs.getStringList(_key) ?? const <String>[]).toSet();

  @override
  Future<void> save(Set<String> placeIds) =>
      _prefs.setStringList(_key, placeIds.toList(growable: false));
}

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return SharedPrefsBookmarkRepository(ref.watch(sharedPreferencesProvider));
});
