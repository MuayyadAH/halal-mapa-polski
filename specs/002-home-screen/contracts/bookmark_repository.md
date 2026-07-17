# Contract: `BookmarkRepository`

**Feature**: 002-home-screen
**Type**: Internal Dart interface (local persistence — `shared_preferences`; Spec FR-015)
**Location**: `lib/core/places/data/bookmark_repository.dart` (shared — the future Saved tab reads the same store)

## Interface

```dart
abstract class BookmarkRepository {
  /// Loads the set of bookmarked place ids (empty if none / first run).
  Future<Set<String>> load();

  /// Persists the full set of bookmarked place ids (overwrite).
  Future<void> save(Set<String> placeIds);
}
```

## Concrete implementation

```dart
class SharedPrefsBookmarkRepository implements BookmarkRepository {
  SharedPrefsBookmarkRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'bookmarked_place_ids';

  @override
  Future<Set<String>> load() async =>
      (_prefs.getStringList(_key) ?? const <String>[]).toSet();

  @override
  Future<void> save(Set<String> placeIds) async =>
      _prefs.setStringList(_key, placeIds.toList(growable: false));
}

// SharedPreferences is async to obtain; expose via a FutureProvider-backed
// Provider so the repository is ready before the bookmarks notifier hydrates.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main() after await'),
);

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return SharedPrefsBookmarkRepository(ref.watch(sharedPreferencesProvider));
});
```

> Bootstrap note: `main.dart` awaits `SharedPreferences.getInstance()` once and overrides `sharedPreferencesProvider` with the instance via `ProviderScope(overrides: …)` — same pattern as a synchronous singleton, keeping widgets free of async-init concerns.

## Contract guarantees

1. `load()` never throws — a missing/corrupt key returns an empty set.
2. `save()` overwrites the whole set (last-write-wins); order is irrelevant (it's a set).
3. Stored data is **non-sensitive** (place ids only) — `shared_preferences`, never secure storage (Constitution §2).
4. The same `_key` is the contract the future **Saved (Zapisane)** tab reads (Spec FR-015).

## Bookmark notifier behavior (consumer)

`BookmarksNotifier` (Riverpod `Notifier<Set<String>>`):
- Hydrates from `load()` at construction.
- `toggle(id)`: updates in-memory set immediately (optimistic UI → instant heart pop/fill), then `save(set)` fire-and-forget; on write failure, emit a non-blocking snackbar and keep the optimistic state.
- `isBookmarked(id)` → membership test for card rendering.

## Unit test surface (for `/ai1st-dev-tasks`)

| Test | Assertion |
|------|-----------|
| `load returns empty when key absent` | fresh prefs → `{}` |
| `save then load round-trips the set` | save `{a,b}`; new repo over same prefs `load()` → `{a,b}` |
| `save overwrites` | save `{a,b}` then `{c}`; load → `{c}` |
| `toggle adds then removes` | notifier: toggle(a) → contains a; toggle(a) → not contains a |
| `toggle persists across notifier re-creation` | toggle(a); rebuild notifier from same prefs → still contains a |

Tests use an in-memory `SharedPreferences` (via `SharedPreferences.setMockInitialValues({})`).
