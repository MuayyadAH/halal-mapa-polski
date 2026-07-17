# Implementation Plan: Map Screen (v1)

**Branch**: `003-map-screen` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

## Summary

Build the launch (v1) **Mapa** tab as a Flutter feature at `lib/features/map/`, rendered full-bleed inside the existing `/map` branch of the 5-tab `StatefulShellRoute` (no own dock — FR-001). A `Stack` puts a **real interactive MapLibre basemap** (custom warm cocoa/cream style) under pinned chrome: a search bar, a **Map ↔ Lista** segmented toggle, single-shortcut **category chips**, a **locate-me FAB**, and a draggable **bottom place sheet** of horizontally-scrolling mini-cards. A **Lista** view cross-fades to a staggered, scrollable list of the same places with a live inline filter and a sort pill (Najbliższe / Alfabetycznie / Wg kategorii). It is deliberately lean — no ratings, verification badges, opening hours/status, addresses, or walk-time, because the launch data (the shared Google Sheet) has none of them — but it adds the one capability Home skipped: **device location** (user dot, locate-me, distance, "Najbliższe" sort), requested only-while-using and approximate (Constitution §1.7), with a graceful Warsaw-overview fallback.

Place data reuses the **shared layer** (`lib/core/places/` `Place`/`Category`/`PlaceRepository`/`placesProvider`) — the same source Home consumes, swappable to the backend later (FR-003). Pins are **Flutter-widget overlays** projected from `lat/lng` (R3) so the teardrop shape, staggered drop, selection scale, and pulse ring match ANIMATIONS.md; clustering is computed in Dart (R4). Navigate hands off to external Google Maps via the shared `MapsLauncher` (FR-022). Search reuses a **promoted, shared** recents store + a new accent-insensitive matcher (R8); `CategoryStyle` is promoted so pins/cards reuse colour/glyph/label (R9).

**Two new dependencies (PO-approved, Clarify R1): `maplibre_gl`** (real map, Constitution §I mandate) and **`geolocator`** (device location). Both are wrapped behind testable abstractions (`MapEngine`, `LocationService`) so the bulk of the UI is verifiable headless with a fake engine.

---

## Implementation Conflicts

**Status**: No Conflicts Found (small, additive promotions only)

- `lib/features/map/map_screen.dart` is a placeholder stub → **replaced** by the real Map (Stack: MapLibre + chrome; no AppBar, no own dock).
- `app_router.dart` `/map` branch and `scaffold_with_tabs.dart` (5-tab nav) **unchanged** (Map still mounts at `/map`).
- **Promotions (no behavior change, update imports)**: `recent_searches_repository.dart` → `lib/core/search/`; `CategoryStyle` ext → `lib/core/places/presentation/`. Home updated to import the new paths (R8/R9). Home's case-only search matcher is left as-is (Map uses the new accent-insensitive matcher).
- `pubspec.yaml` gains `maplibre_gl`, `geolocator`; `assets/map_styles/*.json` stubs completed; Android manifest + iOS Info.plist gain location/tiles entries.
- `lib/l10n/app_*.arb` gains ~13 Map keys/locale (additive); `tokens.dart` gains a few basemap/pin tokens (user-dot blue, dark-basemap variants).
- `main.dart` unchanged (SharedPreferences bootstrap from 002 already present).
- No conflict with 001/002 (disjoint feature module; reuses shared `placesProvider`, `MapsLauncher`, recents, prefs, permissions, entrance primitive).

**Conflict Check Date**: 2026-05-31 · **Checked Against**: `specs/001-onboarding-flow/plan.md`, `specs/002-home-screen/plan.md`.

---

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter 3.24+ (stable; per `pubspec.yaml`)
**Primary Dependencies**:
- `flutter_riverpod` 3.3.1 — feature state (view/filter/sort/selection/search), `locationProvider`, derived `visiblePlaces`/`clusterLayer`; shared `placesProvider`
- `go_router` 17.2.3 — existing `/map` branch of the 5-tab shell (unchanged)
- **`maplibre_gl`** (NEW) — real interactive map + custom warm style (Constitution §I/§II.4)
- **`geolocator`** (NEW) — device location (user dot, locate-me, distance, nearest sort)
- `permission_handler` 12.0.1 (existing) — location-when-in-use prompt via `PermissionsService`
- `url_launcher` 6.3.1 (existing, via shared `MapsLauncher`) — Navigate hand-off (FR-022)
- `dio` 5.6 + `csv` 6.0 (existing, via shared `PlaceRepository`) — Google-Sheet fetch/parse
- `shared_preferences` 2.3.2 (existing) — unified recents (`recent_searches`) + places cache
- `flutter_localizations` + `intl` 0.20.2 — ARB localization incl. ICU plural (Polish 3-form count) + distance number formatting
- Fonts bundled: Lora, Plus Jakarta Sans, Amiri, JetBrains Mono

