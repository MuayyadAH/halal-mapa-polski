# Phase 0 Research — Map Screen (v1)

**Feature**: `003-map-screen` · **Date**: 2026-05-31 · **Source**: [spec.md](./spec.md)
**MCP**: none available this session → all research **Manual** (code inspection + constitution + design handoff).

All `NEEDS CLARIFICATION` from Technical Context are resolved below. Spec-level product ambiguities were already closed in two `/ai1st-po-clarify` rounds; what remains here is technical approach.

---

## R1 — How the Map mounts in the app shell
- **Decision**: Replace the `MapScreen` stub; render full-bleed inside the existing `/map` branch of the 5-tab `StatefulShellRoute` (`app_router.dart`). The screen is a `Stack`: the map surface at the bottom, pinned chrome (search bar, Map↔Lista toggle, category chips, locate-me FAB, bottom place sheet) above. **Map↔Lista is internal view state, not a route.** No own dock (FR-001).
- **Rationale**: Mirrors the 002 decision (content-only inside the shell); avoids route churn; keeps deep-link surface unchanged.
- **Alternatives**: Separate `/map/list` route (rejected — toggle is a view-state cross-fade per ANIMATIONS §6, not navigation); modal map (rejected — Map is a primary tab).
- **Source**: Manual (`app_router.dart`, `scaffold_with_tabs.dart`, spec FR-001/FR-021).

## R2 — Map engine: MapLibre via `maplibre_gl`
- **Decision**: Add **`maplibre_gl`** (community MapLibre GL Flutter plugin). Wrap it behind a thin **`MapEngine`/`MapController` abstraction** in `lib/core/map/` so (a) the rest of the feature depends on an interface, (b) widget tests can inject a fake, and (c) the engine stays swappable. Use the custom warm style JSON via the existing `Env.mapStyleUrlLight/Dark` (asset-hosted style).
- **Rationale**: Constitution §I/§II.4 mandates MapLibre + a custom warm style and forbids vanilla provider styles; `core/map/map_config.dart` + `Env` + `assets/map_styles/*.json` already scaffold exactly this. PO approved the new dependency (Clarify R1).
- **Alternatives**: `flutter_map`+OSM (rejected — deviates from the mandate, raster hard to tint warm); `google_maps_flutter` (rejected — vanilla style, licensing, not brand-styleable to spec).
- **Source**: Manual + constitution.

## R3 — Pins: Flutter-widget overlay projected from lat/lng (not native symbols)
- **Decision**: Render pins as **Flutter widgets in a `Stack` overlay above the map**. This enables the design's teardrop shape (`BorderRadius 50% 50% 50% 4px` rotated −45°, glyph counter-rotated +45°), the staggered drop, the selected scale-to-1.18, and the pulse ring.
- **Projection (smoothness)**: positions are computed **synchronously in Dart** via a pure Web-Mercator projector (`lib/core/map/projection.dart` `latLngToScreen`) from the **live camera** the engine emits on every `onCameraMove` (as a `CameraSnapshot`). This avoids async per-marker `toScreenLocation` platform round-trips, so pins track the basemap smoothly during pan/zoom. Rotation & tilt gestures are **disabled** so the north-up projection is exact (FR-002 allows rotate-optional). Re-clustering is throttled to a ≥0.5 zoom delta; repositioning runs every frame (cheap, pure).
  - **Structure**: `MapView` (owns engine + a `ValueNotifier<CameraSnapshot>` updated on `onCameraMove`; builds the native surface once and caches it) composes a `MapMarkerLayer` — an idiomatic `ValueListenableBuilder` + `Stack`/`Positioned` overlay that rebuilds **only the marker layer** (scoped to the camera listenable) per frame; both halves sit in `RepaintBoundary`s so the native surface is never reconfigured. Re-clustering is deferred ~150 ms after movement settles so pins keep a stable identity mid-gesture.
  - **Known limitation**: compositing Flutter widgets over a native GL map means markers are re-placed at the Dart-frame cadence from sampled camera callbacks, so a fast pinch-zoom can still show a slight ("lowkey") trail vs the GL basemap. Native GL symbols were **declined** (preserve the teardrop design + per-pin animations); a fully jitter-free overlay would require a pure-Flutter map (`flutter_map`), which the engine decision (R2) rules out. Accepted for v1.
  - *(Evolution: v1 `toScreenLocation` on idle → snap after pinch. v2 sync projection + per-frame `setState` → smoother. v3 `Flow` paint-phase transform → no readability win, same residual jitter. v4 (current): clean `MapMarkerLayer` via `ValueListenableBuilder` — idiomatic, same smoothness.)*
