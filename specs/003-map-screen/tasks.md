# Tasks: Map Screen (v1)

**Feature**: `003-map-screen` · **Input**: design docs in `specs/003-map-screen/` (plan.md, spec.md, research.md, data-model.md, contracts/)
**Tech**: Flutter / Dart, Riverpod, go_router, `intl` + existing shared place layer (`lib/core/places/`), `url_launcher` (via shared `MapsLauncher`), `permission_handler` + **new `geolocator`**, **new `maplibre_gl`** behind a `MapEngine` abstraction. Live data from the shared published Google Sheet.

Tests are included (Constitution §4 + spec §6 require unit + widget + integration). The native MapLibre view is untestable headless, so widget tests inject a **FakeMapEngine**; native rendering is covered only by the integration test. Format: `- [ ] [TaskID] [P?] [Story?] Description + file path`. `[P]` = parallelizable (different file, no incomplete deps).

---

## User Stories (priority order, from spec.md)

- **US1 (P1, MVP)** — Interactive map with pins: real MapLibre warm basemap + category teardrop pins + clusters, Warsaw initial camera, inside the 5-tab shell; loading/empty/error states. (FR-001/002/003/004/005, TC-1/2/3/4/17/23)
- **US2 (P2)** — Device location: user-location dot, locate-me FAB, distance; graceful Warsaw fallback when denied. (FR-006/014, NFR-005, TC-5)
- **US3 (P3)** — Selection + bottom place sheet + Navigate: pin↔card sync, visible-places sheet (nearest-first/A→Z) + count, external-maps hand-off. (FR-007/008/009/010/013/022, TC-6/14/14a/15/16)
- **US4 (P4)** — Category filter: one shared `activeCategories` set; chips quick-select + filter-sheet multi-select; filters pins+sheet+list. (FR-011/012, TC-7/13)
- **US5 (P5)** — Map search overlay: full-dataset accent-insensitive match, unified recents, pick→fly+select, out-of-filter selection clears filter. (FR-016/017/018, TC-8/8b/9)
- **US6 (P6)** — Lista view + toggle + sort + inline filter: Map↔Lista cross-fade, list rows, sort pill (Najbliższe/Alfabetycznie/Wg kategorii), inline live filter. (FR-015/019/020/021, TC-10/11/12)
- **US7 (P7)** — Animations: pin drop, selected pulse, sheet entrance, list stagger, view cross-fade; reduced-motion disables all. (FR-024, TC-18/19)

---

## Phase 1: Setup

- [x] T001 Add `maplibre_gl` and `geolocator` to dependencies in `pubspec.yaml` (pin exact versions via `flutter pub add`), run `flutter pub get`, and confirm MapLibre's Android min-SDK / iOS deployment-target floor is met (repo root)
- [x] T002 Add `ACCESS_COARSE_LOCATION` and `INTERNET` permissions to `android/app/src/main/AndroidManifest.xml`
- [x] T003 [P] Add `NSLocationWhenInUseUsageDescription` (Polish-localized) to `ios/Runner/Info.plist` and set MapLibre deployment target if required
- [x] T004 Verify implementation conflicts per plan.md: confirm `lib/features/map/map_screen.dart` (stub) is to be replaced and `lib/core/routing/app_router.dart` (`/map`) + `lib/core/routing/scaffold_with_tabs.dart` stay unchanged; note the recents + `CategoryStyle` promotions (T008/T009) will update Home imports

## Phase 2: Foundational (blocking prerequisites — engine, style, shared utils, promotions, tokens, l10n)