**Storage** (all `shared_preferences`, non-sensitive): `recent_searches` (unified, promoted), `places_cache_csv` (reused). Device location is **session-only** (not persisted).

**Data source**: shared published Google Sheet via `placesProvider` (no Map-private loader). Map tiles via the custom MapLibre style (tile provider per R17/ADR). The sheet fetch + tile fetch + OS location are the only network/OS touchpoints — **no analytics/tracking** (§1.7).

**Testing**:
- Unit: haversine + `formatDistance`; `foldPl`/`matchesQuery` (accent-insensitive); `clusterPlaces`; sort comparators; `visiblePlaces`/`activeCategories` derivations
- Widget: Map screen with **FakeMapEngine** (pins overlay, selection sync, sheet content/order, list rows, search overlay, filter sheet, sort menu) × {pl,en,ar incl. RTL} × {motion on/off} + loading/error
- Integration: open Map → (mock) location → select pin↔card → search-fly → toggle Lista (stagger) → filter+sort → Navigate hand-off (real map on device)

**Target Platform**: iOS 13+ / Android API 23+ (Pixel 7 / API 34 reference). Confirm MapLibre min-SDK floor at setup.
**Project Type**: mobile (Flutter; no backend in repo)

**Performance Goals**: map interaction + pin-drop/selection ≥ 60 fps with the launch dataset (NFR-001); first frame (basemap + chrome) ≤ ~1s, interactive during fetch + while a location fix is pending (NFR-004)

**Constraints**: lean-to-data (no hours/address/walk/ratings/verification — FR-013/FR-027); approximate, while-in-use location only (§1.7/NFR-005); custom MapLibre style only, no vanilla fallback (§II.4/FR-002); WCAG 2.1 AA incl. RTL (NFR-002/003); Polish canonical ARB + tokens only (§1.5/§X)

**Scale/Scope**: ~12–16 widgets (map surface, pin/cluster overlay, search bar, toggle, chips, FAB, sheet + mini-card, list + row, sort menu, filter sheet, search overlay, empty/error); 2 new core abstractions (`MapEngine`, `LocationService`) + utils (cluster, distance, match); ~8 feature providers; 3 locales (~13 keys each); "hundreds of places" eventually (modest list today)

---

## Constitution Check

**Applicable**: frontend + universal. **Sources**: `constitution.md` §1.1–1.7/§2/§4; `constitution-frontend.md` §I–§XIII.

### Compliance Checklist
- [x] **§1.1**: Feature-first — Map under `lib/features/map/`; shared engine/location/search/category-style under `lib/core/` (cross-feature plumbing)
- [x] **§1.2**: Naming conventions (snake_case files, PascalCase types, etc.)
- [x] **§1.3**: Error handling — fetch failure → cache/empty/error+retry (reused); location denied/slow → graceful Warsaw fallback, no crash; bad rows skipped by shared parser
- [x] **§1.5 / FR-025**: Localization & RTL — ARB only; `EdgeInsetsDirectional`; ar RTL tested; distances via `intl`
- [x] **§1.6**: Guest-first; no login wall; verification/ratings intentionally absent (curated v1 — Complexity Tracking)
- [x] **§1.7 / NFR-005**: No analytics/trackers; location only-while-using + **approximate**; no background/precise; session-only
- [x] **§2**: Tiles/provider key via `--dart-define` (never committed); no secrets in code; recents/cache non-sensitive (not secure storage)
- [x] **§4 / §XII**: Unit + widget + integration tests; MapEngine abstraction makes UI testable headless
- [x] **Frontend §I.1**: Stack — Riverpod/go_router/intl/dio/url_launcher/shared_preferences/permission_handler present; **adds `maplibre_gl`, `geolocator`** (recorded in §I.1)
- [x] **§II / §X / §II.4**: Tokens from `tokens.dart` (+ pin/basemap additions); custom warm MapLibre style; no magic literals, no vanilla style
- [x] **§III**: Implements/uses `MapPin` (teardrop) + `ClusterBubble`, translucent `SearchBar`, `CategoryPill`, `AppBottomSheet`
- [x] **§IV.4**: Implements MapLight (+ dark style via tokens); MapPeek (sheet), SearchSuggest (overlay), Filters (sheet)
- [x] **§V**: pl/en/ar; Polish canonical & verbatim
- [x] **§VI**: pin drop/pulse, sheet, list stagger, view cross-fade per ANIMATIONS.md; reduced-motion respected (FR-024)
- [x] **§IX**: Riverpod only
- [x] **§XI**: a11y — pin/control labels, ≥44 px, font-scale, RTL; basemap contrast checked
- [x] **§XIII**: no hardcoded strings, no `EdgeInsets.only(left/right)`, no magic literals, no logic in widgets; icon set (no hand-rolled SVG) — teardrop is a styled container, glyphs from category set