- **Rationale**: maplibre_gl native `SymbolLayer`/annotations render pre-baked images and can't do per-pin Flutter animation/counter-rotation/pulse to the design's fidelity. Widget overlay gives full control and reuses the app's animation primitives.
- **Alternatives**: Native `SymbolLayer` with rendered PNGs (rejected — animation/selection fidelity); `addImage`+symbol (same limitation). Performance mitigations: viewport-cull + clustering (R4) keep the live widget count low for "hundreds of places".
- **Source**: Manual (maplibre_gl capabilities) + design "Pin"/ANIMATIONS §1–2.

## R4 — Clustering: Dart-side, feeding the widget overlay
- **Decision**: Cluster in Dart (grid/distance bucketing keyed on current zoom) and feed either a pin-widget or a cluster-bubble widget to the overlay. Cluster bubble = cocoa800 circle, cream border, count; tap zooms in to expand. A pure `clusterPlaces(places, zoom, ...)` function (unit-testable).
- **Rationale**: We own the widget overlay (R3), so native GeoJSON-source clustering doesn't apply; Dart clustering keeps the visible widget count bounded and is testable without a live map.
- **Alternatives**: maplibre GeoJSON `cluster: true` (rejected — only clusters native symbols, not our widgets). Thresholds (radius/min-zoom) → **Deferred** tuning (§5).
- **Source**: Manual + design "Cluster".

## R5 — Device location: add `geolocator`, reuse `PermissionsService`
- **Decision**: Add **`geolocator`**. Introduce a **`LocationService`** abstraction in `lib/core/location/` that: requests permission via the existing `PermissionsService.requestLocationWhenInUse()`, fetches a current position at **reduced/approximate accuracy** (Constitution §1.7), and optionally exposes a position stream for the dot. Expose as a Riverpod `AsyncValue<Position?>`. On denied/unavailable → null → Map falls back to a **Warsaw overview** (`const warsaw = LatLng(52.2297, 21.0122)`, zoom ≈ 12).
- **Rationale**: `permission_handler` is already present for the prompt; `geolocator` is the standard way to actually obtain coordinates (none installed). Approximate-only honors the privacy default; the abstraction makes it fakeable in tests.
- **Alternatives**: `location` package (rejected — `geolocator` is the de-facto standard, better maintained, supports accuracy control); platform channels (rejected — needless).
- **Platform setup**: iOS `Info.plist` `NSLocationWhenInUseUsageDescription` (Polish-localized); Android `ACCESS_COARSE_LOCATION` + `INTERNET` (tiles) in manifest. Capture as tasks.
- **Source**: Manual (`permissions_service.dart`) + spec FR-006/FR-014/NFR-005.

## R6 — Distance: haversine + adaptive locale formatting
- **Decision**: Pure `distanceMeters(a, b)` haversine util; `formatDistance(meters, locale)` → whole metres `< 1 km` ("350 m"), km with one decimal `≥ 1 km` ("1,2 km" — `intl` localizes the separator). Lives in `lib/core/location/`.
- **Rationale**: Spec Clarify (adaptive m/km via `intl`); pure functions are trivially unit-tested; no routing engine needed (walk-time stays out per spec).
- **Alternatives**: `geolocator.distanceBetween` (fine, but a tiny local haversine avoids coupling distance math to the plugin and is testable without it — use either; util wraps it).
- **Source**: spec FR-009/FR-015 + Clarify 2026-05-31.

## R7 — Category filter: one shared multi-select set
- **Decision**: A single `activeCategoriesProvider` (`Notifier<Set<Category>>`, empty = all). Chips are quick shortcuts (`selectOnly(cat)` sets `{cat}`; "Wszystko" → `clear()`); the filter sheet multi-selects the same set. A `Set` of size ≥2 → no single chip active. Pins, sheet, and list all derive from it.
- **Rationale**: Resolves the chip(single)/sheet(multi) contradiction (Clarify R-clarify-1) with one source of truth (FR-011/FR-012).
- **Alternatives**: separate chip + sheet filters (rejected in clarify — confusing, double-axis).
- **Source**: spec FR-011/FR-012 + Clarify.