- [x] T005 [P] Complete the custom warm MapLibre style JSON (light + dark) referencing the tile source (key via `--dart-define=MAP_TILES_KEY`), using the design palette (land `#ECE1CB`, blocks `#D4C08E`, roads `#F6ECD5`, parks `#B4C89A`, water `#A8C2C5`; dark per §II.4) in `assets/map_styles/halalmap-light.json` and `assets/map_styles/halalmap-dark.json`
- [x] T006 [P] Add Map ARB keys (`mapSearchHint` "Szukaj na mapie…", `listFilterHint` "Filtruj listę…", `toggleListShort` "Lista", `showListLink` "Pokaż listę", `sortNearest` "Najbliższe", `sortAlphabetical` "Alfabetycznie", `sortByCategory` "Wg kategorii", `filtersTitle` "Filtry", `allPlacesTitle` "Wszystkie miejsca", `noResults` "Brak wyników", `placesCount` ICU plural, `locateMeLabel`, `navigateLabel`, `prayerTimesLinkLabel`) to `lib/l10n/app_pl.arb` (canonical), `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`; run `flutter gen-l10n`
- [x] T007 [P] Add Map tokens (`userDot = #2A6FDB`, dark-basemap variants, pin drop-shadow + selected-glow) to `lib/core/theme/tokens.dart`
- [x] T008 Promote `RecentSearchesRepository` → `lib/core/search/recent_searches_repository.dart` (same `recent_searches` key), update Home imports in `lib/features/home/presentation/state/search_notifier.dart` and `lib/features/home/presentation/widgets/search_view.dart`, and confirm Home still compiles
- [x] T009 Promote the `CategoryStyle` extension → `lib/core/places/presentation/category_style.dart`, update all Home imports (`search_view.dart`, `category_chips.dart`, `place_card.dart`, `mini_map.dart`, etc.), and confirm Home still compiles
- [x] T010 [P] Create distance utilities — `distanceMeters(LatLng,LatLng)` (haversine), `formatDistance(double, Locale)` (adaptive m/km via `intl`), and `const warsaw`/`defaultZoom` — in `lib/core/location/distance.dart`
- [x] T011 [P] Create `foldPl(String)` (strip Polish diacritics) + `matchesQuery(Place, String, AppLocalizations)` (name + category label + comment, accent-insensitive) in `lib/core/search/place_match.dart` (dep: T009)
- [x] T012 [P] Create `clusterPlaces(List<Place>, double zoom, LatLngBounds)` + `MapMarker`/`Cluster` value types in `lib/core/map/cluster.dart`
- [x] T013 Create the `MapEngine` interface + `MapLibreEngine` impl (maplibre_gl: build map with custom style, `flyTo`/`recenterOn`/`toScreenLocation`/`setUserLocation`/`zoom`/`visibleBounds`) in `lib/core/map/map_engine.dart` per `contracts/map_engine.md` (deps: T001, T005)
- [x] T014 [P] Create `FakeMapEngine` (plain `SizedBox` surface, records `flyTo`/`recenterOn`/`setUserLocation`, deterministic `toScreenLocation`) in `test/support/fake_map_engine.dart`
- [x] T015 [P] Unit test distance: haversine known pairs; `formatDistance` 350 m / 1,2 km / locale decimal separator in `test/core/location/distance_test.dart`
- [x] T016 [P] Unit test `place_match`: `foldPl` for each Polish diacritic; `matchesQuery` name/label/comment hits + misses, accent + case in `test/core/search/place_match_test.dart`
- [x] T017 [P] Unit test `clusterPlaces`: overlapping points group by zoom, counts, centroid, viewport-cull in `test/core/map/cluster_test.dart`
- [x] T018 [P] Unit test recents repo still round-trips after promotion (mock prefs) in `test/core/search/recent_searches_repository_test.dart`

---

## Phase 3: US1 — Interactive map with pins (P1, MVP)

**Goal**: Open Mapa → warm MapLibre basemap centred on Warsaw with category teardrop pins + clusters, inside the 5-tab shell, no own dock. **Independent test**: with `FakeMapEngine` + a mocked `placesProvider`, pins render for the places; clusters appear at low zoom; tapping a cluster flies/zooms; loading→chrome, error→retry.

