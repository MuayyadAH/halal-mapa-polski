# Implementation Plan: Home Screen (v1)

**Branch**: `002-home-screen` | **Date**: 2026-05-30 | **Spec**: [spec.md](./spec.md)

## Summary

Build the launch (v1) **Strona** (Home) screen as a Flutter feature at `lib/features/home/`, rendered as the scroll body of the existing `/home` branch in the 5-tab `StatefulShellRoute` (no new bottom nav). Sections: a serif **Header**, a resting **search bar**, single-select **category chips**, a **live synthetic mini-map** with ambient motion, and a horizontal **"Polecane miejsca"** (auto-featured) card row. It is deliberately lean — no ratings, distance, verification badges, per-card city, open/closed status, Add, login, browse-all, or Popular-cities — because the launch data (a shared Google Sheet) provides only name, category, and coordinates.

Place data lives in a **shared layer** at `lib/core/places/`: one `Place` model, one canonical `Category` enum, and one `PlaceRepository` that fetches the published Google Sheet (CSV) at runtime (via existing `dio` + the `csv` parser), caches the last good fetch, and exposes a shared `placesProvider`. Home and the future **Map** feature consume the same source. Home derives an auto-featured sample (round-robin across categories), a category chip set from the categories present, and the mini-map count. Tapping a card opens the place in **Google Maps** (`url_launcher`); bookmarks persist via `shared_preferences`.

Three new dependencies (approved/necessary): **`url_launcher`** (FR-015), **`shared_preferences`** (FR-014 + fetch cache), **`csv`** (parse the sheet). HTTP reuses existing **`dio`**.

---

## Implementation Conflicts

**Status**: No Conflicts Found