**Violations**: two intentional/documented — (1) lean-v1 omits ratings/verification/hours/address (no system/data yet); (2) two new deps (`maplibre_gl`, `geolocator`) are PO-approved necessities, not avoidable. See Complexity Tracking.

---

## Project Structure

### Documentation (this feature)
```
specs/003-map-screen/
├── spec.md · plan.md · research.md · data-model.md · quickstart.md
├── contracts/
│   ├── map_engine.md          # MapLibre abstraction (shared, fakeable)
│   ├── location_service.md     # geolocator wrapper + distance utils (shared)
│   └── place_search.md         # accent-insensitive matcher + promoted recents + sort
├── checklists/requirements.md
└── tasks.md                    # Phase 2 — NOT created by /plan
```

### Source Code (repository root)
```
lib/
├── core/
│   ├── map/
│   │   ├── map_engine.dart                 # NEW — MapEngine interface + MapLibreEngine impl (R2/R3)
│   │   └── map_config.dart                 # existing — style URL selection (reused)
│   ├── location/
│   │   ├── location_service.dart           # NEW — LocationService (geolocator) + providers (R5)
│   │   └── distance.dart                   # NEW — haversine + formatDistance (R6)
│   ├── search/
│   │   ├── recent_searches_repository.dart # MOVED from features/home/data (R8) — unified recents
│   │   └── place_match.dart                # NEW — foldPl + matchesQuery (accent-insensitive, R8)
│   ├── places/
│   │   ├── domain/{place,category}.dart     # existing (reused)
│   │   ├── data/{place_repository,places_config,bookmark_repository}.dart  # existing (reused)
│   │   └── presentation/category_style.dart # MOVED from features/home (R9) — colour/glyph/label
│   ├── maps/maps_launcher.dart             # existing — Navigate hand-off (reused)
│   ├── permissions/permissions_service.dart # existing — location prompt (reused)
│   ├── routing/{app_router,scaffold_with_tabs}.dart  # unchanged
│   └── theme/tokens.dart                    # MODIFIED — user-dot blue, dark-basemap + pin tokens
├── features/map/
│   ├── map_screen.dart                      # REPLACES stub — Stack(map + chrome), view cross-fade
│   └── presentation/
│       ├── state/
│       │   ├── map_view_notifier.dart       # MapView (map|list)
│       │   ├── map_filter_notifier.dart     # activeCategories (Set), sortMode
│       │   ├── map_selection_notifier.dart  # selectedPlaceId
│       │   ├── map_search_notifier.dart     # mapSearchActive/Query (map-local)
│       │   └── map_providers.dart           # visiblePlaces, categoryFiltered, clusterLayer, searchMatches, distanceFor
│       └── widgets/
│           ├── map_view.dart                # MapEngine surface + pin/cluster overlay
│           ├── map_pin.dart · cluster_bubble.dart · user_dot.dart
│           ├── map_search_bar.dart · view_toggle.dart · map_category_chips.dart
│           ├── locate_me_fab.dart · place_sheet.dart · mini_card.dart
│           ├── list_view_body.dart · list_row.dart · sort_pill.dart
│           ├── filter_sheet.dart · map_search_overlay.dart   # reuses core/search
│           └── map_empty_error.dart
├── l10n/app_{pl,en,ar}.arb                   # MODIFIED — ~13 keys each
└── (features/home imports updated for moved recents + CategoryStyle)

pubspec.yaml                                  # MODIFIED — add maplibre_gl, geolocator
android/app/src/main/AndroidManifest.xml      # MODIFIED — ACCESS_COARSE_LOCATION, INTERNET
ios/Runner/Info.plist                         # MODIFIED — NSLocationWhenInUseUsageDescription
assets/map_styles/halalmap-{light,dark}.json  # COMPLETED — custom warm style (stubs today)

test/
├── core/
│   ├── location/{distance,location_service}_test.dart
│   ├── search/{place_match,recent_searches_repository}_test.dart
│   └── map/cluster_test.dart
└── features/map/
    └── presentation/{map_screen,state/*,widgets/*}_test.dart   # FakeMapEngine + FakeLocationService
integration_test/map_flow_test.dart
```

