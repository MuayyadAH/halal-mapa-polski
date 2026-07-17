# Tasks: Home Screen (v1)

**Feature**: `002-home-screen` · **Input**: design docs in `specs/002-home-screen/` (plan.md, spec.md, research.md, data-model.md, contracts/)
**Tech**: Flutter / Dart, Riverpod, go_router, `dio` (existing) + new `url_launcher`, `shared_preferences`, `csv`. Live data from the published Google Sheet via a **shared** place layer (`lib/core/places/`).

Tests are included (Constitution §4 + spec §6 require unit + widget + integration). Format: `- [ ] [TaskID] [P?] [Story?] Description + file path`. `[P]` = parallelizable (different file, no incomplete deps).

---

## User Stories (priority order, from spec.md)

- **US1 (P1, MVP)** — Open Home and see real places: shell + header + resting search + shared sheet fetch + Featured card row + mini-map (static) + loading/empty/error states.
- **US2 (P2)** — Filter by category: chips from the categories present, filter the Featured row in place, empty message.
- **US3 (P3)** — Open a place in Google Maps: card-body tap → external maps.
- **US4 (P4)** — Bookmark places: guest bookmark toggle, persists locally, Saved-tab-readable.
- **US5 (P5)** — Living mini-map + entrance motion: ambient drift/float/pulse/sheen + entrance stagger + reduced-motion.

---

## Phase 1: Setup

- [x] T001 Add `url_launcher`, `shared_preferences`, `csv` to dependencies in `pubspec.yaml` and run `flutter pub get` (repo root)
- [x] T002 [P] Ensure a Riverpod `dioProvider` (`Provider<Dio>`) is exposed for reuse by the place repository in `lib/core/api/dio_client.dart` (add if missing)
- [x] T003 Verify implementation conflicts per plan.md: confirm the placeholder `lib/features/home/home_screen.dart` is to be replaced and that `lib/core/routing/scaffold_with_tabs.dart` and `lib/core/routing/app_router.dart` stay unchanged except the Home import path (T024)

## Phase 2: Foundational (blocking prerequisites — shared place layer, tokens, l10n)

- [x] T004 [P] Add Home + mini-map design tokens (`homeH1=26`, `homeH2=19`, `cardTitle=14`, `chip=13`; `homeBgGradientEnd=#E9DDC3`; `HmpMap` palette `mapBase/mapBlock/mapPark/mapRiver/mapRoad`) to `lib/core/theme/tokens.dart`
- [x] T005 [P] Add Home ARB keys (H1 parts + "halal" accent, subtitle, search placeholder, chip labels for Restauracje/Meczety/Sklepy/Cmentarze + "Wszystko", "Polecane miejsca", "Otwórz mapę", mini-map count as ICU plural, empty message, fetch error + retry) to `lib/l10n/app_pl.arb` (canonical), `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`; run `flutter gen-l10n`
- [x] T006 [P] Create the canonical `Category` enum (restaurant, masjid, grocer, butcher, shop, cemetery) + `Category? parsePolish(String)` (Meczet→masjid, Sklep→shop, Restauracja→restaurant, Cmentarz→cemetery; unknown→null) in `lib/core/places/domain/category.dart`
- [x] T007 [P] Create the `Place` value object (`id`, `name`, `category`, `lat`, `lng`, `comment?`, `mawaqitLink?`) with derived `id = '<name>|<lat>|<lng>'` and `==`/`hashCode` in `lib/core/places/domain/place.dart`
- [x] T008 [P] Create `kPlacesSheetId` (public sheet id, `--dart-define`-overridable) in `lib/core/places/data/places_config.dart`
- [x] T009 Create `sharedPreferencesProvider` in `lib/core/storage/prefs_provider.dart` and bootstrap `await SharedPreferences.getInstance()` with a `ProviderScope` override in `lib/main.dart`
- [x] T010 Implement `parsePlacesCsv` (header-name mapping, skip malformed/unknown-category rows) + `PlaceRepository`/`GoogleSheetPlaceRepository` (dio fetch of the sheet CSV, `csv` parse, cache last-good CSV to `shared_preferences`, fallback on failure) + `placeRepositoryProvider` + shared `placesProvider` (`FutureProvider<List<Place>>`) in `lib/core/places/data/place_repository.dart` (deps: T002, T006, T007, T008, T009) — per `contracts/place_repository.md`
- [x] T011 [P] Create the `categoryStyle` helper (`Category` → `cat-*` token color, glyph, ARB label key) in `lib/features/home/presentation/widgets/category_style.dart` (dep: T006)
- [x] T012 [P] Unit test `parsePlacesCsv`: well-formed CSV, malformed/unknown rows skipped, reordered columns, quoted fields/commas in `test/core/places/place_repository_parse_test.dart`
- [x] T013 [P] Unit test `Category.parsePolish` mapping + unknown→null in `test/core/places/category_test.dart`
- [x] T014 [P] Unit test `GoogleSheetPlaceRepository` cache + fallback (mock `Dio`, `SharedPreferences.setMockInitialValues`) in `test/core/places/place_repository_fetch_test.dart`