## R8 — Search: promote shared search to `lib/core/search/`; accent-insensitive matcher
- **Decision**:
  - **Promote** `recent_searches_repository.dart` from `lib/features/home/data/` → **`lib/core/search/recent_searches_repository.dart`** (same `recent_searches` key) so Home and Map share one recents history (FR-018, unified). Update Home's import (no behavior change).
  - Add a shared **accent-insensitive matcher** `lib/core/search/place_match.dart`: `foldPl(String)` (lowercase + strip Polish diacritics: ą→a, ć→c, ę→e, ł→l, ń→n, ó→o, ś→s, ż/ź→z) and `matchesQuery(place, query, l10n)` over **name + category label + comment** (FR-017). The Map search uses it; Home may adopt later (its current matcher is case-only — left unchanged to avoid touching 002 behavior).
  - **Map-local** search-UI state: new `mapSearchActiveProvider` / `mapSearchQueryProvider` (search-active is screen-specific); recents + matcher are shared.
- **Rationale**: Constitution §1.1 — cross-feature plumbing belongs in `lib/core/`; avoids a feature→feature import. Accent-insensitivity is a new spec requirement (FR-017) not in Home's matcher.
- **Alternatives**: import the Home providers directly from the Map (rejected — feature coupling); duplicate the matcher (rejected — DRY).
- **Source**: Manual (`search_notifier.dart`, `recent_searches_repository.dart`) + spec FR-016/FR-017/FR-018.

## R9 — `CategoryStyle` promotion (pins reuse colour/glyph/label)
- **Decision**: Promote the `CategoryStyle` extension from `lib/features/home/presentation/widgets/category_style.dart` → **`lib/core/places/presentation/category_style.dart`** so the Map's pins/cards/rows reuse the exact colour/glyph/label mapping. Update Home's import.
- **Rationale**: The map pins, mini-cards, list rows, chips, and search results all need category colour/glyph/label; it's already the single mapping — promoting it prevents a Home→Map dependency or a duplicate.
- **Alternatives**: duplicate (rejected — DRY); import from Home (rejected — coupling).
- **Source**: Manual (`category_style.dart`).

## R10 — Animations → Flutter primitives (reduced-motion gated)
- **Decision** (per ANIMATIONS.md): pin drop = per-marker `TweenAnimationBuilder` (scale+translateY+opacity, 460 ms `easeOutBack`, `Future.delayed(i*60ms)` stagger); selected pulse = `AnimationController(2400ms)..repeat()` driving a ring behind the pin + `AnimatedScale(250ms)` to 1.18; sheet entrance = `AnimatedSlide`+`AnimatedOpacity` (or `DraggableScrollableSheet` present); list stagger = reuse the existing **`FadeRiseIn` + `EntranceController`** primitive (`lib/shared/widgets/fade_rise_in.dart`, `features/auth/.../stagger_animations.dart` — promote the mixin to `lib/shared/` if needed) with delays sort 70 / header 140 / rows 160+i·45 ms; view cross-fade = `AnimatedSwitcher` (~300 ms). **All gated on `MediaQuery.of(context).disableAnimations`** → render final states.
- **Rationale**: Matches ANIMATIONS.md exactly and reuses the app's proven entrance primitive (001/002).
- **Alternatives**: `flutter_animate` (not in deps; avoid a new dep for motion we can do with core widgets).
- **Source**: ANIMATIONS.md + Manual (`fade_rise_in.dart`, `stagger_animations.dart`).

## R11 — Bottom place sheet
- **Decision**: `DraggableScrollableSheet` pinned above the nav, grab handle, header (`N miejsc` + "Pokaż listę"), horizontal `ListView` of mini-cards. The card set = visible places ordered nearest-first (located) else A→Z (FR-007); selecting scrolls the card into view (`ScrollController.animateTo`).
- **Rationale**: Native draggable sheet gives the snap/drag behavior cheaply; matches design "Bottom place sheet" + AppBottomSheet (§3.9).
- **Source**: design + spec FR-007/FR-009.

## R12 — Sort comparators
- **Decision**: `SortMode { nearest, alphabetical, category }`. `nearest` = ascending distance (needs location; hidden otherwise). `alphabetical` = name via locale-aware compare (Polish collation). `category` = canonical `Category.values` order, then name. Default = `nearest` when located else `alphabetical`. No `openNow` (no hours).
- **Source**: spec FR-020 + Clarify.

## R13 — Riverpod state shape
- **Decision** (feature providers under `lib/features/map/presentation/state/`):
  - `mapViewProvider` `Notifier<MapView>` (`map` | `list`)
  - `activeCategoriesProvider` `Notifier<Set<Category>>` (R7)
  - `sortModeProvider` `Notifier<SortMode>`
  - `selectedPlaceIdProvider` `Notifier<String?>` (pin↔card sync)
  - `mapSearchActiveProvider` / `mapSearchQueryProvider`
  - `locationProvider` `AsyncNotifier`/`FutureProvider<Position?>` (R5); `userLatLngProvider` derived
  - `visiblePlacesProvider` = `placesProvider` ∩ `activeCategories` ∩ search-filter, then sorted (used by sheet + list); cluster layer derives from the category-filtered (pre-sort) set on the map.