**Structure Decision**: The map **engine, location, search, and category styling are shared** under `lib/core/` (the Map needs them and so will later screens), keeping `lib/features/map/` presentation-only. This continues the 002 unification (one place model/loader, two screens) and adds three more shared primitives the rest of the app will reuse. Pins are a Flutter-widget overlay (R3) behind a `MapEngine` interface (R2) so the map is brand-styleable, animatable, and testable.

---

## Phase 0: Outline & Research
See [`research.md`](./research.md): R1 (mount in `/map` branch, view = state), R2 (MapLibre via `maplibre_gl` behind a `MapEngine` abstraction), R3 (Flutter-widget pin overlay projected from lat/lng), R4 (Dart-side clustering), R5 (`geolocator` + `LocationService`, approximate/while-in-use, Warsaw fallback), R6 (haversine + adaptive m/km format), R7 (one shared `activeCategories` set), R8 (promote recents + accent-insensitive matcher to `lib/core/search/`), R9 (promote `CategoryStyle`), R10 (animations → core primitives, reduced-motion gated), R11 (DraggableScrollableSheet), R12 (sort comparators), R13 (Riverpod shapes), R14 (ARB keys + plural), R15 (testing via FakeMapEngine), R16 (deps + platform config), R17 (tile provider → ADR, MapTiler recommended). **No NEEDS CLARIFICATION remain**; R17 is an explicitly-deferred ADR choice that does not block design/tasks.

## Phase 1: Design & Contracts
- **Data model** — [`data-model.md`](./data-model.md): reused shared `Place`/`Category`/`placesProvider`; new runtime state (view, activeCategories, sortMode, selection, search, location); derived providers (categoryFiltered, searchMatches, visiblePlaces, clusterLayer, distanceFor); pure utils (cluster, distance, match, camera consts). No new persisted entity (only the promoted `recent_searches`).
- **Contracts** — [`map_engine.md`](./contracts/map_engine.md) (MapLibre abstraction + FakeMapEngine), [`location_service.md`](./contracts/location_service.md) (geolocator wrapper + distance utils + FakeLocationService), [`place_search.md`](./contracts/place_search.md) (accent matcher + promoted recents + sort). Shared `place_repository.md` / `maps_launcher.md` reused from 002 (no new contract).
- **Stack constitution update** — `constitution-frontend.md` §I.1 marks Map = `maplibre_gl` (chosen) and adds `geolocator`; notes location accuracy default. Token additions in `tokens.dart`.
- **Post-design re-check**: passes; the two documented items (lean-v1 omissions; two PO-approved deps) stand.

## Phase 2: Task Planning Approach
*Describes what `/ai1st-dev-tasks` will do — not executed here.*