- [x] T019 [US1] Create `map_providers.dart` part 1: `categoryFilteredProvider` (all places for now) + `clusterLayerProvider` (from `clusterPlaces` using engine zoom/bounds) in `lib/features/map/presentation/state/map_providers.dart` (deps: T012, shared `placesProvider`)
- [x] T020 [P] [US1] Create `MapPin` widget (teardrop `BorderRadius 50% 50% 50% 4px` rotated −45°, category colour via `CategoryStyle`, 2.5px white border, counter-rotated +45° white glyph) in `lib/features/map/presentation/widgets/map_pin.dart` (deps: T007, T009)
- [x] T021 [P] [US1] Create `ClusterBubble` widget (cocoa800 circle, 3px cream border, count, size `38+count*0.5`) in `lib/features/map/presentation/widgets/cluster_bubble.dart` (dep: T007)
- [x] T022 [US1] Create `MapView` widget: `MapEngine.buildMap` surface + Flutter pin/cluster overlay positioned via `toScreenLocation`, recomputed on camera move/idle (viewport-culled); tap pin → select stub; tap cluster → `flyTo` zoom-in in `lib/features/map/presentation/widgets/map_view.dart` (deps: T013, T019, T020, T021)
- [x] T023 [P] [US1] Create `MapEmptyError` widget (empty + error message + retry; map chrome intact) in `lib/features/map/presentation/widgets/map_empty_error.dart` (dep: T006)
- [x] T024 [US1] Replace the stub `MapScreen`: `lib/features/map/map_screen.dart` = `Stack(MapView + chrome slots)`, Warsaw initial camera, inject `MapEngine` (real in app / fake in tests), consume `placesProvider` `AsyncValue` → loading / `MapEmptyError` / content (deps: T022, T023)
- [x] T025 [P] [US1] Widget test: with `FakeMapEngine` + mocked places, pins render for visible places; cluster bubble at low zoom; tap cluster calls `engine.flyTo` in `test/features/map/presentation/map_view_test.dart`
- [x] T026 [P] [US1] Widget test: `MapScreen` loading shows chrome; error shows `MapEmptyError` + retry; renders inside a tab shell with no own dock in `test/features/map/presentation/map_screen_test.dart`
- [x] T027 [US1] Integration test scaffold: open the Mapa tab → real MapLibre basemap + pins render on device/emulator in `integration_test/map_flow_test.dart`

---

## Phase 4: US2 — Device location (P2)

**Goal**: User-location dot + locate-me + distance; graceful Warsaw fallback when denied. **Independent test**: `FakeLocationService` granted → dot shown, FAB recenters, distance computed; denied → no dot, Warsaw overview, FAB no-crash.

- [x] T028 [US2] Create `LocationService` + `GeolocatorLocationService` (approximate, while-in-use, permission via existing `PermissionsService`) + `locationServiceProvider` + `locationProvider` (`FutureProvider<LatLng?>`) + `userLatLngProvider` in `lib/core/location/location_service.dart` per `contracts/location_service.md` (deps: T001, `permissions_service.dart`)
- [x] T029 [P] [US2] Create `UserDot` widget (20dp `#2A6FDB`, 3.5px white border, soft halo) in `lib/features/map/presentation/widgets/user_dot.dart` (dep: T007)
- [x] T030 [P] [US2] Create `LocateMeFab` (44dp parchment-glass, crosshair glyph, semantic label) in `lib/features/map/presentation/widgets/locate_me_fab.dart` (dep: T006)
- [x] T031 [US2] Wire location into `MapView`/`MapScreen`: show `UserDot` at `userLatLng` (`engine.setUserLocation`), centre camera on user when available else Warsaw; `LocateMeFab` → `recenterOn(user)` / re-prompt if denied / no-op gracefully in `lib/features/map/presentation/widgets/map_view.dart` and `lib/features/map/map_screen.dart` (deps: T028, T029, T030, T024)
- [x] T032 [P] [US2] Create `FakeLocationService` (scripted granted+fix / denied / service-off / slow-fix) in `test/support/fake_location_service.dart`
- [x] T033 [P] [US2] Widget test: granted → `UserDot` shown + FAB calls `recenterOn`; denied → no dot, Warsaw overview, FAB no-crash in `test/features/map/presentation/location_test.dart` (dep: T032)

---

## Phase 5: US3 — Selection + bottom place sheet + Navigate (P3)

**Goal**: Pin↔card bidirectional selection; bottom sheet of visible places (nearest-first/A→Z) + header count; Navigate → external Google Maps. **Independent test**: selecting a pin highlights its card (and vice-versa); sheet order correct; Navigate invokes the shared launcher.

