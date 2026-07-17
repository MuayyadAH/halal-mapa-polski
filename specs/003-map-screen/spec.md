# Map Screen (v1) Specification

**Feature Branch**: `003-map-screen`
**Created**: 2026-05-31
**Status**: Implemented (v1) — unit + widget + localization tests green (`flutter analyze` clean, 120 tests); on-device MapLibre tile rendering + the full integration E2E (`integration_test/map_flow_test.dart`) require a device + a MapTiler key and are verified there.
**Priority**: High
**Input**: User description: "We are now implementing the map, read the design specs from specs/design/map"

---

## 1. Primary User Story

As a guest user (not logged in) opening the **Mapa** tab of Halal Map Polskie, I want an interactive, brand-styled map of curated halal places in Warsaw — with category-coloured pins I can tap, a search that finds and flies to a place, category filters, and a bottom sheet of nearby place cards — plus a **Lista** view of the same places that I can search, filter and sort — so that I can discover halal restaurants, mosques, grocers and Islamic shops both spatially and as a browsable list, without ratings, verification badges, or a login wall.

---

## 2. Details

**Problem:** Home (002) gives a guest a curated entry point and a *synthetic* mini-map preview, but no real spatial discovery. Users need an actual interactive map to see where halal places are relative to each other and to themselves, tap a pin to learn about a place, and hand off to navigation — plus a list alternative for users who prefer scanning. The launch data is the same small, hand-maintained Google Sheet Home uses (name, category, coordinates, optional comment, optional Mawaqit link) — there are **no ratings, verification badges, opening hours, addresses, or distances in the data**. The Map must deliver the full design experience honestly on top of exactly that data, while adding the one capability Home deliberately skipped: the **device's own location**, to power the user-location dot, locate-me, distance, and "nearest" sort.

**Clarifications:**

### Round 1 (2026-05-31)

- Q: Scope — build the whole Map tab, or just the map surface first? → A: **Build the whole Map tab** — both Map and Lista views, the search overlay (map) + inline filter (list), the filter sheet, sort, the bottom place sheet, locate-me, and all animations.
- Q: Where does the Map's place data come from? → A: **Follow the data** — the Map consumes the **same shared Google-Sheet `PlaceRepository`** (`lib/core/places/`) that Home uses; a backend API replaces the sheet later without touching the Map. Fields the sheet does not have are not shown.
- Q: Which map engine for v1 (none installed yet; constitution mandates MapLibre and forbids vanilla styles)? → A: **MapLibre (`maplibre_gl`)** — a real interactive map with the custom warm cocoa/cream style. New dependency approved. A tile-source/style decision is deferred to planning (see §5).
- Q: Include the device's live location (user-dot, locate-me, distance, "Najbliższe" sort)? → A: **Yes, add live location** — add a geolocation package (new dependency) and reuse the existing permission pre-prompt. Graceful fallback to a Warsaw overview if permission is denied/unavailable. Still no walk-time (no routing) and no open-now (no hours).
- Q: Given the lean data, what do mini-cards and list rows show? → A: **Honest minimal + use what we have** — category glyph/colour + name + category label, the optional `comment` as a secondary line, a Mawaqit prayer-times link on mosque cards when present, and a Navigate button that opens external Google Maps. Distance is shown only when location is available. **No** open/closed status dot, address/district line, or walk time.
- Q: Which sort modes should the Lista sort pill offer? → A: **Najbliższe + Alfabetycznie + Wg kategorii.** "Otwarte teraz" (open-now) is dropped (no hours in data). "Najbliższe" appears only when location is available; otherwise the list defaults to Alfabetycznie.

### Session 2026-05-31 (Clarify)

- Q: Chip (single-select) vs filter-sheet (multi-select) category filtering — how should it behave? → A: **One shared multi-select filter** (`Set<Category> activeCategories`) is the single source of truth. Chips are quick shortcuts (tapping a chip selects just that one; "Wszystko" clears to all); the filter sheet multi-selects the same set. When two-or-more categories are selected (via the sheet), no single chip shows active. Pins, sheet mini-cards, and list rows all read this one set.
- Q: Distance unit/format (shown when location is available)? → A: **Adaptive, locale-formatted via `intl`** — under 1 km in whole metres (e.g. "350 m"); 1 km and over in km with one decimal (e.g. "1.2 km").
- Q: Which places appear in the Map bottom sheet, and in what order? → A: **All currently-visible places** (after the category filter + any active search), ordered **nearest-first when location is available, else alphabetically** (matching the Lista default sort); the sheet header count equals that set's size. Selecting a pin/card scrolls the matching card into view.
- Q: Map search scope vs the active category filter, and selecting an out-of-filter result? → A: **Search always queries the full dataset** (ignores the active filter). Selecting a result whose category is filtered out **resets the filter to "Wszystko"** so its pin is visible, then selects the pin, flies the camera, and shows its mini-card.
- Q: How do the map search "Ostatnie" recents relate to Home's recents? → A: **Unified** — reuse the same `recentSearchesProvider`/store, so recent queries are one shared history across Home and Map (no separate key).

**Requirement Conflicts (design `specs/design/map` vs data reality + prior decisions):**

