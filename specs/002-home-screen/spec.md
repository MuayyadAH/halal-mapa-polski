# Home Screen (v1) Specification

**Feature Branch**: `002-home-screen`
**Created**: 2026-05-30
**Status**: Draft
**Input**: User description: "Implement the home page — read the design specs `specs/design/home_page/handoff_home_v1`"

---

## 1. Primary User Story

As a guest user (not logged in, location unknown) opening the **Strona** (Home) tab of Halal Map Polskie, I want to see a warm, alive landing screen that lets me search, filter halal places by category, preview a living map, and browse a curated set of places — without ratings, distances, or a login wall — so that I can immediately start discovering halal-friendly places anywhere in Poland.

---

## 2. Details

**Problem:** At launch the product has no community/crowdsourcing system, no verification badges, no user accounts in flow, and no reliable user location. The place data is a small, hand-maintained list (a shared Google Sheet) of name + category + coordinates. A new visitor needs a single, trustworthy entry point that conveys "halal places everywhere in Poland" and lets them browse without friction, using only the data that actually exists at launch.

**Clarifications:**

### Round 1 (2026-05-30)

- Q: Navigation — handoff 4-tab dock vs existing 5-tab nav? → A: **Keep the existing 5-tab nav as-is.** Home renders only its scroll content inside that shell; the handoff's 4-tab dock (`BottomDock`) is out of scope.
- Q: Follow the handoff's lean v1 (no ratings/distance/verification badges/Add)? → A: **Yes** — omit them; the constitution's fuller trust surface is post-v1 (curated launch).
- Q: Where does Home's data come from? → A: *(superseded — see Data-source session below)* originally "curated Excel import"; now the real source is a shared Google Sheet (live fetch).
- Q: Category taxonomy? → A: **Canonical 6-value enum in the model**; Home surfaces only the categories present in the data.

### Session 2026-05-30 (Interaction)

- Q: When a user taps a city card, how does the city filter interact with the category chip? → A: *(superseded — the Popular-cities section was later removed; see Data-source session.)* A city card opens the Mapa tab, it does not filter Home.
- Q: Should the "Wszystkie miejsca" (browse-all) list stay on Home? → A: **Removed.** Browsing the full set of places is delivered by the separate Map feature.
- Q: With browse-all removed, what do the category chips filter? → A: **They filter the "Polecane miejsca" (Featured) row in place on Home** (single-select; "Wszystko" = all). Chips do not navigate away.
- Q: What happens when a user taps a place card body? → A: **It opens the place in external Google Maps** via a deep-link. No in-app place detail in v1.

### Session 2026-05-30 (Data source — the real Google Sheet)

The real launch dataset is a shared Google Sheet with columns `Longitude, Latitude, Name, Category, Comment, Mawaqit Link` and categories `Meczet, Sklep, Restauracja, Cmentarz`. It has **no city, no opening hours, and no featured flag**. Decisions:

- Q: How is the sheet loaded? → A: **Fetch the published Google Sheet (CSV) live at runtime.** This relaxes the earlier offline/no-network guarantee — the places fetch is the one allowed network call. Home shows loading skeletons while fetching and a graceful empty/error state on failure (with an optional cache of the last successful fetch for resilience). No analytics/tracking (Constitution §1.7 still holds).
- Q: No City column — what about card city and "Popularne miasta"? → A: **Drop the "Popularne miasta" section and the per-card city entirely for v1.** They return only if a City column is added to the sheet later.
- Q: No opening hours — what about open/closed status? → A: **Drop the open/closed status for v1.** It returns when an Hours column exists.
- Q: No featured flag — what feeds "Polecane miejsca"? → A: **Auto-pick featured** — the app selects a varied sample across the available categories (no editorial flag in the source yet).
- Q: Unification — this data also feeds the Map list (separate feature). → A: **The places data layer is shared** (`lib/core/places/`): one `Place` model, one `Category` enum, one `PlaceRepository` that loads the sheet. Home and the future Map both consume it; neither owns a private copy.

