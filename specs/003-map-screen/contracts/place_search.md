# Contract — Shared Place Search (match + recents) & Sort

**Location**: `lib/core/search/` (promoted/shared) · **Backs**: FR-016/FR-017/FR-018/FR-019/FR-020 · **Source**: [research.md](../research.md) R8/R12

Promotes/centralizes the search plumbing so Home and Map share it (Constitution §1.1).

## 1. Accent-insensitive matcher (`lib/core/search/place_match.dart`)

```dart
/// Lowercase + strip Polish diacritics: ą→a ć→c ę→e ł→l ń→n ó→o ś→s ż→z ź→z.
String foldPl(String input);

/// True if the folded query is a substring of the place's folded
/// name OR category label OR comment. Empty query → false.
bool matchesQuery(Place place, String query, AppLocalizations l10n);
```
- **Contract**: case- AND accent-insensitive (FR-017). "lazienki" matches "Łazienki"; "meczet" matches "Meczet". Comment included so notes are searchable.
- **Used by**: Map search overlay (`searchMatchesProvider`, full dataset, ignores active filter) and the Lista inline filter (`visiblePlacesProvider` when `view==list`).

## 2. Recent searches (promoted — `lib/core/search/recent_searches_repository.dart`)

```dart
abstract class RecentSearchesRepository {       // moved from features/home/data/
  List<String> load();                          // most-recent first
  Future<void> save(List<String> queries);
}
// key: 'recent_searches' (UNCHANGED) → unified Home+Map history (FR-018)
```
- Provider `recentSearchesRepositoryProvider` + `recentSearchesProvider` (`Notifier<List<String>>`, de-duped, capped `kRecentLimit=8`) reused as-is; **Home's import path updated** (no behavior change).
- **Contract**: a query recorded on Home appears under the Map's "Ostatnie" and vice-versa; re-fill on tap.

## 3. Sort comparators (`lib/features/map/.../sort.dart` or core)

```dart
enum SortMode { nearest, alphabetical, category }

int Function(Place, Place) comparatorFor(SortMode mode, {LatLng? user});
```
- `nearest` → ascending `distanceMeters(user, p)`; **requires** `user != null` (mode hidden otherwise, FR-020).
- `alphabetical` → locale-aware name compare (Polish collation).
- `category` → `Category.values.indexOf` then name.
- Default = `nearest` if located else `alphabetical`. No `openNow` (no hours data).

## Test contract
- Unit: `foldPl` (each Polish diacritic), `matchesQuery` (name/label/comment hits + misses, accent + case), recents (dedupe/cap/persist via fake prefs), each comparator (incl. nearest with/without user, stable order).
- Widget: Map overlay groups (Ostatnie/Podpowiedzi/Kategorie), Lista inline filter, "Brak wyników".
- Regression: Home still compiles and behaves after the recents/CategoryStyle import moves.