- **Open/closed status & hours** (design: pins, mini-cards and rows show "Otwarte · do 22:00" / "Zamknięte", `open`/`closes`/`opens` fields): **not in the data.** **Resolution:** dropped for v1 (consistent with 002 §2 "drop open/closed status"); returns when an Hours column exists (Deferred Decisions). Showing a faked/placeholder status would violate the trust-first constitution (§1.6).
- **Address / district & walk time** (design rows show "Marszałkowska 8 · Śródmieście" and "5 min"): **not in the data and not derivable** (no addresses; no routing engine). **Resolution:** dropped for v1; the `comment` field stands in as an optional secondary line.
- **Distance & "nearest"** (design: "0.4 km", "Najbliższe" sort, "84 miejsca w pobliżu"): require the device location, which 002 omitted. **Resolution:** v1 **adds** location (this feature's one new capability), so distance and Najbliższe are computed honestly (haversine); copy that implies a hard count of nearby places becomes a total/visible count.
- **Bottom "Dock"** (design: a custom 4-slot parchment-glass Dock, no centre FAB): the app uses the existing **5-tab Material `NavigationBar`** shell. **Resolution:** the Map renders content only inside that shell and draws **no dock of its own** — identical to the 002 decision (FR-001).
- **Ratings / verification badges**: the design's v1 already excludes them ("no ratings, no verification badges"); this aligns with the curated-launch stance. **Resolution:** none shown (consistent with 002 FR-023).
- **Category set** (design chips: Wszystko / Restauracje / Meczety / Sklepy, plus pins for Islamskie + Cmentarz): the sheet maps to masjid / restaurant / shop / cemetery. **Resolution:** chips/pins reflect only the categories present in the data, using the canonical `Category` enum (same as 002 FR-005/FR-007).
- **Requirement conflict check** completed against `specs/001-onboarding-flow` and `specs/002-home-screen` — no blocking logical conflicts; the Map reuses 002's shared data layer, recent-searches store, maps launcher, and nav-shell decisions rather than contradicting them.

---

## 3. Workflow

**Business Workflow** — *guest selects the Mapa tab:*

1. The user selects the **Mapa** tab. The Map view renders full-bleed inside the existing 5-tab nav shell: a warm, brand-styled interactive basemap centred on Warsaw.
2. The app requests the device location (only-while-using, approximate by default per Constitution §1.7) via the existing permission pre-prompt. If granted, a user-location dot appears and the camera centres on the user; if denied/unavailable, the map stays on a Warsaw overview and location-dependent affordances degrade gracefully.
3. The Map fetches places from the shared `PlaceRepository` (the same Google Sheet Home uses). Category-coloured teardrop pins drop onto the map (staggered), clustering where they overlap at low zoom.
4. Pinned chrome appears over the map: a top **search bar** ("Szukaj na mapie…"), a **Map ↔ Lista** segmented toggle, a horizontally-scrolling **category chip** row, a **locate-me FAB**, and a **bottom place sheet** with a header count and horizontally-scrolling **mini-cards**.
5. Tapping a **pin** selects it (scale-up + pulse ring) and surfaces/syncs its mini-card in the sheet; tapping a **mini-card** selects the matching pin and (optionally) pans the camera to it — selection is bidirectional.
6. Tapping a **category chip** filters the visible pins and the sheet/list to that category ("Wszystko" = all). The chip set contains only categories present in the data.
7. Tapping the **search bar** opens a search overlay: a focused field with an "Anuluj" button and a parchment results panel over the map, grouped **Ostatnie** (persisted recents) / **Podpowiedzi** (live matches) / **Kategorie** (quick filters). Matching is case- and accent-insensitive against name, category label, and comment, debounced ~150 ms. Selecting a result dismisses the overlay, flies the camera to the place, selects its pin, and shows its mini-card.
8. Tapping the **locate-me FAB** recentres the camera on the user dot (or re-requests permission if not yet granted).
9. The user switches to **Lista** via the toggle or the sheet's "Pokaż listę" link; the views cross-fade and list rows cascade in. The list shows every place with a category icon tile, name, category label, optional comment, a Navigate button, and (when location is available) a distance.
10. In **Lista**, the search bar ("Filtruj listę…") filters rows live in place; the **sort pill** offers Najbliższe (when location available) / Alfabetycznie / Wg kategorii; the active category chip still applies.
11. The **filter glyph** (search bar trailing, both views) opens a filter sheet: category multi-select; it narrows both pins and list. (Open-now is omitted — no hours.)
12. Tapping a **Navigate** button (mini-card or row) opens the place in the external Google Maps / OS maps app via the shared maps launcher.
13. If the OS reduced-motion setting is on, all entrance and ambient animation is skipped (final/resting states); tap feedback remains.

*No places load (empty dataset / fetch failure with no cache):* the map shows no pins and the sheet/list shows a graceful empty/error state with retry; the chrome still renders.
*Category filter yields nothing:* the sheet/list shows "Brak wyników" (or the empty-category message), and the map shows no pins for that filter.

**Test Cases / Acceptance Scenarios:**

- **TC-1: Renders inside the 5-tab shell** — selecting Mapa shows the map full-bleed inside the existing 5-tab nav; the Map draws no dock of its own. {Conflict: Dock}
- **TC-2: Real interactive basemap** — the basemap is a real MapLibre map with the custom warm style (land/roads/parks/water tints per the design palette), supporting pan and pinch-zoom; it is NOT the synthetic Home mini-map and NOT a vanilla provider style. {FR-002}
- **TC-3: Pins by category** — each place renders a teardrop pin in its category colour with an upright white glyph; categories present in the data (restaurant, masjid, shop, cemetery at launch) are represented. {FR-004}
- **TC-4: Clustering** — at a zoom where pins overlap, they collapse into a styled count cluster (cocoa fill, cream border, count); tapping it zooms/expands. {FR-005}
- **TC-5: User-location dot & locate-me** — with permission granted, a blue user-location dot shows and the locate-me FAB recentres the camera on it; with permission denied, no dot shows and the FAB re-prompts or no-ops gracefully (Warsaw overview retained). {FR-006, FR-014}
- **TC-6: Pin ↔ card selection sync** — tapping a pin selects it (scale 1.18 + pulse ring) and highlights/surfaces its mini-card; tapping a mini-card selects the matching pin; the relationship is bidirectional. {FR-008, FR-010}
- **TC-7: Category chips filter (shared set)** — with Wszystko active, tapping "Meczety" sets the filter to just masjid (only masjid pins + cards/rows); "Wszystko" clears to all. The chip set lists only categories present in the data. When ≥2 categories are selected via the filter sheet, no single category chip shows active. {FR-011}
- **TC-8: Map search overlay finds & flies** — tapping the search bar opens the overlay; typing filters matches (name/category/comment, accent-insensitive, ~150 ms debounce) across the full dataset; selecting a result dismisses the overlay, animates the camera to the place's coordinates, selects its pin, and shows its mini-card; "Anuluj" returns to the map unchanged. {FR-016, FR-017}
- **TC-8b: Search ignores filter; out-of-filter selection clears it** — with the filter set to Meczety, searching finds a restaurant by name; selecting it resets the filter to "Wszystko", makes its pin visible, selects it, flies the camera, and shows its card. {FR-017}
- **TC-9: Recents persist & unified** — recent search queries appear under "Ostatnie", persist across app restarts, and re-fill the query on tap; a query made on Home appears in the Map's recents and vice-versa (one shared history). {FR-018}
- **TC-10: List inline filter** — in Lista, typing in the bar filters rows live in place (same match logic), combined with the active category chip and sort; clearing restores the list; no matches shows "Brak wyników". {FR-019}
- **TC-11: Sort modes** — the Lista sort pill offers Najbliższe (only when location is available), Alfabetycznie, and Wg kategorii; selecting one reorders the list accordingly; there is no "Otwarte teraz" option. {FR-020}
- **TC-12: View toggle cross-fade + stagger** — Map↔Lista (toggle or "Pokaż listę") cross-fades (~300 ms); on entering Lista, the sort pill, header, and rows cascade in (fade-up); shared chrome does not re-animate. {FR-021, FR-024}
- **TC-13: Filter sheet (multi-select, shared set)** — the trailing filter glyph opens a sheet whose category multi-select writes the same shared `activeCategories` set; selecting multiple categories narrows pins + sheet + list together and leaves no single chip active; it has no open-now toggle (no hours data). {FR-012}
- **TC-14: Mini-card / row content (lean, honest)** — a mini-card/row shows a category-tinted icon tile + glyph, name, category label, optional comment, a Navigate button, and a distance only when location is available; it shows NO open/closed status, address/district, or walk time. Mosque cards with a Mawaqit link expose a prayer-times link. {FR-009, FR-013, Conflict: status/address/walk}
- **TC-14a: Distance format** — when location is available, distance reads in whole metres under 1 km (e.g. "350 m") and km with one decimal at/over 1 km (e.g. "1.2 km"), locale-formatted; when location is unavailable, no distance is shown. {FR-009, FR-015}
- **TC-15: Navigate opens external maps** — tapping a Navigate button opens the place in Google Maps / the OS maps app via the shared launcher (browser fallback if none installed); no in-app place detail appears. {FR-022}
- **TC-16: Sheet content, order & header count** — the bottom sheet shows every currently-visible place (after category filter + active search), ordered nearest-first when location is available and alphabetically otherwise; the header shows the localized count of that set (e.g. "N miejsc"). {FR-007}
- **TC-17: Shared data layer** — the Map loads places from the same `PlaceRepository`/`placesProvider` as Home (no private copy); the same source will be re-pointed to the backend later. {FR-003, FR-023}
- **TC-18: Pin-drop & selected-pin animations** — pins drop in staggered (460 ms easeOutBack, +60 ms/pin); the selected pin scales to 1.18 (250 ms) and shows an infinite pulse ring (2400 ms); the sheet slides+fades up on appear. {FR-024}
- **TC-19: Reduced motion** — with OS disable-animations on, pin-drop, pulse, sheet slide, list stagger, and view cross-fade are all disabled (final states rendered instantly); selection still updates styles; tap feedback remains. {FR-024}
- **TC-20: Localization + RTL** — all Map copy renders from ARB in pl/en/ar; Arabic mirrors to RTL with the Arabic font; the Polish design copy is canonical and unchanged; no hard-coded strings. {FR-025}
- **TC-21: Accessibility** — pins, chips, FAB, toggle, sort, navigate and icon-only controls have semantic labels; tap targets ≥ 44–48 dp; usable at max font scale; RTL parity. {FR-026}
- **TC-22: Lean guardrails** — the Map shows no star ratings, review counts, verification badges, opening hours/status, addresses, walk-time, "Add place" FAB, or login wall. {FR-027}
- **TC-23: Fetch failure is graceful** — a failed places fetch with no cache shows a non-blocking empty/error state with retry (map chrome intact); cached data, if present, is shown instead. {FR-023}

**Edge Cases:**

- *Location permission denied or services off* → no user dot; locate-me re-prompts or no-ops with a brief hint; distance hidden; Najbliższe sort hidden; camera stays on Warsaw overview. App does not block or crash.
- *Location granted but a fix is slow/unavailable* → map renders immediately on the Warsaw overview; the user dot and distance appear once a fix arrives; no spinner blocks interaction.
- *Very long place name* → truncates with ellipsis in cards and rows without breaking layout.
- *Maximum OS font scale* → text scales; critical controls (navigate, locate-me, toggle, chips) remain reachable.
- *Place with no comment* → the secondary comment line is omitted; layout stays consistent.
- *Mosque with no Mawaqit link* → no prayer-times link shown (the link is optional).
- *Pins at identical/near-identical coordinates* → clustering keeps them tappable; expanding the cluster (zoom) separates them.
- *Empty dataset (sheet returns 0 rows)* → no pins; sheet/list shows the empty state; header count reads "0".
- *Fetch failure with a prior cache* → last successful dataset is shown; with no cache → empty/error state with retry.
- *Malformed sheet row* (bad coordinates / unknown category) → skipped by the shared parser without failing the load (no pin for that row).
- *Selecting a category then backgrounding/resuming* → active category, search/sort state, view (Map/Lista), and selection are preserved.
- *No maps app installed when Navigate is tapped* → the maps URL opens in the default browser; no crash.
- *Device locale not pl/en/ar* → defaults to Polish.
- *Accent-insensitive search* → "lazienki" matches "Łazienki"; "meczet" matches regardless of diacritics/case.
- *Searching while a category filter is active* → search still scans all places; choosing a result from a filtered-out category resets the filter to "Wszystko" so its pin shows, rather than selecting a place with no visible pin.

---

## 4. Requirements

**Requirement Documents:**

- **Design handoff:** `specs/design/map/` — `README.md` (layout/components/data), `PROMPT.md` (build brief), `ANIMATIONS.md` (motion source of truth), `reference/Map Screen Reference.html` + `reference/01-map-view.png` + `reference/02-list-view.png` (pixel + motion target), `reference/styles.css`, `tokens/app_colors.dart`, `tokens/app_text.dart`. The status/address/walk-time/Dock elements are adapted to the available data and the app shell per §2.
- **Live data source:** the shared Halal-places Google Sheet (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`), via the shared `PlaceRepository`.

**Functional Requirements:**

*Shell, engine & basemap*
- **FR-001**: The Map MUST render as the "Mapa" tab content inside the existing 5-tab nav shell and MUST NOT render its own bottom navigation/dock. {Conflict: Dock; mirrors 002 FR-001}
- **FR-002**: The Map view MUST present a **real interactive map** rendered with MapLibre, styled with the custom warm cocoa/cream palette (land, building blocks, roads, parks, water, faint street labels per the design palette / Constitution §II.4). It MUST NOT use a vanilla provider style and MUST NOT be the synthetic Home mini-map. The map MUST support pan and pinch-zoom (rotate optional). {Design README "Map Engine"; Constitution §I/§II.4}
- **FR-003**: The Map MUST load places from the **shared** `PlaceRepository` (`lib/core/places/`) — the same source Home consumes — parsed into the canonical `Place` model; it MUST NOT keep a private copy or loader. The source MUST remain swappable to the backend API later. {Clarify R1; 002 FR-017}

*Pins, cluster, user location*
- **FR-004**: Each place MUST render as a custom teardrop pin filled with its category colour, white border, and an upright white category glyph; categories follow the canonical `Category` enum and are tinted per the `cat-*` tokens. {Design "Pin"}
- **FR-005**: Overlapping pins at low zoom MUST collapse into a styled count cluster (cocoa fill, cream border, count label); tapping a cluster MUST zoom in / expand it. {Design "Cluster"}
- **FR-006**: When device location is available (permission granted), the Map MUST show a user-location dot at the user's position and centre the initial camera on the user; when unavailable, it MUST fall back to a Warsaw/Poland overview with no dot. {Clarify R1; Design "User location"}
- **FR-014**: The Map MUST provide a locate-me FAB that recentres the camera on the user dot; if permission is not yet granted it re-requests it (via the existing permission pre-prompt), and if denied it degrades gracefully (no crash). {Design "Locate-me FAB"; Constitution §1.7}

*Sheet, chrome & selection*
- **FR-007**: The Map view MUST show a bottom place sheet pinned above the nav shell, with a grab handle, a header showing the localized count of currently-visible places and a "Pokaż listę" link that switches to Lista, and a horizontally-scrolling row of mini-cards. The mini-card set MUST be the **currently-visible places** (after the category filter + active search), ordered **nearest-first when location is available, else alphabetically** (matching the Lista default); the header count MUST equal that set's size. Selecting a pin/card MUST scroll the matching card into view. {Design "Bottom place sheet"; Clarify 2026-05-31}
- **FR-008**: Tapping a pin MUST select it and surface/scroll-to its mini-card; tapping a mini-card MUST select the matching pin; selection MUST be bidirectional and single-selection. {Design "Interactions"}
- **FR-009**: Each mini-card MUST show a category-tinted gradient icon tile + glyph, the place name, the category label, the optional `comment` as a secondary line, a Navigate button, and — only when location is available — a distance. Distance MUST be formatted adaptively and locale-aware (via `intl`): whole metres under 1 km (e.g. "350 m"), km with one decimal at 1 km and above (e.g. "1.2 km"). The selected mini-card MUST take the selected visual treatment (white fill, cocoa border, ring). {Design "Mini-cards"; Clarify R1 + 2026-05-31}
- **FR-010**: The selected pin MUST be visually distinct (scale-up, coloured glow, pulsing ring, raised z-order) and the selected card visually distinct, kept in sync. {Design "Pin selected"; ANIMATIONS §2/§4}
- **FR-013**: The Map MUST NOT show open/closed status, opening hours, address/district, walk time, ratings, or verification badges on pins, mini-cards, or rows (none exist in the v1 data). On mosque places, when a Mawaqit link is present, the card/row MAY expose a prayer-times link. {Conflict: status/address/walk; Clarify R1}

*View toggle, list & sort*
- **FR-021**: The Map MUST provide a Map ↔ Lista segmented toggle (also reachable via the sheet "Pokaż listę" link) that cross-fades (~300 ms) between the two views; shared chrome (search bar, toggle) stays mounted and does not re-animate. {Design "View toggle"; ANIMATIONS §6}
- **FR-015**: The Lista view MUST show a scrollable list of all (filtered) places over the warm gradient background; each row MUST show a category icon tile + glyph, the name, the category label, the optional comment, a Navigate button, and a distance when location is available (same adaptive m/km, locale-formatted rule as FR-009) — and MUST NOT show status, address/district, or walk time. {Design "List view"; Clarify R1 + 2026-05-31}
- **FR-020**: The Lista view MUST provide a sort control offering **Najbliższe** (only when location is available), **Alfabetycznie** (A→Z), and **Wg kategorii** (group by category). It MUST NOT offer "Otwarte teraz". When location is unavailable, the list defaults to Alfabetycznie. {Clarify R1}

*Search & filter*
- **FR-016**: In the Map view, tapping the search bar ("Szukaj na mapie…") MUST open a search overlay: a focused field with native caret, an "Anuluj" button that dismisses it unchanged, and a parchment results panel over the map grouped **Ostatnie** (persisted recents), **Podpowiedzi** (live matches), and **Kategorie** (quick category filters). It MUST reuse the Home "search active" pattern and honor reduced motion. {Design "Search functionality"; reuses 002 FR-028}
- **FR-017**: Search matching MUST be case- and accent-insensitive against name, category label, and comment, debounced ~150 ms, and MUST query the **full dataset regardless of the active category filter**. Selecting a result MUST dismiss the overlay, animate the camera to the place's coordinates, select its pin, and surface its mini-card; if the selected place's category is currently filtered out, the filter MUST first reset to "Wszystko" (all) so the pin is visible. An empty result MUST show "Brak wyników" plus the category quick-filters. {Design "Search functionality"; Clarify 2026-05-31}
- **FR-018**: Recent search queries MUST be persisted locally and re-filled on tap, **unified with Home** by reusing the same shared `recentSearchesProvider`/`shared_preferences` store — recents are one shared history across Home and the Map (no separate key). {Design "Ostatnie"; reuses 002; Clarify 2026-05-31}
- **FR-019**: In the Lista view, the search bar ("Filtruj listę…") MUST filter the rows live in place (same match logic), combined with the active category chip and the sort mode; clearing restores the full list; no matches shows "Brak wyników". {Design "List view — inline filter"}
- **FR-011**: Category filtering MUST use a **single shared multi-select set** (`activeCategories`) read by the pins, the sheet mini-cards, and the list. The Map MUST show a horizontally-scrollable category chip row — **Wszystko** (active by default) plus one chip per category present in the data — that acts as a quick shortcut into that set: tapping a category chip MUST set the filter to **just that category**; tapping "Wszystko" MUST clear the filter (all categories). When two or more categories are selected (via the filter sheet, FR-012), **no single category chip shows active** (and "Wszystko" is inactive). {Design "Category filter chips"; Clarify 2026-05-31; mirrors 002 FR-005/FR-006}
- **FR-012**: The trailing filter glyph (both views) MUST open a filter sheet that **multi-selects the same shared `activeCategories` set** (the chips are the quick, single-select version of this filter); applying it MUST narrow the pins, the sheet, and the list together. It MUST NOT offer an open-now toggle (no hours data). {Design "Filter glyph"; Clarify 2026-05-31}

*Navigation hand-off & data resilience*
- **FR-022**: Tapping a Navigate button (mini-card or row) MUST open the place in an external maps app (Google Maps / OS maps) via the shared `MapsLauncher` using the place's coordinates; if no maps app is installed, the maps URL MUST open in the browser. No in-app place detail is built in v1. {Design "Navigate"; reuses 002 FR-015}
- **FR-023**: The Map MUST show a graceful empty/error state with retry when the places fetch fails and no cache exists (map chrome intact), and MUST show the cached last-successful dataset when present. The places fetch is the data network call; no product analytics/tracking fires. {Constitution §1.7; mirrors 002 FR-016}

*Motion, localization, accessibility, guardrails*
- **FR-024**: The Map MUST implement the motion in `ANIMATIONS.md` — pin drop (460 ms easeOutBack, +60 ms/pin stagger), selected-pin scale-to-1.18 (250 ms) + infinite pulse ring (2400 ms), sheet slide+fade-up (360 ms), list fade-up stagger (sort 70 ms / header 140 ms / rows 160+i·45 ms), and Map↔Lista cross-fade (~300 ms) — and MUST disable all of it under OS reduced-motion (final states rendered instantly; tap feedback retained). {ANIMATIONS.md; Constitution §XI}
- **FR-025**: All user-visible Map copy MUST come from the ARB localization layer with Polish canonical (the design's Polish copy is verbatim and unchanged); the Map MUST render correctly in pl/en/ar including full RTL parity for Arabic; no hard-coded user-visible strings. {Constitution §1.5, §V}
- **FR-026**: The Map MUST meet accessibility: semantic labels on pins and icon-only controls (search, filter, locate-me, navigate, toggle, sort, chips); interactive targets ≥ 44–48 dp; usable at OS-maximum font scale; RTL parity. {Constitution §XI; Design "Conventions"}
- **FR-027**: The Map v1 MUST NOT display star ratings, review counts, verification badges, opening hours/status, addresses, walk time, an "Add place" FAB/center FAB, or a login wall. {Design v1 "no ratings/badges"; mirrors 002 FR-023}

**Feature-Specific Non-Functional Requirements:**

- **NFR-001**: Map interaction (pan/zoom), pin-drop and selection animations MUST sustain 60 fps on the Pixel 7 (API 34) reference device with the launch dataset.
- **NFR-002**: The Map MUST be functionally and visually correct in pl/en/ar including RTL — verified by widget tests per locale.
- **NFR-003**: The Map MUST meet WCAG 2.1 AA contrast/touch-target standards per Constitution §XI; the custom basemap's label/marker contrast MUST be verified against the warm palette.
- **NFR-004**: The Map view MUST show its first frame (basemap + chrome) within ~1 s of tab selection; pins appear when the (shared, possibly cached) places fetch resolves; the map MUST remain interactive during the fetch and while a location fix is pending.
- **NFR-005**: Location handling MUST honor Constitution §1.7 — only-while-using, approximate accuracy by default; the app MUST NOT request background or precise location for this feature.

**Out of Scope:**

- **In-app place detail** — replaced by the external Google Maps hand-off (FR-022); the in-app PlaceDetail screen is a later feature.
- **Open-now filter/sort & opening hours** — no hours in the data; returns when an Hours column exists.
- **Address/district & walk-time** — not in the data / not derivable (no routing); return with data/backend.
- **Ratings, reviews, verification badges** — curated launch; the trust surface is post-v1.
- **Add-place / Suggest-edit from the map** — the contribute flow is a separate feature; no Add FAB on the map.
- **Offline map tiles & turn-by-turn directions** — navigation is an OS hand-off; offline tiles are post-MVP.
- **Backend API place source** — v1 uses the shared Google Sheet; the API replaces it later via the same repository.
- **Dark-map Maghrib prayer pill & prayer-window pin pulse** (Constitution §4.4 MapDark / §VI.1) — the custom dark style ships via theme tokens, but the prayer-time banner/pill and prayer-window pulse are a later prayer-times feature.

**Clarifications:**
- 2026-05-31 Q: Whole Map tab or just the surface? → A: Whole tab (both views, search, filter, sort, sheet, locate-me, animations).
- 2026-05-31 Q: Data source? → A: Shared Google-Sheet `PlaceRepository`; backend API later.
- 2026-05-31 Q: Map engine? → A: MapLibre (`maplibre_gl`) with the custom warm style; new dependency approved; tile source deferred to planning.
- 2026-05-31 Q: Device location? → A: Add it — user dot, locate-me, distance, Najbliższe sort; graceful fallback if denied; approximate/only-while-using.
- 2026-05-31 Q: Mini-card/row content? → A: Glyph + name + category + optional comment + Mawaqit link (mosques) + Navigate; distance only with location; no status/address/walk-time.
- 2026-05-31 Q: Sort modes? → A: Najbliższe (if location) + Alfabetycznie + Wg kategorii; no Otwarte teraz.

---

## 5. Deferred Decisions

- **MapLibre tile source & finished style JSON** — choose the tile provider (MapTiler / Stadia / Protomaps / self-hosted) and complete the custom warm style (the `assets/map_styles/*.json` files are stubs). **Rationale:** affects licensing/cost/keys; not a spec-level product decision. **Resolution phase:** Architecture (ADR) + Implementation.
- **Geolocation package choice** — pick the geolocation plugin and wire it to the existing `PermissionsService`. **Rationale:** dependency decision. **Resolution phase:** Architecture/Implementation.
- **Reintroduce open/closed status & hours** — when an Hours column is added to the sheet/backend, add the status dot + label and the "Otwarte teraz" filter/sort. **Resolution phase:** Data + follow-up feature.
- **Reintroduce address/district & walk time** — when address data (and a routing/ETA source) exist, restore the design's address line and walk-time. **Resolution phase:** Data/Backend + follow-up.
- **Camera default & zoom** — exact Warsaw centre/zoom and clustering thresholds tuned during implementation against the dataset. **Resolution phase:** Implementation.
- **Finer category mapping** — if the sheet later distinguishes grocer vs Islamic shop (and butcher), expand chips/pins toward the full design set. **Resolution phase:** Data + Implementation.
- **Camera-pan-on-select** — whether selecting a pin/card also pans the camera (design says optional). **Resolution phase:** Implementation (UX polish).
- **EN/AR translations** — Polish canonical; human-translated (Islamic terms not machine-translated); placeholders accepted for v1. **Resolution phase:** Implementation.

---

## 6. Definition of Done

- All functional requirements (FR-001 … FR-027) implemented and verified.
- All test cases (TC-1 … TC-23) pass on the Pixel 7 API 34 emulator.
- Edge cases (location denied/slow, long names, max font scale, no comment, no Mawaqit, coincident pins, empty dataset, fetch failure with/without cache, malformed rows, background/resume, no-maps-app, unsupported locale, accent-insensitive search) handled and tested.
- Lean-v1 guardrails verified: no ratings, hours/status, address, walk-time, verification badges, Add FAB, or login on the Map (FR-027); faked/placeholder data not shown.
- Real MapLibre interactive map with the custom warm style ships (not the synthetic mini-map, not a vanilla style); pan/zoom verified; basemap contrast checked.
- Location path verified: dot + locate-me + distance + Najbliższe with permission; graceful Warsaw-overview fallback without; only-while-using + approximate per Constitution §1.7.
- Shared `PlaceRepository`/`placesProvider` is the single source of place data (Home + Map) — no duplicate place-loading code.
- Search (map overlay finds + flies + selects; recents persist), inline list filter, category chips, filter sheet, and sort modes all behave per FRs.
- Selection syncs pin ↔ card (scale + pulse); view toggle cross-fades to a staggered list.
- Localization complete for PL/EN/AR — Polish canonical (design copy verbatim); EN/AR placeholders allowed in v1 with a deferred note; RTL parity verified across both views.
- Accessibility audit passes WCAG 2.1 AA — semantic labels on pins/icon-only controls, ≥44–48 dp targets, contrast verified on the warm basemap and parchment chrome.
- Reduced-motion path verified: pin-drop, pulse, sheet slide, list stagger, and view cross-fade disabled; final state shown; tap feedback retained.
- Network behavior verified: successful fetch renders pins; failure shows cache or a graceful empty/error + retry; no analytics/tracking fires.
- Mandatory test types present: unit (distance/haversine, sort comparators, accent-insensitive matching, visible-places derivation, cluster grouping logic), widget (map chrome, pins, sheet, list, search overlay, RTL, reduced-motion, loading/error), integration (open Map → locate → select pin/card → search-fly → toggle to list → filter/sort → navigate hand-off).
- `flutter analyze` clean; `dart format` applied; widgets reference theme tokens (no magic literals) per Constitution §X.

---

## 7. Solution Overview

The Map screen is the spatial heart of Halal Map Polskie — the **Mapa** tab. It turns the same curated Google-Sheet place data that Home uses into a real, brand-styled interactive experience: a warm cocoa/cream MapLibre basemap dotted with category-coloured teardrop pins, a user-location dot, and a bottom sheet of place mini-cards, all behind a Map ↔ Lista toggle. It is deliberately lean for launch — no ratings, verification badges, opening hours, addresses, or walk-times, because none of those exist in the data — but it is honest and complete on what does exist: name, category, coordinates, an optional comment, and (for mosques) a Mawaqit prayer-times link. The one capability Home skipped is added here: the device's own location, powering the user dot, locate-me, accurate distances, and a "Najbliższe" sort — requested only-while-using and approximate by default, with a graceful Warsaw-overview fallback when permission is withheld.

Both views share one data spine and one chrome. A guest can tap a pin to select it (scale + pulse) and read its synced mini-card, filter pins and cards by category chip, search the map (an overlay that finds a place and flies the camera to it), and hand off to Google Maps to navigate. Switching to Lista cross-fades to a staggered, scrollable list of the same places with a live inline filter and a sort pill (Najbliższe / Alfabetycznie / Wg kategorii). A filter sheet (category multi-select) narrows both views. Every motion in the design's `ANIMATIONS.md` is honored, and every one of them is disabled under OS reduced-motion. All Polish copy is verbatim and final; the screen is fully localized (pl/en/ar with RTL) and meets WCAG 2.1 AA.

Architecturally the Map consumes the existing shared layer (`lib/core/places/` `Place`/`Category`/`PlaceRepository`, the `MapsLauncher`, the recent-searches store, the permissions service, and the theme tokens) rather than re-rolling any of them, and it renders inside the app's existing 5-tab nav shell with no dock of its own — exactly the boundaries 002 established. New to this feature are a MapLibre map engine (with a custom warm style + a tile source chosen in planning) and a geolocation package wired to the existing permission pre-prompt. As the sheet grows columns (hours, address) or is replaced by the backend, the dropped surfaces (status, address, walk-time, open-now) return through the same repository without re-architecting.

---

## 8. Key Entities

**Data Model Reference:** `.ai_project_memory/architecture.md` → Domain Model (Place). The Map reuses the exact shared subset Home loads from the Google Sheet (002 §8).

**Place** (shared — `lib/core/places/`): a halal-relevant location.
- **Purpose:** the mappable/listable unit — one pin and one card/row per place.
- **Key attributes (v1, from the sheet):** `id` (derived stable key); `name`; `category` (canonical 6-value enum, parsed from the Polish category string); `lat`, `lng` (coordinates — present for every row; used for the pin position, distance, and the camera fly-to); `comment` (optional secondary line); `mawaqitLink` (optional prayer-times link, surfaced on mosque cards/rows).
- **Not present in v1 data (and therefore not shown):** opening hours/status, address/district, walk-time, photo, rating, verification, featured flag, city.
- **Relationships:** referenced by selection state (selected pin ↔ selected card by `id`); consumed by both Home and the Map from the same repository.

**Device Location** (session, not persisted): the user's current position.
- **Purpose:** powers the user-location dot, locate-me recentre, per-place distance (haversine), and the Najbliższe sort.
- **Key attributes:** latitude/longitude + availability/permission status. Requested only-while-using; approximate accuracy by default (Constitution §1.7). Not stored, not linked to identity, never sent off-device for this feature.
- **Relationships:** combined with each `Place`'s coordinates to derive distance and ordering.

**Recent Search** (local, guest): a persisted recent query string.
- **Purpose:** the "Ostatnie" group in the map search overlay.
- **Key attributes:** the query text; persisted in the same local store Home uses.
- **Relationships:** re-runs a search over `Place`s on tap.

---

## 9. UX Considerations

- **Primary user actions:** pan/zoom the map; tap a pin to select + read its card; tap a card to select its pin; filter by category chip; open the search overlay and fly to a place; recentre on self (locate-me); switch to Lista; filter/sort the list; open a filter sheet; navigate to a place via Google Maps.
- **User journey touchpoints:** the spatial counterpart to Home — reached from the Mapa tab, from Home's mini-map / "Otwórz mapę", and from Home search/category shortcuts that land the user on a filtered map.
- **Accessibility:** WCAG 2.1 AA — semantic labels for pins and every icon-only control; ≥44–48 dp targets; usable at max font scale; full RTL parity; verified basemap/label contrast on the warm palette.
- **Usability:** calm, premium, brand-warm — the custom cocoa/cream cartography, teardrop pins, and motion are the differentiators. With status/ratings/addresses absent, cards lean on the category tile + name + optional comment + distance; the screen must still feel complete and intentional, never like a stripped-down list over a generic map.

**Design References:**
- Handoff: [`specs/design/map/`](../design/map/) — `README.md`, `PROMPT.md`, `ANIMATIONS.md`, `reference/` (HTML + screenshots + styles.css), `tokens/`. (Status/address/walk-time/Dock adapted to data + shell per §2.)
- Design system: `constitution-frontend.md` §II (tokens, §II.4 map style), §III (MapPin/ClusterBubble/SearchBar/CategoryPill/AppBottomSheet), §V (Polish vocabulary), §VI (interaction/animation).
- Related: `specs/design/home_page/handoff_search_refresh/` (the "search active" pattern reused by the map search overlay).

---

## 10. Integration Context

**External Systems:**

- **Halal-places Google Sheet (published CSV):** the v1 place source (shared with Home).
  - **Business purpose:** a hand-maintained place list the team edits directly before any backend exists.
  - **Data exchange:** the app fetches the published CSV and parses rows into `Place`; read-only. Reused via the shared repository; cached after a successful fetch.
  - **Timing:** on Map load (and Home load); cached locally.
- **Map tile provider (MapLibre):** vector/raster tiles for the custom warm basemap.
  - **Business purpose:** the real interactive map surface; the brand requires a custom style, not a vanilla provider style.
  - **Data exchange:** the app requests map tiles/style; a client key may be required (per build flavor, never committed). Provider chosen in planning (§5).
  - **Timing:** continuously while the Map view is visible.
- **Device location services (OS):** the user's position.
  - **Data exchange:** the OS provides an approximate fix only-while-using, after the user grants permission; nothing leaves the device for this feature.
  - **Timing:** on Map open (pre-prompt → OS prompt) and on locate-me.
- **Google Maps / OS maps app:** external destination for "Navigate" (FR-022), in lieu of in-app place detail.
  - **Data exchange:** the app passes the place's coordinates into a maps deep-link; nothing flows back.
  - **Timing:** on tapping a Navigate button.

**Integration Constraints:**
- The places fetch and the map tiles are the network calls; no product analytics/tracking (Constitution §1.7).
- Map provider/tile keys are configured per build flavor (`--dart-define`), never hard-coded or committed (Constitution §2 / Security).
- Location is only-while-using and approximate by default; no background or precise location for this feature (Constitution §1.7).
- The maps redirect is a one-way OS hand-off; browser fallback if no maps app is installed (no crash).
- Malformed sheet rows are skipped by the shared parser, never fatal.

---

## 11. Feature-Specific Constraints

**FC-1:** Map renders content only — navigation is owned by the app shell (no own dock; cross-tab actions go through the shell). {Mirrors 002 FC-1}

**FC-2:** The place data layer is shared and source-swappable — `PlaceRepository` (in `lib/core/places/`) feeds both Home and the Map; the Map keeps no private place model or loader. {Mirrors 002 FC-2}

**FC-3:** Honest-to-data surface — because the data has no hours/address/walk-time/ratings/verification, the Map shows none of them rather than faking them; the custom warm map style and pins carry the premium feel instead. {§2 conflicts; Constitution §1.6}

**FC-4:** Brand-mandated cartography — the basemap MUST use the custom MapLibre warm style; falling back to a vanilla provider style is prohibited (Constitution §II.4 / Anti-Patterns).

### Feature-Specific Assumptions

**FA-1:** Polish-first copy — Polish canonical and verbatim from the design; EN/AR derived; Islamic terms human-translated.
**FA-2:** The published Google Sheet is reachable at runtime and its column shape is stable; the shared parser tolerates blank optional columns and unknown categories.
**FA-3:** Coordinates are present and good enough to place pins, compute distance, fly the camera, and open the correct place in Google Maps.
**FA-4:** A basic last-successful-fetch cache is acceptable for v1 resilience (reused from Home).
**FA-5:** A MapLibre tile source and a usable custom style are available (or producible) for launch; until then the map style stubs are completed in implementation (§5).

---

## 12. References

**Project Context:**
- **Constitution:** `.ai_project_memory/constitution.md` — §1.5 (Localization & RTL), §1.6 (trust/guest browsing), §1.7 (privacy defaults — location only-while-using, approximate, no analytics), §2 (security/keys).
- **Frontend Constitution:** `.ai_project_memory/constitution-frontend.md` — §I (MapLibre stack), §II (tokens, §II.4 map style), §III (MapPin/ClusterBubble/SearchBar/CategoryPill/AppBottomSheet), §IV.4 (Map screen catalogue), §V (Polish vocabulary), §VI (interaction/animation), §X, §XI, §XII.
- **Architecture:** `.ai_project_memory/architecture.md` — Place domain model, category enum, map provider (MapLibre) + geocoding integration rows, future backend.

**Related Specifications:**
- `specs/002-home-screen/spec.md` — establishes the shared `PlaceRepository`, recent-searches store, maps launcher, 5-tab shell, and lean-v1 guardrails the Map reuses.
- `specs/001-onboarding-flow/spec.md` — the location-permission pre-prompt the Map reuses.

**Design Reference:** Map v1 handoff bundle: `specs/design/map/` (`README.md`, `PROMPT.md`, `ANIMATIONS.md`, `reference/`, `tokens/`).
**Data Reference:** the shared Halal-places Google Sheet (published CSV).

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details in functional requirements (engine/package named only where the PO decision requires it)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

### Traceability & Context
- [x] Design handoff (`specs/design/map/`) + live data source referenced
- [x] Constitution references included
- [x] All clarifications documented with timestamps
- [x] Deferred decisions documented
- [x] Conflicts (design vs data reality + 002 decisions) documented and resolved

---

## Execution Status
- [x] User description parsed
- [x] Key concepts extracted (two views + toggle, MapLibre engine, pins/cluster/user-dot, search overlay + inline filter + filter sheet, sort, bottom sheet mini-cards, location, shared Google-Sheet data, lean guardrails, 5-tab shell)
- [x] Ambiguities resolved through clarification: specify round (scope, data source, engine, location, card content, sort) + clarify 2026-05-31 (category-filter model, distance format, sheet content/order, search-vs-filter scope, unified recents)
- [x] User scenarios defined (TC-1 through TC-23)
- [x] Requirements generated (FR-001 through FR-027, NFR-001 through NFR-005)
- [x] Entities identified (shared Place + session Device Location + local Recent Search)
- [x] Review checklist passed