---

## Phase 3: US1 — Open Home and see live places (P1, MVP)

**Goal**: A guest opens Strona and sees real places from the sheet (or a graceful loading/error state). **Independent test**: with a mocked `placesProvider`, Home renders the Featured cards + mini-map count; on mocked failure it shows the error state + retry.

- [x] T015 [US1] Create the pure `selectFeatured(List<Place> places, {int cap})` deterministic varied-sample selector (round-robin by category, canonical order) in `lib/features/home/presentation/state/home_notifier.dart`
- [x] T016 [US1] Create `homeProvider` (Notifier) deriving `featuredAll`/`featuredVisible`/`availableCategories`/`totalCount` from `placesProvider` data in `lib/features/home/presentation/state/home_notifier.dart` (deps: T010, T015)
- [x] T017 [P] [US1] Create `SectionHeader` (serif h2 + optional right-side count) in `lib/features/home/presentation/widgets/section_header.dart` (dep: T004)
- [x] T018 [P] [US1] Create `HomeHeader` (RichText H1 "Miejsca *halal* w Polsce" with italic colored "halal" + subtitle, ARB-driven) in `lib/features/home/presentation/widgets/home_header.dart` (deps: T004, T005)
- [x] T019 [P] [US1] Create resting `HomeSearchBar` (placeholder from ARB; tap → search stub route/no-op) in `lib/features/home/presentation/widgets/home_search_bar.dart` (deps: T004, T005)
- [x] T020 [P] [US1] Create `PlaceCard` base (category-tinted gradient placeholder, category badge via `categoryStyle`, name; bookmark + body-tap added in US3/US4) in `lib/features/home/presentation/widgets/place_card.dart` (deps: T004, T011)
- [x] T021 [P] [US1] Create `HomeSkeletons` (sand-tone shimmer cards) and `HomeErrorState` (empty + error message + retry) in `lib/features/home/presentation/widgets/home_skeletons.dart` and `lib/features/home/presentation/widgets/home_error_state.dart` (deps: T004, T005)
- [x] T022 [US1] Create `MiniMapPainter` (`CustomPainter`: tiled blocks, park/river `Path`s, road strokes using `HmpMap` tokens) in `lib/features/home/presentation/widgets/mini_map_painter.dart` (dep: T004)
- [x] T023 [US1] Create static `MiniMap` (`ClipRRect`+`Stack`: painter, sample teardrop pins incl. a masjid, dark/light glass overlay with count pill from `totalCount` + "Otwórz mapę" → `context.go('/map')`) in `lib/features/home/presentation/widgets/mini_map.dart` (deps: T022, T016)
- [x] T024 [US1] Replace the stub Home: create `lib/features/home/presentation/home_screen.dart` (parchment→sand gradient scroll; sections Header, Search, [chips slot], Mini-map, "Polecane miejsca" row; consume `placesProvider`/`homeProvider` `AsyncValue` → skeleton/empty/error/content), delete `lib/features/home/home_screen.dart`, and update its import in `lib/core/routing/app_router.dart` (deps: T016–T023)
- [x] T025 [P] [US1] Widget test: Home renders sections + Featured cards from a mocked `placesProvider`; loading→skeletons; error→error state+retry in `test/features/home/presentation/home_screen_test.dart`
- [x] T026 [P] [US1] Widget test: `PlaceCard` shows placeholder + badge + name and shows NO city/status/rating/distance in `test/features/home/presentation/widgets/place_card_test.dart`
- [x] T027 [P] [US1] Widget test: mini-map count == dataset size; tapping it routes to `/map` (mock GoRouter) in `test/features/home/presentation/widgets/mini_map_test.dart`
- [x] T028 [P] [US1] Unit test: `selectFeatured` determinism, category variety, and cap in `test/features/home/presentation/state/home_notifier_test.dart`
- [x] T029 [US1] Integration test: open Home with a mocked sheet fetch → cards render; mocked failure with no cache → error state in `integration_test/home_flow_test.dart`

