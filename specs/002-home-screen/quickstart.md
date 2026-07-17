# Quickstart — Home Screen (v1)

**Feature**: 002-home-screen

How to run, exercise, and test the Home screen locally.

## Prerequisites

```bash
flutter pub get          # picks up the new deps: url_launcher, shared_preferences, csv
flutter gen-l10n         # regenerate localizations after ARB edits
flutter doctor
```

New dependencies for this feature:
- `url_launcher` — open a place in external Google Maps / OS maps (FR-015)
- `shared_preferences` — persist guest bookmarks + cache the last good sheet fetch (FR-014/FR-016)
- `csv` — parse the published Google Sheet (FR-016)

HTTP reuses the existing `dio` client. The place list is loaded **live** from the published Google Sheet (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`).

## Run

```bash
flutter run                       # debug on a device/emulator (Pixel 7 / API 34 reference)
```

After onboarding/splash, the **Strona** tab shows Home. On open it fetches the sheet (skeletons show while loading).

## What to look for (maps to acceptance criteria)

- **Layout (TC-1, TC-2)**: parchment→sand gradient; sections Header · Search · Chips · Mini-map · Polecane miejsca. No Popular-cities, no browse-all. Existing 5-tab nav stays.
- **Data load (TC-11, TC-12, TC-13)**: cards + mini-map count come from the live sheet; skeletons while fetching; with no network and no cache, a graceful empty/error state + retry (not a crash); with a cache, last data shows.
- **Category filter (TC-4, TC-5)**: chips are the categories present (Restauracje/Meczety/Sklepy/Cmentarze); tapping one filters the Featured row; empty → friendly message; mini-map unaffected.
- **Mini-map (TC-6, TC-7, TC-15)**: drift/float/pulse/sheen; "<N> miejsc w Polsce"; tap → Mapa tab.
- **Place card (TC-8, TC-9)**: gradient placeholder + category badge + bookmark + name only; tapping the body opens Google Maps; no city/status/rating/distance.
- **Featured (TC-17)**: a varied sample across categories (deterministic for the same data).
- **Bookmark (TC-10)**: toggle persists across restart; instant pop+fill.
- **Animations / reduced motion (TC-14, TC-15)**: entrance fade-up; with OS "Reduce Motion", no entrance/ambient motion (static), press feedback only.
- **Localization / RTL (TC-16)**: pl/en/ar; Arabic mirrors to RTL.

## Test

```bash
flutter analyze
dart format .

flutter test test/core/places/                              # parse/mapping, repository (cache/fallback), bookmarks
flutter test test/core/maps/maps_launcher_test.dart         # place → maps URI
flutter test test/features/home/                            # widgets + state (×locales, reduced-motion, loading/error)
flutter test integration_test/home_flow_test.dart           # open → fetch → filter → bookmark → Map tab
flutter test --coverage
```

### Key test entry points (created by `/ai1st-dev-tasks`)
- `test/core/places/place_repository_test.dart` — `parsePlacesCsv` (well-formed, malformed rows skipped, reordered columns, quoted fields), fetch cache + fallback via mock `dio`/`SharedPreferences`
- `test/core/places/category_test.dart` — `parsePolish` mapping + available-categories
- `test/core/places/bookmark_repository_test.dart` — round-trip via mock prefs
- `test/core/maps/maps_launcher_test.dart` — `_placeUri` (coordinates, encoding)
- `test/features/home/presentation/state/home_notifier_test.dart` — featured auto-pick determinism + category filter
- `test/features/home/presentation/.../*_test.dart` — section widgets ×3 locales + reduced-motion + loading/empty/error
- `integration_test/home_flow_test.dart` — happy path incl. Map-tab switch + bookmark persistence + mocked fetch failure

## Local toggles
- **Sheet id**: `kPlacesSheetId` in `lib/core/places/data/places_config.dart` (public; can be overridden via `--dart-define`).
- **Reduced motion**: inject `MediaQueryData(disableAnimations: true)` in widget tests or enable the OS setting.
- **RTL**: run a widget under `Locale('ar')`; assert `Directionality.of(context) == TextDirection.rtl`.
- **Fetch states**: mock `dio` to return CSV (success), throw (error), and pre-seed `SharedPreferences` `places_cache_csv` (cache path).
