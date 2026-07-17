# Contract: `PlaceRepository` (shared)

**Feature**: 002-home-screen (also consumed by the future Map feature)
**Type**: Shared Dart interface — loads places from the live Google Sheet (Spec FR-016/FR-017)
**Location**: `lib/core/places/data/place_repository.dart` (shared, under `lib/core/`)

## Interface

```dart
abstract class PlaceRepository {
  /// Fetches and parses the published Google Sheet into Places.
  /// Throws on network/parse failure (the provider surfaces it as AsyncError;
  /// the repository may first return a cached list — see fetchPlaces impl).
  Future<List<Place>> fetchPlaces();
}
```

## Concrete implementation (Google Sheet + dio + csv + cache)

```dart
class GoogleSheetPlaceRepository implements PlaceRepository {
  GoogleSheetPlaceRepository(this._dio, this._prefs, {this.sheetId = kPlacesSheetId});
  final Dio _dio;
  final SharedPreferences _prefs;
  final String sheetId;

  static const _cacheKey = 'places_cache_csv';

  String get _url =>
      'https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv';

  @override
  Future<List<Place>> fetchPlaces() async {
    try {
      final res = await _dio.get<String>(
        _url,
        options: Options(responseType: ResponseType.plain), // follows 307 → signed URL
      );
      final csv = res.data ?? '';
      final places = parsePlacesCsv(csv);          // see below
      await _prefs.setString(_cacheKey, csv);      // cache last good fetch
      return places;
    } catch (_) {
      final cached = _prefs.getString(_cacheKey);  // resilience fallback
      if (cached != null) return parsePlacesCsv(cached);
      rethrow;                                      // → AsyncError → empty/error UI + retry
    }
  }
}

/// Pure, unit-testable CSV → Place mapping (no IO).
@visibleForTesting
List<Place> parsePlacesCsv(String csv) {
  final rows = const CsvToListConverter(eol: '\n').convert(csv);
  if (rows.isEmpty) return const [];
  final header = rows.first.map((c) => c.toString().trim()).toList();
  int col(String name) => header.indexOf(name);
  final iLng = col('Longitude'), iLat = col('Latitude'),
        iName = col('Name'), iCat = col('Category'),
        iComment = col('Comment'), iMawaqit = col('Mawaqit Link');

  final out = <Place>[];
  for (final r in rows.skip(1)) {
    final name = (iName >= 0 ? r[iName] : '').toString().trim();
    final lat = double.tryParse('${iLat >= 0 ? r[iLat] : ''}');
    final lng = double.tryParse('${iLng >= 0 ? r[iLng] : ''}');
    final category = Category.parsePolish('${iCat >= 0 ? r[iCat] : ''}');
    if (name.isEmpty || lat == null || lng == null || category == null) {
      continue; // skip malformed / unknown-category rows (never fatal)
    }
    out.add(Place(
      id: '$name|$lat|$lng',
      name: name,
      category: category,
      lat: lat,
      lng: lng,
      comment: _nullIfBlank(iComment >= 0 ? '${r[iComment]}' : ''),
      mawaqitLink: _nullIfBlank(iMawaqit >= 0 ? '${r[iMawaqit]}' : ''),
    ));
  }
  return out;
}

final placeRepositoryProvider = Provider<PlaceRepository>((ref) =>
    GoogleSheetPlaceRepository(ref.watch(dioProvider), ref.watch(sharedPreferencesProvider)));

/// Shared — Home and the future Map both watch this.
final placesProvider = FutureProvider<List<Place>>((ref) =>
    ref.watch(placeRepositoryProvider).fetchPlaces());
```

`kPlacesSheetId` is a public (non-secret) constant in the places config (movable to `--dart-define`).

## Contract guarantees

1. `fetchPlaces()` returns parsed `Place`s on success and **caches** the raw CSV; on failure it returns the cached list if present, else throws (→ graceful empty/error UI with retry — Spec FR-016, TC-13).
2. `parsePlacesCsv` is pure and tolerant: maps by **header name** (survives column reordering), skips rows with blank name / unparseable coordinates / unknown category — never throws on a bad row (Spec edge cases).
3. The repository is the **single** place-loading path for the app (Home now, Map later — Spec FR-017); no feature reimplements loading.
4. No analytics/tracking; the sheet fetch is the only network call (Constitution §1.7).

## Unit test surface (for `/ai1st-dev-tasks`)

| Test | Assertion |
|------|-----------|
| `parses a well-formed CSV` | header + 3 rows → 3 Places with correct fields and derived ids |
| `maps Polish categories` | Meczet→masjid, Sklep→shop, Restauracja→restaurant, Cmentarz→cemetery |
| `skips malformed rows` | row with empty name / non-numeric coords / unknown category is dropped; others survive |
| `tolerates reordered columns` | header in a different order still maps correctly by name |
| `fetch caches and falls back` | success caches CSV; a subsequent failing fetch returns the cached parse |
| `fetch with no cache rethrows` | failure + empty cache → throws (→ AsyncError) |

Tests use a mocked `Dio` and `SharedPreferences.setMockInitialValues({})`; `parsePlacesCsv` is tested directly with fixture strings (incl. quoted fields / commas in names).