---

## Phase 4: US2 — Filter by category (P2)

**Goal**: The chips reflect the categories in the data and filter the Featured row in place. **Independent test**: tapping "Meczety" shows only masjid cards; an empty category shows the message; mini-map unaffected.

- [x] T030 [US2] Create `CategoryChips` (horizontal single-select: "Wszystko" + one chip per `availableCategories`, color tile + glyph via `categoryStyle`, press feedback) in `lib/features/home/presentation/widgets/category_chips.dart` (deps: T011, T016)
- [x] T031 [US2] Add `selectCategory(Category?)` to `homeProvider` and mount `CategoryChips` in the chips slot, animating the Featured row on filter change in `lib/features/home/presentation/state/home_notifier.dart` and `lib/features/home/presentation/home_screen.dart` (deps: T030, T024)
- [x] T032 [US2] Render the empty-state message ("Brak miejsc w tej kategorii — wkrótce dodamy więcej") in the Featured section when `featuredVisible` is empty in `lib/features/home/presentation/home_screen.dart` (dep: T031)
- [x] T033 [P] [US2] Widget test: tap "Meczety" → only masjid cards; empty category → message; cities/mini-map unaffected in `test/features/home/presentation/widgets/category_chips_test.dart`

---

## Phase 5: US3 — Open a place in Google Maps (P3)

**Goal**: Tapping a place card opens it in the external maps app. **Independent test**: a card-body tap invokes the launcher with the place's coordinates (not the bookmark).

- [x] T034 [US3] Create `MapsLauncher`/`UrlMapsLauncher` (`url_launcher`, `https://www.google.com/maps/search/?api=1&query=<lat>,<lng>`, `LaunchMode.externalApplication`, browser fallback) + `mapsLauncherProvider`, with `@visibleForTesting` `placeUri()`, in `lib/core/maps/maps_launcher.dart` — per `contracts/maps_launcher.md`
- [x] T035 [US3] Wire `PlaceCard` body tap (excluding the bookmark hit area) to `MapsLauncher.openPlace` in `lib/features/home/presentation/widgets/place_card.dart` (deps: T020, T034)
- [x] T036 [P] [US3] Unit test: `placeUri` builds the coordinate URL and URL-encodes the fallback query in `test/core/maps/maps_launcher_test.dart`
- [x] T037 [P] [US3] Widget test: card-body tap invokes a mocked launcher (and the bookmark area does not) in `test/features/home/presentation/widgets/place_card_tap_test.dart`

---

## Phase 6: US4 — Bookmark places (P4)

**Goal**: A guest can bookmark a place and it persists. **Independent test**: toggle a bookmark, restart, the place is still bookmarked; the Saved tab's store holds it.

- [x] T038 [US4] Create `BookmarkRepository`/`SharedPrefsBookmarkRepository` (key `bookmarked_place_ids`) + `bookmarkRepositoryProvider` in `lib/core/places/data/bookmark_repository.dart` (dep: T009) — per `contracts/bookmark_repository.md`
- [x] T039 [US4] Create `bookmarksProvider` (`Notifier<Set<String>>`: hydrate from repo, optimistic `toggle(id)` + write-through, `isBookmarked`) in `lib/features/home/presentation/state/bookmarks_notifier.dart` (dep: T038)
- [x] T040 [US4] Add the bookmark toggle button to `PlaceCard` (28px circle, pop + fill swap, wired to `bookmarksProvider`) in `lib/features/home/presentation/widgets/place_card.dart` (deps: T020, T039)
- [x] T041 [P] [US4] Unit test: `BookmarkRepository` round-trip + overwrite via mock prefs in `test/core/places/bookmark_repository_test.dart`
- [x] T042 [US4] Extend the integration test: toggle a bookmark → restart (`reassembleApplication`/re-pump) → still bookmarked in `integration_test/home_flow_test.dart` (deps: T029, T040)

---

## Phase 7: US5 — Living mini-map + entrance motion (P5)

