# Phase 1 Data Model — Map Screen (v1)

**Feature**: `003-map-screen` · **Date**: 2026-05-31 · **Source**: [spec.md](./spec.md) · [research.md](./research.md)

The Map adds **no new persistent data model** — it reuses the shared `Place`/`Category`/`PlaceRepository` (from 002) and adds **runtime/UI state** plus small pure value types. Persistence touched: the shared `recent_searches` key only (unified recents).

---

## 1. Reused shared entities (no change)

### Place (`lib/core/places/domain/place.dart`)
`id, name, category, lat, lng, comment?, mawaqitLink?` — see [002 data-model](../002-home-screen/data-model.md). The Map uses `lat/lng` for pin position, distance, and camera fly-to; `comment` as the optional secondary card/row line; `mawaqitLink` for the mosque prayer-times link.

### Category (`lib/core/places/domain/category.dart`)
Canonical 6-value enum + `parsePolish`. Map surfaces only categories present in the data. Colour/glyph/label via the **promoted** `CategoryStyle` extension (R9 → `lib/core/places/presentation/category_style.dart`).

### PlaceRepository / `placesProvider`
Shared loader (Google Sheet CSV → cache → backend later). The Map watches the same `placesProvider` (FR-003).

---

## 2. New runtime/UI state (not persisted)

### MapView (enum)
- `map | list`. Drives the Map↔Lista cross-fade. `mapViewProvider : Notifier<MapView>` (default `map`).

### activeCategories (`Set<Category>`)
- Single source of truth for category filtering (R7). Empty = all.
- `activeCategoriesProvider : Notifier<Set<Category>>`. Ops: `selectOnly(cat)` (chip quick-select → `{cat}`), `clear()` ("Wszystko"), `toggle(cat)` (sheet multi-select).
- **Derivations**: a single-element set highlights that chip; empty highlights "Wszystko"; size ≥2 → no chip highlighted (FR-011).

### SortMode (enum)
- `nearest | alphabetical | category`. `sortModeProvider : Notifier<SortMode>`.
- `nearest` available **only** when `userLatLng != null` (else hidden; default falls back to `alphabetical`). No `openNow` (no hours). (FR-020)

### selectedPlaceId (`String?`)
- The selected place (pin↔card sync). `selectedPlaceIdProvider : Notifier<String?>` (null = none). Single-selection (FR-008/FR-010).

### Map search UI state
- `mapSearchActiveProvider : Notifier<bool>` (overlay open).
- `mapSearchQueryProvider : Notifier<String>` (debounced ~150 ms at the widget layer).
- (List view reuses the same query for inline filtering when `view == list`, or a parallel `listFilterQuery` — implementation detail; behavior per FR-019.)

### DeviceLocation (`AsyncValue<Position?>`)
- `locationProvider` — resolves to a `Position?` (null when permission denied / unavailable). `userLatLngProvider` derives `LatLng?`.
- Accuracy: reduced/approximate (Constitution §1.7). Not persisted, not identity-linked (spec §8 Device Location).

---

## 3. Derived providers (pure, from the above + `placesProvider`)

| Provider | Type | Definition |
|---|---|---|
| `availableCategoriesProvider` | `List<Category>` | categories present in data, canonical order (reuse 002 pattern) |
| `categoryFilteredProvider` | `List<Place>` | places where `activeCategories` empty OR contains `p.category` — feeds the **map pin/cluster layer** |
| `searchMatchesProvider` | `List<Place>` | full-dataset matches for `mapSearchQuery` (accent-insensitive over name+label+comment) — **ignores** `activeCategories` (FR-017) |
| `visiblePlacesProvider` | `List<Place>` | `categoryFiltered` (∩ inline list filter when in list view), then sorted by `sortMode` (nearest needs `userLatLng`) — feeds the **sheet + list**; header count = `.length` (FR-007/FR-015/FR-016) |
| `clusterLayerProvider` | `List<MapMarker \| Cluster>` | `clusterPlaces(categoryFiltered, zoom, viewport)` (R4) |
| `distanceForProvider(place)` | `double?` | `userLatLng == null ? null : haversine(userLatLng, place)` |

---

## 4. Pure value types & utilities (unit-tested)

### MapMarker / Cluster (overlay items, R3/R4)
- `MapMarker { Place place, LatLng latLng }`
- `Cluster { LatLng centroid, int count, List<Place> members }`
- `clusterPlaces(List<Place>, double zoom, LatLngBounds viewport) → List<MapItem>` — pure, deterministic.

### Distance (`lib/core/location/`)
- `double distanceMeters(LatLng a, LatLng b)` — haversine.
- `String formatDistance(double meters, Locale locale)` — `<1 km` → "350 m"; `≥1 km` → "1,2 km" (intl-localized decimal). (FR-009)

### Search match (`lib/core/search/place_match.dart`, R8)
- `String foldPl(String)` — lowercase + strip Polish diacritics (ą/ć/ę/ł/ń/ó/ś/ż/ź).
- `bool matchesQuery(Place, String query, AppLocalizations)` — `foldPl` over name + category label + comment. (FR-017)

### Camera constants
- `const warsaw = LatLng(52.2297, 21.0122)`; `const defaultZoom = 12.0` (fallback when no location, R5). Exact values → tunable (Deferred §5).

---

## 5. Persistence (unchanged keys + one promotion)

| Key | Store | Owner | Change |
|---|---|---|---|
| `recent_searches` | `shared_preferences` | **promoted** `RecentSearchesRepository` → `lib/core/search/` | shared by Home + Map (unified recents, FR-018) |
| `places_cache_csv` | `shared_preferences` | shared `PlaceRepository` | reused (resilience) |
| `bookmarked_place_ids` | `shared_preferences` | shared `BookmarkRepository` | not used by Map v1 (no save on map cards — Navigate only); available later |

**No secure storage, no PII, no new persisted entity.** Device location is session-only.

---

## 6. State transitions (selection & view)

```
view: map ⇄ list            (toggle / "Pokaż listę"; cross-fade)
selectedPlaceId: null → id  (tap pin OR tap card OR pick search result)
                 id → id'   (re-select)
                 id → null  (tap empty map / Anuluj returns unchanged)
search: idle → active (tap bar) → typing(query) → pick result
        pick result → { if place.category ∉ activeCategories: activeCategories.clear();
                         selectedPlaceId = id; camera.flyTo(place); view stays map; overlay closes }   (FR-017)
        Anuluj → active=false, query unchanged (map unchanged)
filter: chip selectOnly / clear ; sheet toggle  → activeCategories  (one source of truth)
```

---

**Inputs to /ai1st-dev-tasks**: reused shared entities (no migration), new feature-local state notifiers, derived providers, and four pure util/value modules (cluster, distance, match, camera consts) — each maps to a model/util task; each derived provider + screen widget maps to an implementation + test task.