**Ordering** (dependency-respecting):
1. pubspec: add `maplibre_gl`, `geolocator`; `flutter pub get`; Android manifest + iOS Info.plist entries; complete `assets/map_styles/*.json`
2. ARB Map keys + `flutter gen-l10n`
3. **Promotions**: move `recent_searches_repository` → `core/search/`; move `CategoryStyle` → `core/places/presentation/`; fix Home imports (verify Home still builds/tests green)
4. Core utils: `distance.dart` (haversine + format), `place_match.dart` (foldPl + matchesQuery), `cluster` function, camera consts + token additions
5. Core abstractions: `LocationService` (+ providers); `MapEngine` interface + `MapLibreEngine` impl + `FakeMapEngine`
6. Feature state: `map_view`, `map_filter` (activeCategories+sort), `map_selection`, `map_search` notifiers; `map_providers` derivations
7. Leaf widgets: `map_pin`, `cluster_bubble`, `user_dot`, `map_search_bar`, `view_toggle`, `map_category_chips`, `locate_me_fab`, `mini_card`, `list_row`, `sort_pill`, `map_empty_error`
8. Composite widgets: `map_view` (engine + overlay + drop/pulse anim), `place_sheet` (draggable + horizontal mini-cards), `list_view_body` (stagger), `filter_sheet`, `map_search_overlay`
9. `map_screen.dart` assembly (Stack + view cross-fade; AsyncValue → loading/empty/error; selection sync; search-fly + out-of-filter clear)
10. Tests: unit → widget (FakeMapEngine + FakeLocationService, ×locales, motion on/off, loading/error) → integration (`map_flow_test.dart`)

Mark `[P]` for independent files (leaf widgets, util tests). **Estimated**: ~36–44 tasks. Include a task to verify no implementation conflict (Home regression after promotions).

---

## Dependencies Analysis

### Prerequisites
| Dependency | Source | Status | Notes |
|------------|--------|--------|-------|
| 5-tab shell + `/map` branch | scaffold/001 | Required | Map renders inside (unchanged) |
| Shared `placesProvider` (`Place`/`Category`/`PlaceRepository`) | 002 | Required | Pins/sheet/list data source |
| Shared `MapsLauncher` | 002 | Required | Navigate hand-off (FR-022) |
| `recent_searches` store + provider | 002 | Required | Promoted to core; unified recents |
| `CategoryStyle` ext | 002 (home) | Required | Promoted to core; pin colour/glyph/label |
| `PermissionsService` | 001 scaffold | Required | Location prompt |
| Entrance primitive (`FadeRiseIn`/`EntranceController`) | 001/002 | Optional | Reused for list stagger; promote to `lib/shared/` if needed |
| `tokens.dart` (+ category tints, HmpMap palette) | scaffold/002 | Required | Extended (pin/dark-basemap) |
| **`maplibre_gl`, `geolocator`** | THIS plan | Required | Added to pubspec |
| **Map tiles provider/key** | THIS plan (R17/ADR) | Required (runtime) | `--dart-define`; recommended MapTiler |

### Provides (to other features)
| Output | Used By | Description |
|--------|---------|-------------|
| `MapEngine` (MapLibre wrapper) | Place detail map, Submit drop-pin, MasjidDetail | Reusable real-map surface + projection |
| `LocationService` + distance utils | Home (distance later), Submit, prayer-times city resolve | Shared, privacy-correct location |
| Shared `place_match` (accent matcher) | Home search upgrade, Saved/Submit search | One matcher across the app |
| Promoted `RecentSearchesRepository` | Home (unified) + any search surface | One recents history |
| Promoted `CategoryStyle` | Saved, Submit, Place detail | One colour/glyph/label mapping |
| `MapPin`/`ClusterBubble` widgets | Place detail, Explore/CityDetail maps | Reusable map primitives |

---

## Work Streams
- [x] **[UI]** — feature widgets/state + shared map/location/search primitives (single Flutter stream)
- [x] **[TEST]** — unit + widget (FakeMapEngine/FakeLocationService) + integration (rolls up with [UI])
- [x] **[INFRA]** — pubspec deps + Android/iOS platform config + map tiles key/ADR (small, front-loaded)
- [ ] [API]/[DB]/[INT] — N/A (no backend; key-value prefs only; sheet + tiles are read-only)

---

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Lean-v1 omits ratings/verification/hours/address (diverges from §1.6/§3 fuller trust surface and parts of the design) | No verification system and no hours/address data at launch | Faking trust/status/address would mislead users; restored as the sheet/backend grows (Deferred Decisions) |
| Two new deps (`maplibre_gl`, `geolocator`) | §I mandates MapLibre real map; PO approved live location (user dot/locate-me/distance/nearest) | flutter_map/google_maps break the brand mandate; no location → no dot/distance/nearest (core to the design). Both wrapped behind testable abstractions |
| Flutter-widget pin overlay (vs native symbols) | Teardrop shape + counter-rotated glyph + staggered drop + pulse + selection scale per ANIMATIONS.md | Native `SymbolLayer` can't animate pins to spec; mitigated by viewport-cull + Dart clustering |
| Two file promotions (recents, CategoryStyle) into `lib/core/` | Map must reuse them without a feature→feature import (§1.1) | Duplicating (breaks DRY) or importing from Home (feature coupling) are worse |