- [x] T034 [US3] Create `selectedPlaceIdProvider` (`Notifier<String?>`, single-selection) in `lib/features/map/presentation/state/map_selection_notifier.dart`
- [x] T035 [US3] Add `visiblePlacesProvider` (categoryFiltered + sort; nearest needs `userLatLng`) + `distanceForProvider(place)` to `lib/features/map/presentation/state/map_providers.dart` (deps: T010, T019, T028)
- [x] T036 [P] [US3] Create `MiniCard` widget (gradient icon tile + glyph, name, category label + distance when located, optional comment line, Navigate button, Mawaqit link on mosques, selected treatment white/cocoa-border/ring) in `lib/features/map/presentation/widgets/mini_card.dart` (deps: T009, T010, shared `MapsLauncher`)
- [x] T037 [US3] Create `PlaceSheet` (`DraggableScrollableSheet`, grab handle, header "N miejsc" plural + "Pokaż listę", horizontal `ListView` of `MiniCard` from `visiblePlaces`, scroll-selected-into-view) in `lib/features/map/presentation/widgets/place_sheet.dart` (deps: T035, T036, T034)
- [x] T038 [US3] Wire bidirectional selection: pin tap → `selectedPlaceId` + scroll sheet to card; card tap → `selectedPlaceId` + mark pin selected (+ optional `flyTo`) in `lib/features/map/presentation/widgets/map_view.dart` and `lib/features/map/presentation/widgets/place_sheet.dart` (deps: T034, T037, T022)
- [x] T039 [US3] Mount `PlaceSheet` in `MapScreen` and wire `MiniCard` Navigate → `MapsLauncher.openPlace` in `lib/features/map/map_screen.dart` and `lib/features/map/presentation/widgets/mini_card.dart` (deps: T037)
- [x] T040 [P] [US3] Widget test: pin tap ↔ card highlight sync; sheet order nearest-first (located) / A→Z (not); header count; Navigate invokes a mocked launcher in `test/features/map/presentation/sheet_selection_test.dart`
- [x] T041 [P] [US3] Unit test: `visiblePlaces` derivation + sort comparators (nearest with/without user, alphabetical, by-category) in `test/features/map/presentation/state/map_providers_test.dart`

---

## Phase 6: US4 — Category filter (P4)

**Goal**: One shared `activeCategories` set; chips quick-select, filter sheet multi-select; filters pins + sheet + list. **Independent test**: chip → single category; "Wszystko" clears; sheet selecting ≥2 → no single chip active; both pins and sheet narrow.

- [x] T042 [US4] Create `map_filter_notifier.dart`: `activeCategoriesProvider` (`Notifier<Set<Category>>` with `selectOnly`/`clear`/`toggle`) + `availableCategoriesProvider` in `lib/features/map/presentation/state/map_filter_notifier.dart` (dep: shared `placesProvider`)
- [x] T043 [US4] Wire `categoryFilteredProvider`/`visiblePlacesProvider` to read `activeCategories` in `lib/features/map/presentation/state/map_providers.dart` (deps: T042, T019, T035)
- [x] T044 [P] [US4] Create `MapCategoryChips` (horizontal single-shortcut: "Wszystko" + a chip per `availableCategories`; `selectOnly`/`clear`; no chip active when set size ≥2) in `lib/features/map/presentation/widgets/map_category_chips.dart` (deps: T009, T042)
- [x] T045 [P] [US4] Create `FilterSheet` (category multi-select toggling `activeCategories`; **no open-now toggle**) in `lib/features/map/presentation/widgets/filter_sheet.dart` (deps: T009, T042)
- [x] T046 [US4] Mount `MapCategoryChips` + the trailing filter glyph (opens `FilterSheet`) in `MapScreen` chrome in `lib/features/map/map_screen.dart` (deps: T044, T045)
- [x] T047 [P] [US4] Widget test: chip `selectOnly` filters pins + sheet; "Wszystko" clears; filter-sheet ≥2 selected → no single chip active; both views narrow in `test/features/map/presentation/filter_test.dart`

---

## Phase 7: US5 — Map search overlay (P5)

**Goal**: Search bar → overlay; full-dataset accent-insensitive match; unified recents; pick → fly + select; out-of-filter pick clears filter; "Brak wyników". **Independent test**: typing filters across all places; picking a filtered-out result clears the filter + selects + flies; recents shared with Home.