- `lib/features/home/home_screen.dart` is a placeholder stub → **replaced** by the real Home (gradient `Scaffold` body, no AppBar, no own dock).
- `scaffold_with_tabs.dart` (5-tab nav) and `app_router.dart` (`/home`) **unchanged**.
- `pubspec.yaml` gains `url_launcher`, `shared_preferences`, `csv`.
- `lib/l10n/app_*.arb` gains ~12 keys/locale (additive).
- `main.dart` gains a one-line `await SharedPreferences.getInstance()` bootstrap + provider override.
- No conflict with 001 (disjoint module; reuses 001's reduced-motion entrance primitive only).

**Conflict Check Date**: 2026-05-30 · **Checked Against**: `specs/001-onboarding-flow/plan.md` (only prior plan).

---

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter 3.24+ (stable; per `pubspec.yaml`)
**Primary Dependencies**:
- `flutter_riverpod` 3.3.1 — `placesProvider` (shared FutureProvider), `homeProvider`, `bookmarksProvider`, repo/service providers
- `go_router` 17.2.3 — existing 5-tab shell; Home → `/map` for mini-map
- `dio` 5.6 (existing) — fetch the published Google Sheet CSV (follows 307 redirect)
- **`csv`** (NEW) — parse the sheet CSV safely (quoted fields)
- **`url_launcher`** (NEW) — open a place in external Google Maps (FR-015)
- **`shared_preferences`** (NEW) — bookmark id set + last-good-fetch cache
- `flutter_localizations` + `intl` 0.20.2 — ARB localization incl. ICU plural (Polish 3-form count)
- Fonts bundled: Lora, Plus Jakarta Sans, Amiri

**Storage** (all `shared_preferences`, non-sensitive — not secure storage):
- `bookmarked_place_ids` (`List<String>`) — bookmarks (shared with Saved tab)
- `places_cache_csv` (+ timestamp) — last successful sheet fetch (resilience)

**Data source**: live published Google Sheet (`Longitude, Latitude, Name, Category, Comment, Mawaqit Link`; categories Meczet/Sklep/Restauracja/Cmentarz). The sheet fetch is the only network call (no analytics/tracking).

**Testing**:
- Unit: `parsePlacesCsv` + category mapping, `PlaceRepository` (cache/fallback via mock dio+prefs), featured auto-pick, `BookmarkRepository`, `MapsLauncher` URI
- Widget: each section incl. ×3 locales (RTL for ar), reduced-motion, loading/error states
- Integration: open Home → fetch → filter → bookmark (persists) → tap mini-map → Map tab

**Target Platform**: iOS 13+ / Android API 23+ (Pixel 7 / API 34 reference)
**Project Type**: mobile (Flutter; no backend in repo)

**Performance Goals**: mini-map + entrance ≥ 60 fps (NFR-001); first frame (skeletons + chrome) ≤ ~1s, content after the fetch resolves, screen interactive during fetch (NFR-004)

**Constraints**:
- One network call (the sheet fetch); graceful cache/empty/error + retry on failure; no analytics (Constitution §1.7)
- Lean guardrails: no ratings/distance/verification/city/status/Add/login/greeting (FR-023)
- WCAG 2.1 AA — ≥44 px, glyph/icon labels, font-scale, RTL (NFR-003)
- Polish canonical; ARB only (Constitution §1.5/§V); theme tokens only (§X) → extend `tokens.dart` (R8)

**Scale/Scope**: ~8 widgets; `Place`+`Category` (shared) + `MapsLauncher`; `PlaceRepository`+`BookmarkRepository`; 2 notifiers + shared `placesProvider`; 3 locales (~12 keys each); "hundreds of places" eventually (live sheet has a modest list today)

---

## Constitution Check

**Applicable**: frontend + universal. **Sources**: `constitution.md` §1.1–1.7/§2/§4; `constitution-frontend.md` §I–§XIII.

### Compliance Checklist
- [x] **§1.1**: Feature-first — Home under `lib/features/home/`; **shared** place layer + `MapsLauncher` under `lib/core/` (cross-feature plumbing)
- [x] **§1.2**: Naming conventions
- [x] **§1.3**: Error handling — fetch failure → cache/empty/error + retry; bad rows skipped; bookmark write failure → snackbar
- [x] **§1.5 / FR-021**: Localization & RTL — ARB only; `EdgeInsetsDirectional`; ar RTL tested
- [x] **§1.6**: Guest-first; no login wall; verification surface intentionally absent (Complexity Tracking)
- [x] **§1.7**: No analytics/trackers; only the sheet fetch hits the network; bookmarks/cache non-identifying
- [x] **§2**: Bookmarks/cache in `shared_preferences` (non-sensitive), not secure storage; no secrets in code (sheet id is public)
- [x] **§4 / §XII**: Unit + widget + integration tests
- [x] **Frontend §I.1**: Stack — Riverpod/go_router/intl/dio present; adds `url_launcher`, `shared_preferences`, `csv` (recorded in §I.1)
- [x] **§II / §X**: Tokens from `tokens.dart` (+ Home/mini-map additions, R8); no magic literals
- [x] **§III**: Introduces lean `PlaceCard`, `CategoryPill`, `SearchBar`, `SectionHeader`
- [x] **§IV**: Implements HomeC · Guest
- [x] **§V**: pl/en/ar; Polish canonical; chip vocabulary reconciliation deferred
- [x] **§VI**: ambient + entrance per handoff; reduced-motion respected (FR-020)
- [x] **§IX**: Riverpod only
- [x] **§XI**: a11y — labels, 44 px, font-scale, RTL
- [x] **§XIII**: no hardcoded strings, no `EdgeInsets.only(left/right)`, no magic literals, no logic in widgets

**Violations**: one intentional/documented — lean-v1 omits the verification surface (no system exists yet). See Complexity Tracking.

---

## Project Structure

### Documentation (this feature)
```
specs/002-home-screen/
├── spec.md · plan.md · research.md · data-model.md · quickstart.md
├── contracts/
│   ├── place_repository.md      # shared — Google Sheet fetch + parse + cache
│   ├── bookmark_repository.md    # shared — shared_preferences
│   └── maps_launcher.md          # shared — url_launcher
├── checklists/requirements.md
└── tasks.md                      # Phase 2 — NOT created by /plan
```

### Source Code (repository root)
```
lib/
├── core/
│   ├── places/                                   # NEW shared place layer (Home + future Map)
│   │   ├── domain/
│   │   │   ├── place.dart                         # Place (id,name,category,lat,lng,comment?,mawaqitLink?)
│   │   │   └── category.dart                      # Category enum (6) + parsePolish()
│   │   └── data/
│   │       ├── place_repository.dart              # PlaceRepository + GoogleSheetPlaceRepository + parsePlacesCsv + placesProvider
│   │       ├── places_config.dart                 # kPlacesSheetId (public, --dart-define-able)
│   │       └── bookmark_repository.dart           # BookmarkRepository (shared_preferences) — shared with Saved tab
│   ├── maps/
│   │   └── maps_launcher.dart                     # NEW — MapsLauncher over url_launcher (FR-015)
│   ├── network/dio_client.dart                    # existing dioProvider (reused for the fetch)
│   ├── routing/{app_router,scaffold_with_tabs}.dart  # unchanged
│   └── theme/tokens.dart                          # MODIFIED — Home type sizes, gradient end, HmpMap palette (R8)
├── features/home/
│   └── presentation/
│       ├── home_screen.dart                       # REPLACES stub — gradient scroll, sections, entrance, AsyncValue states
│       ├── state/
│       │   ├── home_notifier.dart                 # selectedCategory + derived featured/available-categories/count
│       │   └── bookmarks_notifier.dart            # Notifier<Set<String>>
│       └── widgets/
│           ├── home_header.dart · home_search_bar.dart
│           ├── category_chips.dart · category_style.dart   # Category → color/glyph/labelKey
│           ├── mini_map.dart · mini_map_painter.dart
│           ├── place_card.dart · section_header.dart
│           └── home_skeletons.dart · home_error_state.dart # loading + empty/error+retry
├── l10n/app_{pl,en,ar}.arb                         # MODIFIED — ~12 keys each
└── main.dart                                       # MODIFIED — await SharedPreferences; override sharedPreferencesProvider

pubspec.yaml                                        # MODIFIED — add url_launcher, shared_preferences, csv

test/
├── core/
│   ├── places/{place_repository,category,bookmark_repository}_test.dart
│   └── maps/maps_launcher_test.dart
└── features/home/
    └── presentation/{home_screen,state/*,widgets/*}_test.dart
integration_test/home_flow_test.dart
```

**Structure Decision**: Place data is **shared** under `lib/core/places/` (domain + data) because the Map feature will consume the identical model/repository (Spec FR-017) — Home keeps only presentation. `MapsLauncher` and bookmark storage are likewise shared (`lib/core/`). This is the unification the user asked for: one place model, one loader, two screens.

---

## Phase 0: Outline & Research
See [`research.md`](./research.md) — R1 (shell nav), R2 (live Google-Sheet fetch via dio+csv, cache/fallback), R3 (sheet-shaped Place + derived id), R4 (6-enum, parse the 4 present), R5 (deterministic featured auto-pick), R6 (url_launcher maps), R7 (shared_preferences bookmarks), R8 (token extensions), R9 (mini-map painter + ambient), R10 (entrance reuse), R11 (Riverpod shapes + AsyncValue states), R12 (ARB/plural), R13 (deps incl. csv), R14 (no MCP). No NEEDS CLARIFICATION remain.

## Phase 1: Design & Contracts
- **Data model** — [`data-model.md`](./data-model.md): shared `Place`/`Category`, `placesProvider`, `homeProvider` derivations, bookmark + cache keys, Google-Sheet contract.
- **Contracts** — [`place_repository.md`](./contracts/place_repository.md) (shared fetch/parse/cache), [`bookmark_repository.md`](./contracts/bookmark_repository.md), [`maps_launcher.md`](./contracts/maps_launcher.md).
- **Stack constitution update** — `constitution-frontend.md` §I.1 adds `url_launcher`, `shared_preferences`, `csv` (and notes `dio` is reused for the sheet fetch). Token additions in `tokens.dart` (R8).
- **Post-design re-check**: passes; only the documented lean-v1 verification omission stands.

## Phase 2: Task Planning Approach
*Describes what `/ai1st-dev-tasks` will do.*

**Ordering** (dependency-respecting):
1. pubspec (`url_launcher`, `shared_preferences`, `csv`) + `flutter pub get`
2. ARB keys + `flutter gen-l10n`
3. `Category` (+ `parsePolish`) and `Place`; `places_config.dart`
4. `parsePlacesCsv` + `PlaceRepository`/`GoogleSheetPlaceRepository` (+ cache); `placesProvider`
5. `BookmarkRepository`; `MapsLauncher`
6. `main.dart` SharedPreferences bootstrap + provider override
7. `homeProvider` (featured auto-pick + filter + available categories + count); `bookmarksProvider`
8. `tokens.dart` additions (R8)
9. Leaf widgets (`section_header`, `home_header`, `home_search_bar`, `category_chips`/`category_style`, `place_card`, `home_skeletons`, `home_error_state`)
10. `mini_map_painter` → `mini_map` (ambient controllers)
11. `home_screen.dart` assembly (AsyncValue → skeleton/empty/error/content; entrance stagger)
12. Unit → widget (×locales, reduced-motion, loading/error) → integration tests

Mark `[P]` for independent files. **Estimated**: ~32–38 tasks.

---

## Dependencies Analysis

### Prerequisites
| Dependency | Source | Status | Notes |
|------------|--------|--------|-------|
| Flutter scaffold + 5-tab shell + `/home` | scaffold/001 | Required | Home renders inside |
| `core/network` `dioProvider` | scaffold | Required | Reused for the sheet fetch |
| `tokens.dart` | scaffold | Required | Extended (R8) |
| ARB pipeline | scaffold | Required | `flutter gen-l10n` after edits |
| 001 reduced-motion entrance primitive | 001 | Optional | Reused; promote to `lib/shared/` if needed |
| `url_launcher`, `shared_preferences`, `csv` | THIS plan | Required | Added to pubspec |

### Provides (to other features)
| Output | Used By | Description |
|--------|---------|-------------|
| Shared **`Place`/`Category`/`PlaceRepository`/`placesProvider`** | **Map** (pins), Submit, Saved, Place detail | Single place source loaded from the Google Sheet → backend later; the unification the user requested |
| `MapsLauncher` | Map, future Place detail, Navigate actions | "Open in maps" hand-off |
| `BookmarkRepository` + `bookmarked_place_ids` | **Saved (Zapisane)** tab | Shared local bookmark store |
| `parsePlacesCsv` | Any sheet-backed importer / tests | Pure CSV→Place mapping |
| Home/mini-map design tokens | Map basemap, warm surfaces | Shared palette + Home type scale |

---

## Work Streams
- [x] **[UI]** — widgets, state, shared place layer, service — single Flutter stream
- [x] **[TEST]** — unit + widget + integration (rolls up with [UI])
- [ ] [API]/[DB]/[INFRA]/[INT] — N/A (no backend; key-value prefs only; sheet fetch is read-only HTTP)

---

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Lean-v1 omits verification surface (and city/status), diverging from §1.6/§3.3 and parts of the handoff | No verification system yet; the launch data has no city/hours/featured | Faking trust/city/status signals would mislead; restored as the sheet/backend grows (Deferred Decisions) |
| Three new deps (`url_launcher`, `shared_preferences`, `csv`) | FR-015 maps hand-off; FR-014 local persistence + fetch cache; live-CSV parsing | Platform channels / secure storage / hand-rolled CSV are worse fits; all three are tiny and standard |
| Live network fetch (relaxes the earlier offline guarantee) | User chose live sheet as the source of truth | A bundled asset (offline) was offered and declined; cache + graceful failure mitigate the network dependency |

---

## Use Case Specific NFRs

### Performance
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Mini-map ambient + entrance | ≥ 60 fps | DevTools timeline, Pixel 7 (NFR-001) |
| First frame (skeletons + chrome) | ≤ ~1s; interactive during fetch | Integration test + manual (NFR-004) |

### Reliability
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Fetch failure handling | cache shown, else empty/error + retry; no crash | Unit (repo) + widget (error state) + integration (mock failure) |
| Bookmark persistence | survives app kill/relaunch | Integration test |

### Accessibility / Localization
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Targets / labels / status | ≥44 px; glyph+icon labels | Widget tests |
| Locale + RTL | pl/en/ar incl. RTL | Widget tests per locale (NFR-002) |
| Plural | Polish 3-form count on mini-map pill | Widget test at N=1,2,5,22 |

---

## Acceptance Criteria

### BRD Traceability
No BRD; [`spec.md`](./spec.md) is canonical (FR-001…FR-023, NFR-001…004, TC-1…TC-17). Design: `specs/design/home_page/handoff_home_v1/`. Data: the shared Google Sheet.

### Layout & Shell
- [FR-001] Vertical scroll over gradient inside the 5-tab shell; no own dock
- [FR-002] Sections: Header · Search · Chips · Mini-map · Polecane miejsca; no Popular-cities, no browse-all
- [DS-§II] Tokens only (Home sizes/gradient/mini-map palette added, R8)

### Header / Search / Chips
- [FR-003] H1 "Miejsca *halal* w Polsce" + subtitle; guest (no avatar/greeting/login/city)
- [FR-004] Resting search bar "Szukaj miejsca w Polsce…" → search stub
- [FR-005] Single-select chips: Wszystko + a chip per category present (Restauracje/Meczety/Sklepy/Cmentarze)
- [FR-006] Chip filters the Featured row in place (animated); mini-map stays nationwide; no nav
- [FR-007] Canonical 6-`Category`; sheet mapping (Meczet→masjid, Sklep→shop, Restauracja→restaurant, Cmentarz→cemetery); unknown safe-fallback

### Mini-map
- [FR-008] Synthetic map (no tiles/outline), pins, "<N> miejsc w Polsce" pill, "Otwórz mapę"
- [FR-009] Tap → Mapa tab
- [FR-010] Ambient drift/float/pulse/sheen
- [FR-011] Count = loaded dataset size · [NFR-001] ≥60 fps

### Featured cards
- [FR-012] Card: gradient placeholder + category badge + bookmark + name — no city/status/rating/distance
- [FR-013] Featured = deterministic varied sample across available categories (auto-pick)
- [FR-014] Bookmark persists locally (shared_preferences); instant pop+fill; Saved-tab-readable
- [FR-015] Card body tap → external Google Maps by coordinates; no in-app detail; no-maps-app → browser

### Data / network
- [FR-016] Shared `PlaceRepository` fetches the published Google Sheet (CSV) at runtime; loading skeletons; cache/empty/error+retry on failure; no analytics
- [FR-017] `Place`/`Category`/`PlaceRepository` shared under `lib/core/`; Home + future Map consume the same source
- [TC-11/TC-13] Loads from the live sheet; fetch failure is graceful

### Motion / a11y / i18n / guardrails
- [FR-019] Entrance staggered fade-up · [FR-020] reduced motion disables entrance + all ambient; press feedback kept
- [FR-021/NFR-002] ARB pl/en/ar incl. RTL; no hardcoded strings
- [FR-022/NFR-003] ≥44 px, glyph/icon labels, font-scale usable
- [FR-023] No ratings/reviews/verification/distance/city/status/Add/login/greeting on Home

### Testing
- [Universal §4] Unit + widget + integration present; each TC-1…TC-17 covered by ≥1 test

---

*Based on Constitution — see `.ai_project_memory/constitution.md` and `.ai_project_memory/constitution-frontend.md`*