---

## Use Case Specific NFRs

### Performance
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Map interaction + pin drop/selection | ≥ 60 fps | DevTools timeline, Pixel 7 (NFR-001) |
| First frame (basemap + chrome) | ≤ ~1s; interactive during fetch & pending location | Integration + manual (NFR-004) |

### Reliability
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Location denied/slow | graceful Warsaw overview; no crash/block | Widget (FakeLocationService) + integration |
| Fetch failure | cache shown, else empty/error+retry | Unit (repo, reused) + widget (error state) |

### Accessibility / Localization
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Targets / labels | ≥44–48 px; pin + icon-only labels | Widget tests |
| Locale + RTL | pl/en/ar incl. RTL | Widget tests per locale (NFR-002) |
| Count plural | Polish 3-form "N miejsc" | Widget test at N=1,2,5,22 |
| Basemap contrast | WCAG AA on warm palette | Manual/contrast check (NFR-003) |

---

## Acceptance Criteria

### BRD Traceability
No BRD; [`spec.md`](./spec.md) is canonical (FR-001…FR-027, NFR-001…005, TC-1…TC-23). Design: `specs/design/map/` (README, PROMPT, ANIMATIONS). Data: shared Google Sheet.

### Shell, engine & basemap
- [FR-001] Map = `/map` tab content inside the 5-tab shell; no own dock (TC-1)
- [FR-002][DS-§II.4] Real MapLibre map, custom warm style, pan/zoom; not synthetic, not vanilla (TC-2)
- [FR-003] Loads from the shared `placesProvider` (no private loader) (TC-17)

### Pins, cluster, location
- [FR-004] Teardrop category pins with upright glyph (TC-3)
- [FR-005] Dart-clustered count bubbles; tap zooms/expands (TC-4)
- [FR-006][NFR-005] User-location dot + Warsaw fallback; approximate/while-in-use (TC-5)
- [FR-014] Locate-me FAB recenters; re-prompt/no-op if denied (TC-5)

### Sheet, selection & content
- [FR-007] Bottom sheet = visible places, nearest-first/A→Z, header count (TC-16)
- [FR-008][FR-010] Pin↔card bidirectional selection (scale 1.18 + pulse) (TC-6)
- [FR-009][FR-015] Card/row = glyph+name+category(+comment+distance); distance m/km locale-formatted; selected treatment (TC-14/TC-14a)
- [FR-013][FR-027] No status/address/walk/ratings/verification/Add/login; Mawaqit link on mosques (TC-14/TC-22)

### Views, search, filter, sort
- [FR-021][FR-024] Map↔Lista cross-fade (~300ms) + list stagger; shared chrome stays (TC-12)
- [FR-011][FR-012] One shared `activeCategories`: chips quick-select, sheet multi-select, ≥2 → no chip active (TC-7/TC-13)
- [FR-016][FR-017] Map search overlay: full-dataset accent-insensitive match; pick out-of-filter → clear filter + select + fly (TC-8/TC-8b)
- [FR-018] Unified recents with Home (TC-9)
- [FR-019] Lista inline live filter; "Brak wyników" (TC-10)
- [FR-020] Sort Najbliższe(if located)/Alfabetycznie/Wg kategorii; no open-now (TC-11)
- [FR-022] Navigate → external Google Maps; browser fallback (TC-15)

### Resilience / motion / i18n / a11y
- [FR-023] Graceful empty/error + retry; cache when present; no analytics (TC-23)
- [FR-024] All ANIMATIONS.md motion; reduced-motion disables (TC-18/TC-19)
- [FR-025][NFR-002] ARB pl/en/ar incl. RTL; no hardcoded strings (TC-20)
- [FR-026][NFR-003] ≥44–48px, pin/icon labels, font-scale, RTL, basemap contrast (TC-21)
- [NFR-001/004] 60fps; first frame ≤~1s, interactive during fetch/location

### Testing
- [Universal §4/§XII] Unit + widget (FakeMapEngine) + integration present; each TC-1…TC-23 covered by ≥1 test

---

*Based on Constitution — see `.ai_project_memory/constitution.md` and `.ai_project_memory/constitution-frontend.md`*