- **Rationale**: Riverpod is the chosen stack; derive everything from the shared `placesProvider`.
- **Source**: Manual + spec State section.

## R14 — Localization keys (ARB, Polish canonical)
- **Decision**: add Map keys to `app_{pl,en,ar}.arb` (verbatim Polish from the design): `mapSearchHint` "Szukaj na mapie…", `listFilterHint` "Filtruj listę…", `toggleMapShort` "Mapa" (reuse `tabMap`? keep distinct), `toggleListShort` "Lista", `showListLink` "Pokaż listę", `sortNearest` "Najbliższe", `sortAlphabetical` "Alfabetycznie", `sortByCategory` "Wg kategorii", `filtersTitle` "Filtry", `allPlacesTitle` "Wszystkie miejsca", `noResults` "Brak wyników", `placesCount` (ICU plural — Polish 3-form, "{n} miejsce/miejsca/miejsc"), `locateMeLabel`, `navigateLabel`, `prayerTimesLinkLabel`. Reuse existing `searchCancel` ("Anuluj"), chip labels, `tabMap`.
- **Rationale**: Constitution §1.5/§V — ARB only, Polish canonical, plural via `intl`.
- **Source**: design copy + spec FR-025.

## R15 — Testing strategy (MapLibre native view not testable in widget tests)
- **Decision**: Because the native MapLibre view can't render in `flutter test`, the `MapEngine` abstraction (R2) lets widget tests inject a **fake engine** (a plain `SizedBox`/stub that records camera calls and answers `toScreenLocation`), so chrome + pin overlay + sheet + list + search + state are all testable headless. Native rendering is validated in the **integration test** on device/emulator.
  - **Unit**: haversine + `formatDistance`; `foldPl`/`matchesQuery` (accent-insensitive); `clusterPlaces`; sort comparators; `visiblePlaces` derivation; `activeCategories` chip/sheet logic.
  - **Widget**: map screen with fake engine (pins overlay, selection sync, sheet content/order, list rows, search overlay, filter sheet, sort menu) ×{pl,en,ar incl. RTL} ×{motion on/off} + loading/error states.
  - **Integration**: open Map → (mock) location → select pin↔card → search-fly → toggle Lista (stagger) → filter+sort → Navigate hand-off.
- **Rationale**: Constitution §XII mandates unit+widget+integration; abstraction makes the bulk testable without a device.
- **Source**: Manual + spec DoD/§XII.

## R16 — Dependencies & platform config
- **Decision**: add to `pubspec.yaml`: **`maplibre_gl`**, **`geolocator`** (pin exact versions during T-setup via `flutter pub add`). Platform: Android manifest `ACCESS_COARSE_LOCATION` + `INTERNET`; iOS `Info.plist` location usage string (localized) + MapLibre min-deployment if required. No backend; tiles + sheet + OS-location are the only network/OS touchpoints (no analytics — §1.7).
- **Source**: Manual (`pubspec.yaml`).

## R17 — MapLibre tile source (the one open technical choice — non-blocking)
- **Decision (recommendation, to confirm in ADR)**: ship the custom warm **style JSON** (complete the `assets/map_styles/halalmap-{light,dark}.json` stubs) referencing **MapTiler** vector tiles (free tier; key injected via `--dart-define=MAP_TILES_KEY`, never committed). This unblocks a real map fastest.
- **Alternatives**: Stadia Maps (similar), **Protomaps** `.pmtiles` (self-host/CDN, no per-tile key — best long-term cost), self-hosted tileserver-gl. Choice affects cost/keys, **not** the feature's product behavior.
- **Status**: **DECIDED — MapTiler** (key supplied 2026-05-31). Implemented: custom warm `halalmap-{light,dark}.json` styles reference MapTiler's OpenMapTiles vector tiles + glyphs with a `{key}` placeholder; `MapConfig.loadStyle()` injects `Env.mapTilesKey` at runtime (`--dart-define=MAP_TILES_KEY`, gitignored `dart_define.local.json`, never committed). Swapping providers later is a style-JSON change, not a code change.
- **Source**: Manual + constitution §I (tiles "decision pending").

---

**All NEEDS CLARIFICATION resolved.** One item (R17 tile provider) is an explicitly-deferred ADR decision that does not block design or task generation.