**Goal**: The mini-map feels alive and Home animates in, all reduced-motion-safe. **Independent test**: with animations on, ambient effects run + blocks fade up; with `disableAnimations`, everything is static (press feedback only).

- [x] T043 [US5] Add ambient controllers `mmDrift`(16s)/`mmFloat`(3.6s, staggered)/`mmPulse`(2.6s, mosque)/`mmSheen`(7s) via `AnimatedBuilder`, started only when `!MediaQuery.disableAnimations`, in `lib/features/home/presentation/widgets/mini_map.dart` (dep: T023)
- [x] T044 [US5] Add staggered entrance fade-up to Home top-level blocks (reuse 001's `FadeRiseIn`; if cross-feature import is awkward, promote it to `lib/shared/widgets/fade_rise_in.dart`), gated by reduced motion, in `lib/features/home/presentation/home_screen.dart`
- [x] T045 [P] [US5] Add press-feedback scale (`AnimatedScale` ~0.98) to `PlaceCard` and `CategoryChips` in `lib/features/home/presentation/widgets/place_card.dart` and `lib/features/home/presentation/widgets/category_chips.dart`
- [x] T046 [P] [US5] Widget test: ambient effects active normally; disabled (static) under `MediaQueryData(disableAnimations: true)` in `test/features/home/presentation/widgets/mini_map_motion_test.dart`
- [x] T047 [P] [US5] Widget test: entrance stagger present; reduced motion renders final state in `test/features/home/presentation/home_screen_motion_test.dart`

---

## Phase 8: Polish & Cross-Cutting

- [x] T048 [P] Accessibility pass: `Semantics` labels on category glyphs, bookmark, and "Otwórz mapę"; ≥44px hit targets on chips/bookmark/cards; usable at max font scale — across `lib/features/home/presentation/widgets/`
- [x] T049 [P] Localization completeness + RTL: ensure pl (canonical) / en / ar keys resolve; widget tests per locale incl. RTL assertion for `ar` in `test/features/home/presentation/home_localization_test.dart`
- [x] T050 [P] Visual parity review against the handoff (`specs/design/home_page/handoff_home_v1/Home Screen v1.html`, `styles.css`, `HOME_V1_IMPLEMENTATION_BRIEF.md`): verify colors/tokens, type scale, radii, shadows, spacing, mini-map composition — manual checklist (Flutter native; no Playwright), note deviations
- [x] T051 Run `flutter analyze` (must be clean) and `dart format .`; confirm widgets reference theme tokens (no magic hex/sp literals) per Constitution §X
- [x] T052 Verify the Definition of Done checklist (spec.md §6) is satisfied and set spec **Status** accordingly

---

## Phase 9: US6 — Search-active overlay & Pull-to-refresh (handoff_search_refresh)

**Goal**: Tapping the search bar opens an in-place search overlay (dimmed header peek, focused field, three suggestion groups) and the home scroll supports pull-to-refresh. **Independent test**: search bar tap → overlay; typing filters; suggestion tap → maps + close; pull → re-fetch. All animations reduced-motion-safe.

- [x] T053 [US6] Add ARB keys (searchCancel, searchGroupRecent/Suggestions/Categories, searchNoResults, searchRefill, refreshCaption) to pl/en/ar; `flutter gen-l10n`
- [x] T054 [US6] Create `RecentSearchesRepository` + `SharedPrefsRecentSearchesRepository` (key `recent_searches`) + provider in `lib/features/home/data/recent_searches_repository.dart`
- [x] T055 [US6] Create search state (`searchActiveProvider`, `searchQueryProvider`, `searchSuggestionsProvider` name-filter, `recentSearchesProvider` add/dedup/cap) in `lib/features/home/presentation/state/search_notifier.dart`
- [x] T056 [US6] Create `SearchView` overlay (dimmed guest-header peek + IgnorePointer, focused field w/ native caret + "Anuluj", Ostatnie/Podpowiedzi/Kategorie groups, staggered entrance, reduced-motion) in `lib/features/home/presentation/widgets/search_view.dart`
- [x] T057 [US6] Wire `HomeSearchBar.onTap` → open search; render `SearchView` when `searchActive`; suggestion tap → `MapsLauncher` + record recent + close; category chip → select + close in `home_search_bar.dart` + `home_screen.dart`
- [x] T058 [US6] Wrap the home scroll in `RefreshIndicator` (styled cocoa) backed by `ref.refresh(placesProvider.future)` in `lib/features/home/presentation/home_screen.dart`
- [x] T059 [P] [US6] Unit tests: recent-searches repo round-trip; `searchSuggestionsProvider` name-filter/limit; `RecentSearches` dedup/cap/blank in `test/features/home/data/recent_searches_repository_test.dart` + `test/features/home/presentation/state/search_notifier_test.dart`
- [x] T060 [P] [US6] Widget tests: search bar opens overlay; Anuluj closes; typing filters + suggestion tap opens maps & closes; pull-to-refresh re-fetches in `test/features/home/presentation/search_flow_test.dart`

---

## Dependencies

### Phase gating
- **Setup (T001–T003)** → before everything.
- **Foundational (T004–T014)** → blocks all user stories (shared data layer, tokens, l10n).
- **US1 (T015–T029)** → the MVP; US2–US5 build on its widgets/state.
- **US2/US3/US4** are largely independent of each other (all depend on US1's `PlaceCard`/`homeProvider`); can proceed in parallel by different executors after US1.
- **US5** depends on US1's `MiniMap`/`home_screen` (T023/T024) and US2's chips (T045 touches `category_chips.dart`).
- **Polish (T048–T052)** → after the stories it covers.

### Key task deps
- T010 ← T002, T006, T007, T008, T009
- T016 ← T010, T015 · T023 ← T022, T016 · T024 ← T016–T023
- T031 ← T030, T024 · T032 ← T031
- T035 ← T020, T034
- T039 ← T038 · T040 ← T020, T039 · T042 ← T029, T040
- T043 ← T023 · T044 ← T024 · T045 ← T020, T030

---

## Parallel Execution Examples

### Foundational fan-out (after T001–T003)
```
T004 (tokens) · T005 (ARB) · T006 (Category) · T007 (Place) · T008 (config)   # all [P], different files
then T009 → T010 (repository) ; T011 (category_style) [P after T006]
then T012 · T013 · T014 (unit tests) [P]
```

### US1 leaf widgets (after T016)
```
T017 SectionHeader · T018 HomeHeader · T019 SearchBar · T020 PlaceCard · T021 Skeletons/Error   # all [P]
then T022 → T023 (mini-map) → T024 (home_screen assembly)
then T025 · T026 · T027 · T028 (tests) [P]
```

### Cross-story parallel (after US1 lands)
```
Executor A: US2 (T030–T033)
Executor B: US3 (T034–T037)
Executor C: US4 (T038–T042)
# US5 (T043–T047) after MiniMap/home_screen + chips are stable
```

---

## Implementation Strategy

- **MVP = US1** (T001–T029): a guest opens Home and sees real places from the live sheet, with graceful loading/error. Shippable on its own.
- **Increment 2 = US2 + US3** (filter + open-in-maps): the core browse loop.
- **Increment 3 = US4** (bookmarks): guest save.
- **Increment 4 = US5** (motion polish) + **Phase 8** (a11y, i18n/RTL, visual parity, analyze/format, DoD).
- Commit after each task; keep `flutter analyze` clean throughout.

---

## Task Completeness Checklist

- [x] Every contract has tasks + tests: `place_repository` (T010, T012, T014), `bookmark_repository` (T038, T041), `maps_launcher` (T034, T036)
- [x] Every entity has a task: `Place` (T007), `Category` (T006); local Bookmark store (T038/T039)
- [x] Every spec FR mapped: FR-001/002 (T024), 003 (T018), 004 (T019), 005/006/007 (T006/T011/T030/T031), 008–011 (T022/T023/T016), 012/013 (T020/T015/T016), 014 (T038–T040), 015 (T034/T035), 016/017 (T010 shared), 018 (T017), 019/020 (T044/T043/T045), 021 (T005/T049), 022 (T048), 023 (lean — enforced across T020/T024 + T026)
- [x] Every TC covered by ≥1 test (T012–T014, T025–T029, T033, T036–T037, T041–T042, T046–T047, T049)
- [x] Mandatory test types present: unit (T012–T014, T028, T036, T041), widget (T025–T027, T033, T037, T046–T047, T049), integration (T029, T042)
- [x] Each task has an exact file path; `[P]` tasks touch different files
- [x] User-story phases carry `[US#]`; Setup/Foundational/Polish do not