- [x] T048 [US5] Create `map_search_notifier.dart`: `mapSearchActiveProvider` + `mapSearchQueryProvider` + `searchMatchesProvider` (full dataset via `matchesQuery`, **ignores** `activeCategories`) in `lib/features/map/presentation/state/map_search_notifier.dart` (deps: T011, shared `placesProvider`)
- [x] T049 [P] [US5] Create `MapSearchBar` (translucent parchment-glass; placeholder `mapSearchHint`/`listFilterHint`; leading magnifier; trailing filter glyph) in `lib/features/map/presentation/widgets/map_search_bar.dart` (dep: T006)
- [x] T050 [US5] Create `MapSearchOverlay` (focused field + "Anuluj"; groups Ostatnie [shared `recentSearchesProvider`] / Podpowiedzi [`searchMatches`] / Kategorie [quick filters]; ~150 ms debounce; reduced-motion entrance) in `lib/features/map/presentation/widgets/map_search_overlay.dart` (deps: T048, T009, promoted recents)
- [x] T051 [US5] Wire: search-bar tap → `mapSearchActive`; render overlay; selecting a result → if `place.category ∉ activeCategories` then `clear()` filter, set `selectedPlaceId`, `engine.flyTo`, surface card, close overlay, record recent; "Anuluj" closes unchanged in `lib/features/map/map_screen.dart` and `lib/features/map/presentation/widgets/map_search_bar.dart` (deps: T050, T034, T042, T031)
- [x] T052 [P] [US5] Widget test: typing → accent-insensitive matches across the full dataset (incl. filtered-out); picking an out-of-filter result clears the filter + selects + `flyTo`; "Anuluj" leaves the map unchanged; empty → "Brak wyników" in `test/features/map/presentation/search_overlay_test.dart`
- [x] T053 [P] [US5] Widget test: recents unified — a query recorded surfaces via the shared `recentSearchesProvider` (same store as Home) in `test/features/map/presentation/search_recents_test.dart`

---

## Phase 8: US6 — Lista view + toggle + sort + inline filter (P6)

**Goal**: Map↔Lista cross-fade; scrollable list rows; sort pill (Najbliższe/Alfabetycznie/Wg kategorii); inline live filter. **Independent test**: toggle cross-fades to the list; rows render; sort reorders; inline filter narrows live; "Brak wyników"; no open-now option.

- [x] T054 [US6] Create `map_view_notifier.dart`: `mapViewProvider` (`Notifier<MapView>` `map|list`) + `sortModeProvider` (`Notifier<SortMode>`, default nearest-if-located-else-alphabetical) in `lib/features/map/presentation/state/map_view_notifier.dart`
- [x] T055 [P] [US6] Create `ViewToggle` (segmented Mapa/Lista; active = cocoa800 fill + cream) in `lib/features/map/presentation/widgets/view_toggle.dart` (dep: T006)
- [x] T056 [P] [US6] Create `ListRow` (icon tile + glyph, name, category label, optional comment, distance when located, Navigate button; no status/address/walk) in `lib/features/map/presentation/widgets/list_row.dart` (deps: T009, T010, shared `MapsLauncher`)
- [x] T057 [P] [US6] Create `SortPill` + sort menu (Najbliższe [only if located] / Alfabetycznie / Wg kategorii; writes `sortModeProvider`) in `lib/features/map/presentation/widgets/sort_pill.dart` (deps: T006, T054)
- [x] T058 [US6] Create `ListViewBody` (warm gradient bg; header "Wszystkie miejsca" + count; `ListRow`s from `visiblePlaces`; inline filter via `mapSearchQuery` when `view==list`; "Brak wyników") in `lib/features/map/presentation/widgets/list_view_body.dart` (deps: T056, T035, T048, T057)
- [x] T059 [US6] Wire `ViewToggle` + the sheet "Pokaż listę" link → `mapView`; `AnimatedSwitcher` cross-fade between (MapView + PlaceSheet) and `ListViewBody` in `lib/features/map/map_screen.dart` (deps: T054, T055, T058)
- [x] T060 [P] [US6] Widget test: toggle → list cross-fade; rows render; sort reorders (nearest/alpha/category); inline filter narrows; "Brak wyników"; no open-now option in `test/features/map/presentation/list_view_test.dart`

