# Phase 1 Data Model — Home Screen (v1)

**Feature**: 002-home-screen · **Date**: 2026-05-30 (real Google-Sheet data source)

The place data is **shared** (`lib/core/places/`) and loaded live from the published Google Sheet (Spec FR-016/FR-017). Home and the future Map consume the same model and repository. Types are immutable Dart value objects with `==`/`hashCode`.

---

## Enums

### `Category` — `lib/core/places/domain/category.dart` (shared)
Canonical 6-value taxonomy (Architecture domain model). Parsed from the sheet's Polish category strings; Home surfaces a chip per category **present** in the loaded data.

| Value | Sheet string | Home chip (PL) | `cat-*` token | Glyph |
|-------|--------------|----------------|---------------|-------|
| `masjid` | Meczet | Meczety | `catMosque` #3F6B5A | 🕌 |
| `shop` | Sklep | Sklepy | `catShop` #5B4A8A | 🛍 |
| `restaurant` | Restauracja | Restauracje | `catRest` #8A4A36 | 🍴 |
| `cemetery` | Cmentarz | Cmentarze | `catCem` #5A6473 | ✦ |
| `grocer` | *(not in data yet)* | — | `catGroc` | — |
| `butcher` | *(not in data yet)* | — | — | — |

`Category? parsePolish(String raw)` — case/whitespace-tolerant; unknown → `null` (the row is defaulted/skipped, never fatal). A Home presentation helper maps `Category → color/glyph/labelKey`. (`grocer`/`butcher` and the grocery-vs-Islamic-shop split are Deferred Decisions, pending finer sheet categories.)

---

## Entities

### `Place` — `lib/core/places/domain/place.dart` (shared)
| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | derived stable key `'<name>\|<lat>\|<lng>'` (sheet has no id); bookmark key |
| `name` | `String` | display name (column `Name`) |
| `category` | `Category` | parsed from column `Category` |
| `lat` | `double` | column `Latitude` |
| `lng` | `double` | column `Longitude` |
| `comment` | `String?` | column `Comment` (optional notes) |
| `mawaqitLink` | `String?` | column `Mawaqit Link` (optional; unused by Home v1) |

**Rules / validation**
- `name` non-empty and `lat`/`lng` parseable → required for a valid row; otherwise the row is skipped during parse.
- `category` from `parsePolish`; unknown → row skipped (or assigned a default) — never crashes the load.
- **Not present in v1 data (and not shown):** city, opening hours, featured flag, photo, rating, verification, distance.

### `Bookmark` (local, guest) — persisted set of place ids
- A `Set<String>` of `Place.id`; persisted via `BookmarkRepository`; shared with the Saved (Zapisane) tab.

> **City** entity is removed for v1 (no city data); returns with a City column (Deferred Decisions).

---

## View-state (Riverpod)

### `placesProvider` — `FutureProvider<List<Place>>` (shared)
- Loads via `PlaceRepository.fetchPlaces()` (Google Sheet → parsed `Place`s). `AsyncValue` drives Home's loading skeletons / error state and the mini-map count; the Map will watch the same provider.

### `homeProvider` — `Notifier<HomeViewState>`
| Field | Type | Notes |
|-------|------|-------|
| `selectedCategory` | `Category?` | null = "Wszystko" |

Derived (pure, from `placesProvider` data):
- `featuredAll = selectFeatured(places, cap: ~10)` — deterministic varied sample (round-robin by category).
- `featuredVisible = selectedCategory == null ? featuredAll : featuredAll.where(category == selected)`.
- `availableCategories = places.map(category).toSet()` (in canonical order) → the chip set.
- `totalCount = places.length` → mini-map pill.
- `featuredVisible` empty → Featured section shows the empty message.

### `bookmarksProvider` — `Notifier<Set<String>>`
- Hydrated from `BookmarkRepository.load()`; `toggle(id)` optimistic + write-through; `isBookmarked(id)`.

---

## Persistence

| Store | Key | Value | Used by |
|-------|-----|-------|---------|
| `shared_preferences` | `bookmarked_place_ids` | `List<String>` (place ids) | `BookmarkRepository`; future Saved tab |
| `shared_preferences` | `places_cache_csv` (+ `places_cache_at`) | last successful sheet CSV (string) + timestamp | `PlaceRepository` resilience cache (Spec FR-016) |

No SQL/document DB. Bookmarks/cache are non-sensitive → not secure storage (Constitution §2).

---

## Data source contract (Google Sheet)

- **URL**: `https://docs.google.com/spreadsheets/d/<SHEET_ID>/export?format=csv` (public; 307→signed URL, `dio` follows).
- **Columns (header row)**: `Longitude, Latitude, Name, Category, Comment, Mawaqit Link`.
- **Parse**: `csv` package → rows; map by header name (tolerant of column reordering); skip blank/invalid rows.
- **Categories at launch**: Meczet, Sklep, Restauracja, Cmentarz.
