# Quickstart — Map Screen (v1)

**Feature**: `003-map-screen` · branch `003-map-screen`

## Prerequisites
- Flutter stable (`>=3.24`), Dart `>=3.5` (see `pubspec.yaml`)
- Android emulator / iOS simulator (Pixel 7 · API 34 is the reference device)
- A **map tiles key** for local runs (see below). Without it, the map shows the warm background but no tiles.

## New dependencies (added by this feature)
```bash
flutter pub add maplibre_gl      # real interactive MapLibre map (Constitution §I/§II.4)
flutter pub add geolocator       # device location: user dot, locate-me, distance, nearest sort
flutter pub get
```
(`permission_handler`, `shared_preferences`, `dio`, `csv`, `flutter_riverpod`, `go_router`, `intl`, `url_launcher` already present.)

## Platform setup (one-time)
- **Android** (`android/app/src/main/AndroidManifest.xml`): `ACCESS_COARSE_LOCATION` + `INTERNET` (tiles). Verify `minSdkVersion` meets MapLibre's floor.
- **iOS** (`ios/Runner/Info.plist`): `NSLocationWhenInUseUsageDescription` (Polish-localized) + MapLibre deployment target if required.

## Run
```bash
# Tiles key + (optional) style overrides via --dart-define
flutter run \
  --dart-define=MAP_TILES_KEY=<your_maptiler_or_provider_key>
# Style URLs default to asset://assets/map_styles/halalmap-{light,dark}.json (see core/env/env.dart)
```
On launch → tap the **Mapa** tab. Expected: warm MapLibre basemap centred on Warsaw, category-coloured teardrop pins (staggered drop), search bar + Map/Lista toggle + category chips + locate-me FAB + bottom sheet of mini-cards. Grant location → user dot + distances + "Najbliższe" sort; deny → Warsaw overview, no dot/distance.

## Verify the feature (maps to spec TCs)
1. **Map renders** in the 5-tab shell, no own dock (TC-1); real interactive tiles, pan/zoom (TC-2).
2. **Pins & cluster** by category; zoom out → clusters; tap cluster zooms (TC-3/TC-4).
3. **Location**: grant → dot + locate-me recenters (TC-5); deny → graceful Warsaw overview (TC-5).
4. **Selection sync**: tap pin ↔ card (scale + pulse) (TC-6).
5. **Category chips / filter sheet**: chip = single quick-select; sheet = multi-select; ≥2 → no chip active (TC-7/TC-13).
6. **Search**: tap bar → overlay; type (accent-insensitive) → matches across ALL places; pick out-of-filter result → filter clears, pin selected, camera flies (TC-8/TC-8b); recents unified with Home (TC-9).
7. **List**: toggle/“Pokaż listę” cross-fades + staggers (TC-12); inline filter (TC-10); sort Najbliższe/Alfabetycznie/Wg kategorii (TC-11).
8. **Cards/rows lean**: glyph+name+category(+comment+distance); no status/address/walk (TC-14); distance format m/km (TC-14a).
9. **Navigate** → external Google Maps (TC-15).
10. **Reduced motion** off→on disables all animations (TC-19); **pl/en/ar + RTL** (TC-20); **a11y** labels/targets (TC-21); **no ratings/badges/hours/Add/login** (TC-22).

## Test
```bash
flutter test                                  # unit + widget (fake MapEngine + FakeLocationService)
flutter test integration_test/map_flow_test.dart   # E2E on device/emulator (real map)
flutter analyze && dart format .              # must be clean
flutter gen-l10n                              # after ARB edits
```

## Key files (after implementation)
- `lib/features/map/` — `map_screen.dart` (replaces stub) + `presentation/{state,widgets}/`
- `lib/core/map/` — `MapEngine` (MapLibre wrapper) + `map_config.dart`
- `lib/core/location/` — `LocationService` + distance utils
- `lib/core/search/` — promoted recents + `place_match.dart`
- `lib/core/places/presentation/category_style.dart` — promoted `CategoryStyle`
- `assets/map_styles/halalmap-{light,dark}.json` — custom warm style (complete the stubs)