---

## Phase 9: US7 — Animations (P7)

**Goal**: Pin drop, selected pulse, sheet entrance, list stagger, view cross-fade — all reduced-motion-safe. **Independent test**: with animations on, effects play; with `disableAnimations`, all are disabled (final states) and selection still updates styles.

- [x] T061 [US7] Add pin-drop entrance (per-marker `TweenAnimationBuilder` 460 ms `easeOutBack`, +60 ms/pin stagger) + selected pulse ring (`AnimationController` 2400 ms repeat) + `AnimatedScale`→1.18 (250 ms), gated on `disableAnimations`, in `lib/features/map/presentation/widgets/map_pin.dart` and `lib/features/map/presentation/widgets/map_view.dart` (deps: T020, T022)
- [x] T062 [US7] Add sheet slide+fade entrance (360 ms easeOutCubic) to `PlaceSheet` and list fade-up stagger (reuse `FadeRiseIn`; sort 70 / header 140 / rows 160+i·45 ms — promote `FadeRiseIn` to `lib/shared/widgets/` if needed) to `ListViewBody`, gated on reduced motion, in `lib/features/map/presentation/widgets/place_sheet.dart` and `lib/features/map/presentation/widgets/list_view_body.dart` (deps: T037, T058)
- [x] T063 [US7] Ensure the Map↔Lista `AnimatedSwitcher` cross-fade (~300 ms) and the reduced-motion final-state path in `lib/features/map/map_screen.dart` (dep: T059)
- [x] T064 [P] [US7] Widget test: animations present normally; with `MediaQueryData(disableAnimations: true)` all pin/pulse/sheet/list/toggle motion is disabled (final state) while selection styling still updates in `test/features/map/presentation/motion_test.dart`

---

## Phase 10: Polish & Cross-Cutting

- [x] T065 [P] Accessibility pass: `Semantics` labels on pins, search/filter/locate-me/navigate/toggle/sort/chips; ≥44–48 dp hit targets; usable at max font scale — across `lib/features/map/presentation/widgets/`
- [x] T066 [P] Localization + RTL: ensure pl (canonical) / en / ar keys resolve; widget tests per locale incl. an `ar` RTL assertion in `test/features/map/presentation/map_localization_test.dart`
- [x] T067 [P] Visual parity review vs the design handoff (`specs/design/map/reference/Map Screen Reference.html`, `01-map-view.png`, `02-list-view.png`, `styles.css`): verify basemap tints, teardrop pins, type, radii, spacing, sheet/list composition — manual checklist (Flutter native; no Playwright), note deviations
- [x] T068 Extend the integration test: open Map → (mock) location → select pin↔card → search-fly → toggle Lista (stagger) → filter + sort → Navigate hand-off in `integration_test/map_flow_test.dart` (deps: T027 + US2–US7)
- [x] T069 Run `flutter analyze` (must be clean) + `dart format .`; confirm widgets reference theme tokens (no magic hex/sp literals) per Constitution §X; confirm `flutter gen-l10n` is current
- [x] T070 Verify the Definition of Done (spec.md §6); confirm Home is regression-free after the T008/T009 promotions; set spec **Status** accordingly

---

## Dependencies

### Phase gating
- **Setup (T001–T004)** → before everything.
- **Foundational (T005–T018)** → blocks all user stories (engine, style, shared utils, promotions, tokens, l10n).
- **US1 (T019–T027)** → the MVP; US2–US7 build on its `MapView`/`MapScreen`/providers.
- **US2/US3/US4** layer onto US1; US3 (sheet) and US4 (filter) both feed `visiblePlaces`. **US5** (search) depends on US4's filter (out-of-filter clearing) + US3's selection + US2's engine fly. **US6** (list) depends on US3's `visiblePlaces` + US4's filter. **US7** (motion) depends on the widgets from US1/US3/US6.
- **Polish (T065–T070)** → after the stories they cover.

