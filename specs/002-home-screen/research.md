# Phase 0 Research — Home Screen (v1)

**Feature**: 002-home-screen · **Date**: 2026-05-30 · **Revised**: 2026-05-30 (real Google-Sheet data source)

All decisions resolve the Technical Context and the spec's clarifications. Source tags: **Spec**, **Clarify**, **Constitution**, **AskUser**, **Manual**.

---

## R1. Navigation: render inside the existing 5-tab shell
- **Decision**: Home is the scroll **body** of the existing `/home` branch in the `StatefulShellRoute`; no own dock. Mini-map / "Otwórz mapę" switch to `/map` via the shell.
- **Source**: Clarify R1; Spec FR-001/FR-009.

## R2. Data source: live fetch of the shared Google Sheet
- **Decision**: A **shared** `PlaceRepository` (`lib/core/places/`) fetches the published Google Sheet CSV at runtime using the existing **`dio`** client, parses it with the **`csv`** package, and maps rows → `Place`. Exposed as `placesProvider` (`FutureProvider<List<Place>>`). Home and the future **Map** both watch it — single source, no duplication (Spec FR-016/FR-017).
- **Sheet URL**: `https://docs.google.com/spreadsheets/d/<SHEET_ID>/export?format=csv` (307-redirects to a signed `googleusercontent` URL; `dio` follows redirects). `SHEET_ID` is a public (non-secret) constant in the places config; can move to `--dart-define` later.
- **Columns**: `Longitude, Latitude, Name, Category, Comment, Mawaqit Link`. Categories present: `Meczet, Sklep, Restauracja, Cmentarz`.
- **Resilience**: cache the last successful CSV in `shared_preferences`; on fetch failure show cache, else a graceful empty/error state with retry (Spec FR-016, edge cases). Malformed rows (bad coords / unknown category) are skipped or defaulted, never fatal.
- **Rationale**: AskUser — user chose live fetch (relaxes the earlier offline guarantee). Reuses `dio` (already in pubspec); `csv` handles quoted fields/commas in names safely.
- **Alternatives**: bundle an exported CSV asset (rejected by user — wanted live); gviz JSON endpoint (rejected — JSONP wrapper is hackier than CSV); hand-rolled CSV split (rejected — unsafe with quoted fields).
- **Source**: AskUser, Spec FR-016/FR-017.

## R3. Place model & id (sheet-shaped)
- **Decision**: `Place { id, name, category, lat, lng, comment?, mawaqitLink? }` in `lib/core/places/domain/place.dart`. The sheet has **no id** → derive a stable `id = '<name>|<lat>|<lng>'` (used as the bookmark key). No city / hours / featured / photo fields (absent in data).
- **Source**: Spec §8, Data-source session.