### Session 2026-05-30 (Search & pull-to-refresh — handoff_search_refresh)

The `handoff_search_refresh` bundle was authored against a richer "Home Screen v2" (personalized greeting, ratings/distance/district/verified shields, Warsaw "nearby" data, a 5-slot dock with an Add FAB) that contradicts our lean guest v1 and the real data. Decisions:

- Q: Header peek in search-active — personalized "Cześć, Amir"? → A: **Stick to the search functionality + design; ignore the rest.** Dim the existing **guest** header (Opacity 0.4 + IgnorePointer); no greeting/name (preserves FR-023).
- Q: Suggestion-row content (rating/distance/district/verified)? → A: **Name + category only** — live-filter the loaded places by name; tapping a suggestion opens the place in Google Maps (FR-015). No rating/distance/district/verification (not in v1 data).
- Q: "Ostatnie" recent searches store? → A: **Persist recents locally** in `shared_preferences` (the store already used for bookmarks); re-fill the query on tap.
- Q: What does pull-to-refresh fetch (handoff's "W pobliżu / Warsaw")? → A: **Re-fetch the places sheet** (re-run `placesProvider`); the handoff's nearby/Warsaw target does not apply.
- Implementation note: pull-to-refresh uses Flutter's `RefreshIndicator` (styled cocoa) backed by the sheet re-fetch — chosen over the handoff's fully-custom pinned indicator for maintainability (Constitution: simple/clean). The custom pinned-spinner + content-offset visual is deferred polish.

**Requirement Conflicts (handoff/constitution vs reality):**

- **FR-023 vs `constitution-frontend.md` §3.4 / §1.6 / §3.3** (PlaceCard with rating + distance; verification always visible): Home v1 omits ratings, distance, and verification badges. **Resolution:** handoff/curated-launch wins for v1; fuller card deferred post-v1.
- **FR-001/FR-002 vs §4.1** (5-tab nav incl. Dodaj + Profil): the app keeps its 5-tab nav; Home renders no dock; the handoff 4-tab dock is out of scope.
- **Handoff Home anatomy vs available data:** the handoff shows per-card **city**, **open/closed status**, a **"Popularne miasta"** section, and curated **featured** places. The launch data (Google Sheet) provides none of city/hours/featured. **Resolution:** drop card-city, status, and the Popular-cities section for v1; auto-pick featured. These return as the sheet gains columns (Deferred Decisions).
- **Offline guarantee:** earlier drafts required no network; the chosen live-sheet fetch supersedes that (FR-016).

---

## 3. Workflow

**Business Workflow** — *guest opens the Home tab (default landing after onboarding):*

1. The user selects (or lands on) the **Strona** tab. Home renders as a vertical scroll over a warm parchment→sand gradient, inside the existing 5-tab nav shell.
2. Home requests the places dataset from the shared repository, which fetches the published Google Sheet. While the fetch is in flight, sand-tone skeletons show for the cards.
3. Top-level blocks animate in with a brief staggered fade-up (Header → Search → Mini-map → Featured).
4. The user sees the **Header** ("Miejsca *halal* w Polsce" + subtitle) — no avatar, greeting, or login.
5. A resting **search bar** invites "Szukaj miejsca w Polsce…". Tapping it would open the full search experience (out of scope — stub).
6. A horizontal **category chip** row shows **Wszystko** (active) plus a chip for each category present in the data (Restauracje, Meczety, Sklepy, Cmentarze). Selecting one filters the "Polecane miejsca" (Featured) row in place (single-select); the mini-map stays nationwide.
7. A **live mini-map** preview pans, pins float, the mosque pin pulses, a sheen sweeps — subtly and continuously. It shows a "<N> miejsc w Polsce" count from the dataset. Tapping it (or "Otwórz mapę") switches to the **Mapa** tab.
8. **"Polecane miejsca"** shows a horizontal row of auto-selected place cards: a category-tinted gradient placeholder, a category badge, a bookmark toggle, and the place name. Tapping a card body opens the place in **Google Maps**; tapping the bookmark saves it locally.
9. If the data fetch fails and no cache exists, Home shows a graceful empty/error state instead of cards; the rest of the screen still renders.
10. If the OS reduced-motion setting is on, all entrance + ambient animation is skipped (final/resting states); press feedback remains.

*Category filter yields nothing:* the Featured section shows "Brak miejsc w tej kategorii — wkrótce dodamy więcej".

**Test Cases / Acceptance Scenarios:**

- **TC-1: Renders inside the 5-tab shell** — opening Strona shows the Home scroll over the gradient; the existing 5-tab bottom nav stays; Home draws no dock of its own.
- **TC-2: Section order** — sections top→bottom are Header, Search, Category chips, Mini-map, Polecane miejsca. There is no Popular-cities section and no browse-all list.
- **TC-3: Header content** — H1 "Miejsca halal" + line break + "w Polsce" with "halal" emphasized; subtitle present; no avatar/greeting/city pill/login.
- **TC-4: Category filter** — with Wszystko active, tapping "Meczety" shows only masjid places in the Featured row (animated); "Wszystko" restores all; the mini-map is unaffected.
- **TC-5: Empty category** — selecting a category with no places shows "Brak miejsc w tej kategorii — wkrótce dodamy więcej" instead of cards.
- **TC-6: Mini-map opens Map tab** — tapping the mini-map or "Otwórz mapę" switches to the Mapa tab.
- **TC-7: Mini-map count reflects data** — with N places loaded, the pill reads the localized "<N> miejsc w Polsce".
- **TC-8: Place card content (lean)** — a card shows a category-tinted gradient placeholder, a category badge, a bookmark control, and the name — and shows no city, no open/closed status, no rating, and no distance.
- **TC-9: Place card opens external maps** — tapping a card body (not the bookmark) opens Google Maps / the OS maps app at the place's coordinates; no in-app place detail appears.
- **TC-10: Bookmark persists in guest mode** — toggling a bookmark, then restarting the app, keeps the place bookmarked (same local store the Saved tab reads); the toggle pops + swaps fill on tap.
- **TC-11: Data loads from the live sheet** — on open, Home fetches the published Google Sheet and renders cards/mini-map count from it; the same repository is the one the Map feature will consume.
- **TC-12: Loading skeletons** — while the fetch is in flight, sand-tone shimmer skeletons (not spinners) show for the cards, replaced by content when the fetch resolves.
- **TC-13: Fetch failure is graceful** — if the fetch fails with no cached data, Home shows a non-blocking empty/error state (and a retry affordance), not a crash; cached data (if present) is shown instead.
- **TC-14: Entrance stagger + reduced motion** — with animations on, top-level blocks fade-up with increasing delay; with reduced motion on, no entrance animation plays (final state shown).
- **TC-15: Ambient motion + reduced motion** — with animations on, the mini-map drifts, pins float (staggered), the mosque pin pulses, a sheen sweeps; with reduced motion on, all four are disabled and the map is static.
- **TC-16: Localization + RTL** — all copy renders from ARB in pl/en/ar; Arabic mirrors to RTL with the Arabic font; no hard-coded strings.
- **TC-17: Auto-featured selection** — "Polecane miejsca" shows a varied sample across the available categories (deterministic given the same dataset), capped at the configured count.

**Edge Cases:**

- *Very long place name* → truncates gracefully (ellipsis) without breaking the card.
- *Maximum OS font scale* → text scales; critical controls (bookmark, open-map) remain reachable.
- *Category selected then app backgrounded/resumed* → selected category + scroll position preserved.
- *Place with no photo (the v1 default)* → category-tinted gradient placeholder; layout identical to the eventual photo state.
- *Empty dataset (sheet returns 0 rows)* → Featured shows the empty state; mini-map count reads "0".
- *Fetch failure with a prior cache* → last successful dataset is shown; with no cache → empty/error state with retry.
- *Malformed sheet row* (bad coordinates / unknown category) → the row is skipped (or category falls back) without failing the whole load.
- *Device locale not pl/en/ar* → Home defaults to Polish.
- *No maps app installed when a card is tapped* → the maps URL opens in the default browser; Home does not crash.

---

## 4. Requirements

**Requirement Documents:**

- **Design handoff:** `specs/design/home_page/handoff_home_v1/` — source of truth for layout, color, typography, and motion (the city/status/popular-cities/featured-flag elements are adapted to the available data per §2).
- **Live data source:** the shared Halal-places Google Sheet (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`).

**Functional Requirements:**

- **FR-001**: Home MUST render as a vertical scroll (the "Strona" tab content) inside the existing 5-tab nav shell, over the warm parchment→sand gradient, and MUST NOT render its own bottom navigation/dock. {Handoff §3; Clarify R1}
- **FR-002**: Home MUST present its sections top→bottom: Header, Search bar, Category chips, Live mini-map, "Polecane miejsca" (Featured). Home MUST NOT include a Popular-cities section or a browse-all list. {Handoff §3; Clarify Interaction + Data-source}
- **FR-003**: The Header MUST show the H1 "Miejsca halal" + line break + "w Polsce" with "halal" visually emphasized (italic accent) and the subtitle "Restauracje, meczety i sklepy — w całym kraju". No avatar, greeting, city pill, or login. {Handoff §4.1}
- **FR-004**: Home MUST show a resting search bar (placeholder "Szukaj miejsca w Polsce…"); tapping it opens an in-place **search-active** overlay (FR-028) within the Home tab — the bottom nav stays mounted. {Handoff §4.2; handoff_search_refresh Screen A}
- **FR-028**: The search-active overlay MUST show: a dimmed (Opacity 0.4 + IgnorePointer) peek of the existing guest header; a focused field with a native caret and an "Anuluj" button that closes it; and a suggestions panel of three groups — **Ostatnie** (locally-persisted recent queries, re-fill on tap), **Podpowiedzi** (live place matches by name, each = category tile + name + category label; tapping opens the place in Google Maps per FR-015 and records the query), and **Kategorie** (chips for the categories present; tapping selects that category and closes search). It MUST NOT show ratings, distance, district, or verification (not in v1 data). Entrance/stagger animations honor reduced motion. {handoff_search_refresh Screen A + ANIMATIONS.md; Clarify 2026-05-30}
- **FR-029**: Home MUST support pull-to-refresh: an overscroll pull re-fetches the places sheet (re-runs `placesProvider`), showing a refresh indicator and rebuilding the Featured row + mini-map count on completion. {handoff_search_refresh Screen B; Clarify 2026-05-30}
- **FR-005**: Home MUST show a horizontally-scrollable, single-select category chip row: **Wszystko** (active by default) plus one chip per category present in the dataset — at launch Restauracje, Meczety, Sklepy, Cmentarze — each non-default chip carrying its category-color tile + glyph. {Handoff §4.3; Data-source}
- **FR-006**: Selecting a chip MUST filter the "Polecane miejsca" (Featured) row to that category, in place (single-select; Wszystko = all), with an animated change. The mini-map MUST stay nationwide and chips MUST NOT navigate away from Home. {Handoff §4.3; Clarify Interaction}
- **FR-007**: The data model MUST use the canonical 6-value `Category` enum (restaurant, masjid, grocer, butcher, shop, cemetery). The sheet's Polish categories MUST map: Meczet→masjid, Restauracja→restaurant, Cmentarz→cemetery, Sklep→shop (grocer/butcher and the grocer/Islamic-shop split are not distinguishable in the current data). Home surfaces a chip only for categories present in the data. Unknown category strings MUST fall back safely (skipped or a default), not crash the load. {Clarify R1 + Data-source; Architecture domain model}
- **FR-008**: Home MUST show a live mini-map preview: a stylized, fully synthetic street-map (NOT a country outline, NOT real map tiles) with category pins, a place-count pill "<N> miejsc w Polsce", and an "Otwórz mapę" affordance. {Handoff §4.4}
- **FR-009**: Tapping the mini-map or "Otwórz mapę" MUST switch the app to the Mapa tab. {Handoff §4.4}
- **FR-010**: The mini-map MUST run continuous, subtle ambient motion: basemap drift, staggered pin float, an expanding pulse ring behind the mosque pin, and a light sheen sweep — all subject to FR-020. {Handoff §5.2}
- **FR-011**: The mini-map place count MUST reflect the total number of places in the loaded dataset (nationwide). {Handoff §4.4}
- **FR-012**: "Polecane miejsca" MUST show a horizontally-scrollable row of place cards. Each card MUST show a category-tinted gradient placeholder, a category badge, a bookmark toggle, and the place name. The cards MUST NOT show a city, an open/closed status, a rating, or a distance (none of which exist in the v1 data). {Handoff §4.5; Data-source}
- **FR-013**: The featured set MUST be auto-selected from the dataset as a varied sample across the available categories (the source has no featured flag), capped at a configured count, and deterministic for a given dataset. {Data-source}
- **FR-014**: Users MUST be able to toggle a bookmark on any place card in guest mode; the state MUST persist locally across sessions (no account), be stored where the Saved (Zapisane) tab can read it, and give immediate visual feedback (pop + fill swap). {Handoff §4.5, §7; Constitution §1.6}
- **FR-015**: Tapping a place card's body (anywhere except the bookmark) MUST open that place in an external maps app (Google Maps / OS maps) via a maps deep-link using the place's coordinates. In-app place detail is NOT built in v1; this stands in for it. Launching the external app is an OS hand-off (not an app backend call). If no maps app is installed, the maps URL opens in the browser. {Clarify Interaction; §10}
- **FR-016**: Home data (the places list + total count) MUST be loaded at runtime by a **shared** `PlaceRepository` that fetches the published Google Sheet (CSV) and parses it into the `Place` model. This is the only network call Home makes; there is no product analytics/tracking (Constitution §1.7). Home MUST show loading skeletons during the fetch and a graceful empty/error state (with retry, and showing a cached last-successful dataset when available) on failure. {Data-source; Constitution §1.7}
- **FR-017**: The places data layer (`Place`, `Category`, `PlaceRepository`) MUST be shared (under `lib/core/`) so the Home screen and the future Map feature consume the same source; neither feature keeps a private copy. {Data-source — unification}
- **FR-018**: Each section MUST use the shared section-header pattern (serif h2 title; optional right-side count). {Handoff §4.9}
- **FR-019**: On first render (animations enabled), Home top-level blocks MUST animate in with a staggered fade-up. {Handoff §5.1}
- **FR-020**: When the OS reduced-motion / disable-animations setting is on, Home MUST disable all entrance and ambient animations (final/resting states) and keep only instant press feedback. Cards and chips MUST give press feedback (brief scale-down) on tap. {Handoff §5.3–5.4; Constitution §XI}
- **FR-021**: All user-visible Home copy MUST come from the ARB localization layer with Polish canonical; Home MUST render correctly in pl/en/ar incl. full RTL parity for Arabic. No hard-coded user-visible strings. {Constitution §1.5, §V}
- **FR-022**: Home MUST meet accessibility: interactive targets ≥ 44 px; text alternatives for category glyphs and icon-only controls (bookmark, open-map); usable at OS-maximum font scale; RTL parity. {Handoff §8; Constitution §XI}
- **FR-023**: Home v1 MUST NOT display star ratings, review counts, verification badges, distance (km), per-card city, open/closed status, an "Add place" button / center FAB, a login wall, or a personalized greeting. {Handoff §10; Clarify; Data-source}

**Feature-Specific Non-Functional Requirements:**

- **NFR-001**: Mini-map ambient + entrance animations MUST sustain 60fps on the Pixel 7 (API 34) reference device.
- **NFR-002**: Home MUST be functionally and visually correct in pl/en/ar incl. RTL — verified by widget tests per locale.
- **NFR-003**: Home MUST meet WCAG 2.1 AA contrast/touch-target standards per Constitution §XI.
- **NFR-004**: Home MUST show its first frame (skeletons + static chrome) within ~1s of tab selection; place content appears when the sheet fetch resolves. The screen MUST remain interactive (scroll, chips) during the fetch.

**Out of Scope:**

- **Full search screen** — search bar routes to a stub; search is a separate feature.
- **In-app place detail** — replaced by the Google Maps redirect (FR-015); the in-app PlaceDetail screen is later.
- **Map tab content** — the mini-map is a synthetic preview; the real Mapa screen (MapLibre) is a separate feature that will reuse the shared `PlaceRepository` (FR-017).
- **Browse-all list & "Popularne miasta"** — removed from Home; full browsing lives in the Map feature. Popular-cities returns only if the sheet gains a City column.
- **Per-card city & open/closed status** — dropped in v1 (no city/hours data); return when those columns exist.
- **Real photos** — gradient placeholders are intentional; real photos post-MVP.
- **Backend / Excel pipeline** — v1's source is the live Google Sheet; backend API is later.
- **Saved (Zapisane) tab UI** — this feature only persists bookmark state.
- **Handoff `BottomDock` / 4-tab dock** — app keeps the 5-tab nav.

---

## 5. Deferred Decisions

- **Reintroduce city + "Popularne miasta"** — when a **City** column is added to the sheet, restore the per-card city and the Popular-cities section (the design already specifies them). **Resolution phase:** Data + a follow-up feature.
- **Reintroduce open/closed status** — when an **Hours** column is added, compute and show status (dot + label). **Resolution phase:** Data + follow-up.
- **Editorial featured flag** — when a **Featured** column is added, replace the auto-pick with the curated flag. **Resolution phase:** Data.
- **Finer category mapping** — if the sheet later distinguishes grocery vs Islamic shops (and butcher), expand chips/mapping toward the full handoff set ("Sklepy halal" / "Islamskie"). **Resolution phase:** Data + Implementation.
- **Chip vocabulary** vs Constitution §5.2 (e.g., "Sklepy" vs "Spożywczy") — PO confirms final Polish chip labels in the ARB. **Resolution phase:** Implementation (PO copy review).
- **Offline cache policy** — depth of the last-successful-fetch cache (TTL, storage) — basic cache for v1; refine later. **Resolution phase:** Implementation.
- **EN/AR translations** — Polish canonical; human-translated (Islamic terms not machine-translated); placeholders accepted for v1. **Resolution phase:** Implementation.
- **Mini-map basemap fidelity** — synthetic approximation tuned against the real Mapa style later. **Resolution phase:** Implementation.

---

## 6. Definition of Done

- All functional requirements (FR-001 through FR-023) implemented and verified.
- All test cases (TC-1 through TC-17) pass on the Pixel 7 API 34 emulator.
- Edge cases (long names, max font scale, background/resume, missing photo, empty dataset, fetch failure with/without cache, malformed rows, unsupported locale, no-maps-app) handled and tested.
- Lean-v1 guardrails verified: no ratings, distance, verification badges, city, status, Add, login, or greeting on Home (FR-023).
- Localization complete for PL/EN/AR — Polish canonical; EN/AR placeholders allowed in v1 with a deferred note. RTL parity verified across every section.
- Accessibility audit passes WCAG 2.1 AA — semantic labels on glyphs/icon-only controls, ≥44 px targets, contrast verified on parchment.
- Reduced-motion path verified: entrance + all four ambient effects disabled; static final state; press feedback retained.
- Bookmark state persists across app kill/relaunch and is readable by the Saved tab's store.
- The shared `PlaceRepository` is the single source of place data (Home today; Map later) — no duplicate place-loading code.
- Network behavior verified: successful fetch renders data; failure shows cache or a graceful empty/error + retry; no analytics/tracking fires.
- Mandatory test types present: unit (CSV parse/mapping, repository, category mapping, featured auto-pick), widget (sections + RTL + reduced-motion + loading/error), integration (open Home → fetch → filter → bookmark → open Map tab).
- `flutter analyze` clean; `dart format` applied; widgets reference theme tokens (no magic literals) per Constitution §X.

---

## 7. Solution Overview

The Home screen is the everyday landing surface of Halal Map Polskie — the **Strona** tab. It is deliberately lean for launch: places are a small, hand-maintained list in a shared Google Sheet (name, category, coordinates), with no community signals, no user location, and — at this stage — no city, opening-hours, or featured metadata. Home is built around exactly that data: a guest can browse a curated sample of places, filter by the categories that exist, preview a living map, and open any place in Google Maps — with no ratings, distance, verification badges, login, city labels, or open/closed status.

Visually and in motion the screen stays high-fidelity to the design handoff: a warm parchment→sand gradient scroll holding a serif header, a resting search bar, category chips, a **live synthetic mini-map** (drift, floating pins, pulsing mosque marker, sheen sweep), and a horizontal row of curated place cards. Entrance is a staggered fade-up; everything respects OS reduced-motion. The screen lives inside the existing 5-tab nav, rendering content only and routing the mini-map to the Mapa tab.

Architecturally, the place data lives in a **shared layer** (`lib/core/places/`): one `Place` model, one canonical `Category` enum, and one `PlaceRepository` that fetches and parses the published Google Sheet at runtime. Home derives its featured sample, category chips, and mini-map count from that single source; the future **Map** feature consumes the very same repository for its pins, so the two screens never diverge. Bookmarks persist locally so guests can save places before any account exists. As the sheet grows columns (city, hours, featured), the dropped sections (per-card city, open/closed status, "Popularne miasta") and editorial curation return without re-architecting.

---

## 8. Key Entities

**Data Model Reference:** `.ai_project_memory/architecture.md` → Domain Model (Place). Home + Map share a read-oriented subset loaded from the Google Sheet.

**Place** (shared — `lib/core/places/`): a halal-relevant location.
- **Purpose:** the core browsable/mappable unit, fed by the Google Sheet and (later) the backend.
- **Key attributes (v1, from the sheet):** `id` (derived stable key, e.g. name+coords — the sheet has no id); `name`; `category` (canonical 6-value enum, parsed from the Polish category string); `lat`, `lng` (coordinates — present for every row); `comment` (optional notes); `mawaqitLink` (optional prayer-times link).
- **Not present in v1 data (and therefore not shown):** city, opening hours, featured flag, photo, rating, verification, distance.
- **Relationships:** referenced by Bookmark (by `id`); consumed by Home (featured sample + mini-map) and the future Map (pins).

**Bookmark (local, guest):**
- **Purpose:** lets guests save places with no account.
- **Key attributes:** a set of place `id`s; persisted locally (non-sensitive); shared with the Saved (Zapisane) tab.
- **Relationships:** references Place by `id`.

> The earlier **City** entity is removed for v1 (no city data); it returns with a City column (Deferred Decisions).

---

## 9. UX Considerations

- **Primary user actions:** browse the auto-curated featured places; filter the featured row by category chip; open the Map (mini-map / "Otwórz mapę"); open a place in Google Maps (card tap); bookmark a place; tap the search bar (stub).
- **User journey touchpoints:** the default landing after onboarding; the home base between sessions; the first impression of the "halal everywhere in Poland" promise.
- **Accessibility:** WCAG 2.1 AA — text alternatives for category glyphs + icon-only controls; ≥44 px targets; usable at max font scale; full RTL parity for Arabic.
- **Usability:** calm and premium — cocoa/cream warmth, serif "halal" emphasis, and the alive mini-map are the differentiators. With city/status/ratings absent, the card leans on the category badge + name + the gradient placeholder; the screen must still feel complete and intentional.

**Design References:**
- Handoff: [`specs/design/home_page/handoff_home_v1/`](../design/home_page/handoff_home_v1/) (layout/motion; city/status/cities/featured adapted to data per §2).
- Design system: `constitution-frontend.md` §II (tokens — Home uses the handoff px + parchment gradient), §III (widgets), §V (Polish vocabulary), §VI (interaction/animation).

---

## 10. Integration Context

**External Systems:**

- **Halal-places Google Sheet (published CSV):** the v1 data source.
  - **Business purpose:** a hand-maintained place list the team edits directly, before any backend exists; the same source the Map will use.
  - **Data exchange:** the app fetches the published CSV (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`) and parses rows into `Place`. Read-only; nothing is written back.
  - **Timing:** on Home load (and reused by the Map feature). Cached locally after a successful fetch.
- **Google Maps / OS maps app:** external destination for "view place" (FR-015), in lieu of an in-app place detail.
  - **Data exchange:** the app passes the place's coordinates into a maps deep-link; nothing flows back.
  - **Timing:** on tapping a place card body.

**Integration Constraints:**

- The sheet fetch is the only network call; on failure Home degrades to cache or a graceful empty/error state with retry. No product analytics/tracking (Constitution §1.7).
- Malformed rows (bad coordinates / unknown category) are skipped or defaulted, never fatal.
- The maps redirect is a one-way OS hand-off; if no maps app is installed, the URL opens in the browser (no crash).

---

## 11. Feature-Specific Constraints

**FC-1:** Home renders content only — navigation is owned by the app shell (no own dock; cross-tab actions go through the shell).

**FC-2:** The place data layer is shared and source-swappable — `PlaceRepository` (in `lib/core/places/`) loads the Google Sheet today and can be re-pointed to the backend later; **both Home and the Map consume it** (no duplicate place models or loaders).

**FC-3:** Lean-v1 surface — because the data has no city/hours/featured/verification, Home shows none of those; it is honest about what exists rather than faking signals.

### Feature-Specific Assumptions

**FA-1:** Polish-first copy — Polish canonical; EN/AR derived; Islamic terms human-translated.
**FA-2:** The published Google Sheet is reachable at runtime and its column shape (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`) is stable; a parser tolerant of blank optional columns and unknown categories absorbs minor edits.
**FA-3:** Coordinates are present and good enough to open the correct place in Google Maps and to scatter the synthetic mini-map pins.
**FA-4:** A basic last-successful-fetch cache is acceptable for v1 resilience; richer offline policy is deferred.

---

## 12. References

**Project Context:**
- **Constitution:** `.ai_project_memory/constitution.md` — §1.5 (Localization & RTL), §1.6 (guest browsing), §1.7 (no analytics/tracking).
- **Frontend Constitution:** `.ai_project_memory/constitution-frontend.md` — §II, §III, §IV (HomeC · Guest), §V, §VI, §X, §XII.
- **Architecture:** `.ai_project_memory/architecture.md` — Place domain model, category enum, future backend integration.

**Design Reference:** Home v1 handoff bundle: `specs/design/home_page/handoff_home_v1/`
**Data Reference:** the shared Halal-places Google Sheet (published CSV).

**Related Specifications:** `specs/001-onboarding-flow/spec.md` (onboarding lands the user on Home).

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details in functional requirements
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
- [x] Design handoff + live data source referenced
- [x] Constitution references included
- [x] All clarifications documented with timestamps
- [x] Deferred decisions documented
- [x] Conflicts (handoff/constitution vs data reality) documented and resolved

---

## Execution Status
- [x] User description parsed
- [x] Key concepts extracted (sections, mini-map motion, lean guardrails, shared Google-Sheet data layer, 5-tab shell, category mapping)
- [x] Ambiguities resolved through three clarification sessions (nav/scope, interaction, data source)
- [x] User scenarios defined (TC-1 through TC-17)
- [x] Requirements generated (FR-001 through FR-023, NFR-001 through NFR-004)
- [x] Entities identified (shared Place + local Bookmark; City removed for v1)
- [x] Review checklist passed