### Key task deps
- T013 ← T001, T005 · T019 ← T012 · T022 ← T013, T019, T020, T021 · T024 ← T022, T023
- T028 ← T001 · T031 ← T028, T029, T030, T024
- T035 ← T010, T019, T028 · T037 ← T035, T036, T034 · T038 ← T034, T037, T022 · T039 ← T037
- T043 ← T042, T019, T035 · T046 ← T044, T045
- T048 ← T011 · T050 ← T048, T009 · T051 ← T050, T034, T042, T031
- T058 ← T056, T035, T048, T057 · T059 ← T054, T055, T058
- T061 ← T020, T022 · T062 ← T037, T058 · T063 ← T059
- T068 ← T027 + US2–US7

---

## Parallel Execution Examples

### Foundational fan-out (after T001–T004)
```
T005 (style JSON) · T006 (ARB) · T007 (tokens) · T010 (distance) · T012 (cluster)   # all [P], different files
then T008 (promote recents) · T009 (promote CategoryStyle) ; T011 (place_match, after T009)
then T013 (MapEngine) ; T014 FakeMapEngine [P]
then T015 · T016 · T017 · T018 (unit tests) [P]
```

### US1 leaf widgets (after T019)
```
T020 MapPin · T021 ClusterBubble · T023 MapEmptyError   # all [P]
then T022 (MapView) → T024 (MapScreen assembly)
then T025 · T026 (widget tests) [P] ; T027 (integration scaffold)
```

### Cross-story parallel (after US1 lands)
```
Executor A: US2 location (T028–T033)
Executor B: US3 sheet/selection (T034–T041)   # share map_providers.dart — coordinate T035/T043
Executor C: US4 filter (T042–T047)
# US5 (search) after US3+US4; US6 (list) after US3+US4; US7 (motion) last
```

---

## Implementation Strategy

- **MVP = US1** (T001–T027): a guest opens Mapa and sees a real warm MapLibre map with category pins + clusters, with graceful loading/error. Shippable on its own (camera on Warsaw overview).
- **Increment 2 = US2 + US3**: location (dot/locate-me/distance) + the place sheet with selection + Navigate — the core map browse loop.
- **Increment 3 = US4 + US5**: category filtering + map search (fly-to + unified recents).
- **Increment 4 = US6**: the Lista view (toggle, sort, inline filter).
- **Increment 5 = US7** (motion polish) + **Phase 10** (a11y, i18n/RTL, visual parity, analyze/format, DoD).
- Commit after each task; keep `flutter analyze` clean throughout; keep Home green after the promotions (T008/T009).

---

## Task Completeness Checklist

- [x] Every contract has tasks + tests: `map_engine` (T013/T014/T025), `location_service` (T028/T032/T033), `place_search` (matcher T011/T016, recents T008/T018, sort T041) ; reused `maps_launcher`/`place_repository` (no new tasks, exercised in T039/T040 + US1)
- [x] Every entity/state has a task: runtime state — view (T054), activeCategories (T042), sortMode (T054), selection (T034), search (T048), location (T028); utils — distance (T010), match (T011), cluster (T012); reused shared `Place`/`Category`/`placesProvider`
- [x] Every spec FR mapped: 001/002/003 (T024/T013/T019), 004/005 (T020/T021/T022), 006/014 (T028/T029/T030/T031), 007/008/009/010/013 (T034/T035/T036/T037/T038), 011/012 (T042/T044/T045/T046), 015 (T056/T058), 016/017/018 (T048/T050/T051), 019/020/021 (T058/T057/T059), 022 (T039), 023 (T023/T024), 024 (T061/T062/T063), 025/026 (T006/T065/T066), 027 (lean — enforced across T036/T056 + tests)
- [x] Every TC covered by ≥1 test: TC-1/2/3/4 (T025/T026/T027), 5 (T033), 6/14/14a/16 (T040), 7/13 (T047), 8/8b (T052), 9 (T053), 10/11/12 (T060), 17/23 (T026), 18/19 (T064), 20 (T066), 21 (T065), 15 (T040/T068)
- [x] Mandatory test types present: unit (T015–T018, T041), widget (T025/T026, T033, T040, T047, T052/T053, T060, T064, T066), integration (T027, T068)
- [x] Each task has an exact file path; `[P]` tasks touch different files
- [x] User-story phases carry `[US#]`; Setup/Foundational/Polish do not