## R4. Category taxonomy: canonical 6-enum, parse the 4 present
- **Decision**: `enum Category { restaurant, masjid, grocer, butcher, shop, cemetery }` in `lib/core/places/domain/category.dart`, with `Category? parsePolish(String)`: Meczet→masjid, Restauracja→restaurant, Cmentarz→cemetery, Sklep→shop; unknown → null (row's category defaulted/skipped, not fatal). Home shows a chip per category **present** in the loaded data (launch: Restauracje, Meczety, Sklepy, Cmentarze). A Home presentation helper maps `Category → cat-* color + glyph + ARB label key`.
- **Rationale**: Clarify R1 + Data-source. Keeps the canonical enum (Map/other features reuse) while honestly surfacing only what exists; grocer/butcher and the grocery/Islamic-shop split aren't distinguishable yet (Deferred Decision).
- **Source**: Spec FR-005/FR-007.

## R5. Featured auto-pick (no featured flag in data)
- **Decision**: `selectFeatured(List<Place>, {cap})` produces a **deterministic varied sample**: group by category in canonical order, round-robin one place per category until `cap` (default ~10) is reached or places exhausted. Deterministic for a given dataset (no `Math.random`). The category chip then filters this featured list in place.
- **Rationale**: AskUser — auto-pick. Round-robin guarantees category variety on the hero row.
- **Source**: Spec FR-012/FR-013/FR-006.

## R6. External maps redirect (url_launcher)
- **Decision**: `MapsLauncher` (`lib/core/maps/`) over **`url_launcher`** opens the place by coordinates: `https://www.google.com/maps/search/?api=1&query=<lat>,<lng>`, `LaunchMode.externalApplication`; no maps app → OS opens the URL in the browser. Coordinates are always present in the sheet (FA-3), so the name+city fallback is unnecessary now (kept as a defensive fallback only).
- **Source**: AskUser, Spec FR-015, §10.

## R7. Bookmarks (shared_preferences)
- **Decision**: `BookmarkRepository` (`lib/core/places/data/`) over **`shared_preferences`** persists a `List<String>` of place ids under `bookmarked_place_ids`. `BookmarksNotifier` holds the in-memory `Set<String>`, optimistic toggle + write-through. Shared so the future **Saved** tab reads the same key.
- **Rationale**: AskUser — non-sensitive, idiomatic prefs store (not secure storage).
- **Source**: AskUser, Spec FR-014.

## R8. Design tokens: extend `tokens.dart` for Home + mini-map
- **Decision**: add Home type sizes (`homeH1=26`, `homeH2=19`, `cardTitle=14`, `chip=13`), screen-gradient end `homeBgGradientEnd #E9DDC3`, and an `HmpMap` palette (`mapBase #ECE1CB`, `mapBlock #D4C08E`, `mapPark #B4C89A`, `mapRiver #A8C2C5`, `mapRoad #F6ECD5`). Category colors already exist (`catRest/catMosque/catGroc/catShop/catCem`). No status/open colors needed now (status dropped).
- **Rationale**: Constitution §X (no magic literals), §2.4/§2.5; Spec UX note (Home uses handoff px).
- **Source**: Manual + Constitution.

## R9. Mini-map rendering & ambient motion
- **Decision**: `CustomPainter` synthetic basemap (block rects, park `Path`, river `Path`, road strokes) under `ClipRRect(20)`; teardrop pins as `Positioned` widgets (a deterministic small sample incl. a masjid for the pulse); count pill from `places.length`; glass overlay via `BackdropFilter`. Four ambient controllers (`mmDrift` 16s, `mmFloat` 3.6s, `mmPulse` 2.6s, `mmSheen` 7s) via `AnimatedBuilder`. When `MediaQuery.disableAnimations` is true, controllers are not started and a static frame renders.
- **Rationale**: Spec FR-008/FR-010/FR-020; handoff §4.4/§5.2. No animation dependency.
- **Source**: Spec, handoff.

## R10. Entrance animation & reduced motion (reuse 001 primitive)
- **Decision**: Reuse 001's `FadeRiseIn` entrance primitive (already respects `disableAnimations`); promote to `lib/shared/widgets/` if cross-feature import warrants. Cards/chips press feedback via `AnimatedScale`.
- **Source**: Spec FR-019/FR-020; DRY (Constitution §1.1).

## R11. State management (Riverpod)
- **Decision**: `placesProvider` (`FutureProvider<List<Place>>`, shared) → loads via repository. `homeProvider` (Notifier) holds `selectedCategory` and derives `featuredVisible` from `placesProvider`'s data + `selectFeatured` + filter. `bookmarksProvider` (`Notifier<Set<String>>`). Repos/prefs/launcher as `Provider`s. Loading/error surfaced via the `AsyncValue` of `placesProvider` (skeletons / error state).
- **Source**: Constitution §IX; Spec FR-016.

## R12. Localization (ARB, Polish canonical)
- **Decision**: add ~12 ARB keys/locale (H1 parts + "halal" accent, subtitle, search placeholder, chip labels for the present categories + "Wszystko", section title "Polecane miejsca", "Otwórz mapę", mini-map count with ICU plural, empty message, error/retry copy). Polish canonical; en/ar placeholders; RTL for ar. `intl` (present) handles Polish 3-form plural.
- **Source**: Constitution §1.5/§V; Spec FR-021.

## R13. New dependencies
- **`url_launcher`** (maps redirect), **`shared_preferences`** (bookmarks + fetch cache), **`csv`** (parse the sheet CSV). HTTP fetch reuses existing **`dio`**. `csv` is a necessary consequence of the live-CSV choice (small, standard); recorded here and in the stack constitution.
- **Source**: AskUser + Manual.

## R14. MCP / external research
- Not used (no Jira/Confluence; libraries are well-known). Decisions live in git here.
