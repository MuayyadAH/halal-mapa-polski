# Implementation Plan: Onboarding Flow

**Branch**: `001-onboarding-flow` | **Date**: 2026-05-27 | **Spec**: [spec.md](./spec.md)

## Summary

Build the four-screen onboarding flow (Splash → Onboard 1·Find → Onboard 2·Trust → Onboard 3·Community → LocationPermission → Map) as a self-contained Flutter feature module at `lib/features/auth/`. The flow is fully offline, guest-friendly (no sign-in), localised across PL/EN/AR with full RTL support for Arabic, and routes the first-time user to the main Map experience while persisting an "onboarding completed" flag and the chosen locale to `flutter_secure_storage`. Returning users skip directly from a truncated 1-second splash to the Map; users with OS "Reduce Motion" enabled bypass the in-app splash animation entirely.

Technical approach: a `StatefulShellRoute` branch in `go_router` that holds the onboarding stack; a single Riverpod `Notifier` for navigation state across the 3 intro pages; a `LocaleNotifier` exposed via Riverpod that wraps `flutter_secure_storage` and drives `MaterialApp.locale`; a custom `AnimatedSplash` widget driven by `AnimationController` and respecting `MediaQuery.disableAnimations`.

---

## Implementation Conflicts

**Status**: No Conflicts Found

**Conflict Check Date**: 2026-05-27
**Checked Against**: This is the first feature in `specs/`; no prior plan.md files exist to conflict with. Confirmed no UC-XX or EN-XX plan files present.

---

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44 (stable channel)
**Primary Dependencies**:
- `flutter_riverpod` 3.3.1 — state management
- `go_router` 17.2.3 — routing (existing `StatefulShellRoute` 5-tab shell, plus a new branch for onboarding)
- `flutter_secure_storage` 10.3.1 — persists onboarding-completed flag + selected locale
- `flutter_localizations` (Flutter SDK) + `intl` 0.20.2 — ARB-driven localisation
- `permission_handler` 12.0.1 — location permission pre-prompt (already wired in `core/permissions/`)

**Storage**: `flutter_secure_storage` (native: iOS Keychain via `KeychainAccessibility.first_unlock`, Android encrypted shared preferences). Two keys:
- `onboarding_completed_at` — ISO-8601 timestamp string set when user first reaches the Map
- `selected_locale` — `pl` | `en` | `ar`

No backend API. No SQL/document database. No on-device cache (Hive/Drift) for this feature.

**Testing**:
- Unit: `flutter_test` for the onboarding repository, locale notifier, animation controller logic
- Widget: `flutter_test` with `WidgetTester` for each screen (including RTL variants per locale)
- Integration: `integration_test` for the cold-launch → Map happy path (both first-time and returning users), Reduce Motion bypass path, and language switch persistence

**Target Platform**: iOS 13+ / Android API 23+ (Pixel 7 / API 34 emulator is the reference for development)

**Project Type**: mobile (Flutter single codebase, no separate backend)

**Performance Goals**:
- Cold launch to first frame: depends on Flutter runtime, not feature-controlled
- Fastest path through onboarding (skip + browse-as-guest): < 10 s wall clock (NFR-001)
- Splash and Onboard transitions: maintain 60 fps on the Pixel 7 emulator (NFR-004)

**Constraints**:
- Fully offline-capable — no network calls during any onboarding screen (FR-018)
- No analytics or tracking events fire during onboarding (FR-019)
- WCAG 2.1 AA compliance — semantic labels, contrast verified on cocoa/cream surfaces, 44 sp hit targets (NFR-003)
- RTL parity required for Arabic locale (FR-006)
- Polish copy is the canonical source of truth (Constitution §V.4)

**Scale/Scope**:
- 5 user-facing widgets: `AnimatedSplash`, `OnboardFindScreen`, `OnboardTrustScreen`, `OnboardCommunityScreen`, `LocationPermissionScreen`
- 3 supporting widgets: `LanguagePicker`, `OnboardPageIndicator`, `OnboardPrimaryButton`
- 3 locales: pl, en, ar (~15–25 new ARB keys per locale)
- 1 repository + 2 Riverpod notifiers + 1 router branch addition

---

## Constitution Check

**Applicable Constitution**: frontend + universal (cross-cutting)
**Source Documents**:
- `.ai_project_memory/constitution.md` (core principles §1.5, §1.6, §1.7, §2, §4)
- `.ai_project_memory/constitution-frontend.md` (stack §I, design system §II, components §III, screen catalogue §IV, localisation §V, interaction §VI, code quality §X, a11y §XI, testing §XII, anti-patterns §XIII)

### Compliance Checklist

- [x] **Universal §1.1**: Feature-first layout — code lives under `lib/features/auth/` per kit convention
- [x] **Universal §1.2**: Naming conventions — `snake_case.dart` files, `PascalCase` classes (`OnboardFindScreen`), `lowerCamelCase` methods (`completeOnboarding`)
- [x] **Universal §1.3**: Error handling — no silent failures; localisation failures fall back to Polish (FR-005)
- [x] **Universal §1.5**: Localisation & RTL — all visible strings in ARB; `EdgeInsetsDirectional` only; RTL tested for Arabic
- [x] **Universal §1.6**: Trust & community UX — no sign-in required (FR-013); guest path is first-class CTA on Onboard 3 (FR-008)
- [x] **Universal §1.7**: Privacy defaults — analytics off (FR-019), no backend calls (FR-018), no third-party trackers, anonymous-by-design
- [x] **Universal §2**: Security — secrets via `flutter_secure_storage`, never `SharedPreferences`; no embedded keys
- [x] **Universal §4**: Testing — unit + widget + integration mandatory (covered in Section "Use Case Specific NFRs" below)
- [x] **Frontend §I.1**: Stack — uses Riverpod, go_router, flutter_secure_storage, flutter_localizations (all already in pubspec)
- [x] **Frontend §II**: Design system — tokens from `lib/core/theme/tokens.dart`; Lora display for headings, Plus Jakarta Sans for body, Amiri for Arabic
- [x] **Frontend §III**: Component library — reuses `PrimaryButton`, `OutlineButton`, `AppChip` patterns (currently scaffolded as Material 3 NavigationBar; will introduce concrete widgets in this feature)
- [x] **Frontend §IV**: Screen catalogue — adds Splash, Onboard 1·Find, Onboard 2·Trust, Onboard 3·Community, LocationPermission to the catalogue (already enumerated in `constitution-frontend.md` §IV.2 — no new screens beyond what's listed)
- [x] **Frontend §V.1**: MVP locale scope — pl, en, ar; Turkish + Ukrainian explicitly out of scope
- [x] **Frontend §V.2**: Polish UI vocabulary — uses canonical strings (`Pomiń`, `Kontynuuj`, `Przeglądaj jako gość`, `Pozwól`, `Nie teraz`, language pill labels) verbatim
- [x] **Frontend §V.3**: Arabic RTL rules — `Directionality.rtl` app-wide when locale = `ar`; no flipped brand icons; Amiri font for Arabic text
- [x] **Frontend §V.4**: Translation discipline — Polish is canonical; EN/AR translations placeholder-acceptable for v1 with translator review before release
- [x] **Frontend §VI**: Interaction & animation — splash animation timing from design source; Reduce Motion respected (FR-020)
- [x] **Frontend §IX**: State management — Riverpod (single state-management solution per constitution)
- [x] **Frontend §X**: Code quality — `flutter analyze` clean, `dart format`, sound null safety, no widget files over 300 lines (target ~150 lines for each onboarding screen)
- [x] **Frontend §XI**: Accessibility — semantic labels on every CTA and language pill, 44 sp hit targets, contrast verified, RTL parity, Reduce Motion handled
- [x] **Frontend §XII**: Testing — three mandatory test types
- [x] **Frontend §XIII**: Anti-patterns — no hardcoded user-visible strings (ARB), no `EdgeInsets.only(left:/right:)`, no magic colour/spacing literals (tokens only), no logic in widgets (notifiers + use-cases)

**Violations Found**: None.
**Remediation**: N/A.

---

## Project Structure

### Documentation (this feature)
```
specs/001-onboarding-flow/
├── spec.md                  # Feature specification (input)
├── plan.md                  # This file
├── research.md              # Phase 0 — technical decisions
├── data-model.md            # Phase 1 — state shape + persistence keys
├── quickstart.md            # Phase 1 — how to run/test locally
├── contracts/               # Phase 1 — internal Dart interfaces
│   ├── onboarding_repository.md
│   └── locale_service.md
├── checklists/
│   └── requirements.md      # Spec quality checklist (from /ai1st-po-specify)
└── tasks.md                 # Phase 2 output — NOT created by /plan
```

### Source Code (repository root)

```
lib/
├── core/
│   ├── routing/
│   │   ├── app_router.dart                    # MODIFIED — added /splash and /onboarding/* routes outside the 5-tab shell
│   │   └── scaffold_with_tabs.dart            # MODIFIED — tab labels now ARB-driven (proves FR-017)
│   ├── permissions/
│   │   └── permissions_service.dart           # unchanged
│   ├── storage/
│   │   └── secure_storage.dart                # unchanged
│   └── theme/
│       ├── tokens.dart                        # unchanged
│       └── theme.dart                         # MODIFIED — Amiri added to `fontFamilyFallback` on every TextStyle (resolves cross-cutting concern from research §10; required for FR-006 Arabic headings)
├── features/
│   └── auth/                                  # NEW feature module for this spec
│       ├── data/
│       │   └── onboarding_repository.dart     # NEW — wraps secure_storage for the two keys
│       ├── domain/
│       │   └── onboarding_state.dart          # NEW — enums + state classes (no Freezed yet; trivial enums)
│       └── presentation/
│           ├── screens/
│           │   ├── animated_splash_screen.dart       # NEW — CustomPaint-driven pin/crescent + wordmark + loader
│           │   ├── onboard_intro_screen.dart         # NEW — PageView shell with shared top/bottom chrome
│           │   ├── onboard_find_screen.dart          # NEW — Onboard 1 (page content only)
│           │   ├── onboard_trust_screen.dart         # NEW — Onboard 2
│           │   ├── onboard_community_screen.dart     # NEW — Onboard 3
│           │   └── location_permission_screen.dart   # NEW
│           ├── widgets/
│           │   ├── language_picker.dart              # NEW — top-right pl/en/ع pill row
│           │   ├── onboard_page_indicator.dart       # NEW — 3 dots
│           │   ├── soft_bg.dart                      # NEW — shared warm gradient + radial blobs (splash + onboarding + location-permission)
│           │   └── stagger_animations.dart           # NEW — `FadeRiseIn` / `ScaleFadeIn` widgets + `OnboardEntranceController` mixin (respects Reduce Motion per FR-020)
│           └── state/
│               ├── onboarding_notifier.dart          # NEW — flow state + complete() persistence
│               └── locale_notifier.dart              # NEW — locale + persists choice
│
│   Note: an `onboard_layout.dart` was planned originally; its role was absorbed into `onboard_intro_screen.dart` because the shared chrome only needs to exist around the PageView (one screen, not three).
├── l10n/
│   ├── app_pl.arb                             # MODIFIED — add ~20 new keys (onboarding copy)
│   ├── app_en.arb                             # MODIFIED — placeholder EN translations
│   └── app_ar.arb                             # MODIFIED — placeholder AR translations
├── app.dart                                   # MODIFIED — `locale:` driven by LocaleNotifier
└── main.dart                                  # MODIFIED — bootstrap reads onboarding flag before runApp

test/
└── features/
    └── auth/
        ├── data/
        │   └── onboarding_repository_test.dart
        ├── presentation/
        │   ├── screens/
        │   │   ├── animated_splash_screen_test.dart
        │   │   ├── onboard_find_screen_test.dart
        │   │   ├── onboard_trust_screen_test.dart
        │   │   ├── onboard_community_screen_test.dart
        │   │   └── location_permission_screen_test.dart
        │   └── state/
        │       ├── onboarding_notifier_test.dart
        │       └── locale_notifier_test.dart
        └── golden/                            # OPTIONAL — golden tests for design-system parity
            ├── onboard_find_light_pl.png
            ├── onboard_find_dark_ar.png
            └── ...

integration_test/
└── onboarding_happy_path_test.dart           # NEW — cold launch → Map for first-time + returning + reduce-motion paths
```

**Structure Decision**: Flutter mobile feature module under `lib/features/auth/` with the canonical `data/` + `domain/` + `presentation/{screens,widgets,state}/` layered layout from `constitution-frontend.md` §VIII. The feature complexity (5 screens, 3 supporting widgets, 1 repository, 2 notifiers, 1 router branch) genuinely warrants the sub-folder split per the "when complexity warrants" rule — flat would be too crowded.

---

## Phase 0: Outline & Research

See [`research.md`](./research.md) for the consolidated technical decisions. Topics covered:

1. Splash animation implementation pattern (sequenced `AnimationController` + `TweenSequence`)
2. Reduce Motion detection via `MediaQuery.disableAnimations`
3. Language picker widget pattern (custom widget that taps into `LocaleNotifier`)
4. First-launch detection on app bootstrap (sync `secure_storage` read before `runApp`)
5. go_router routing for the onboarding shell (separate top-level branch outside the 5-tab `StatefulShellRoute`)
6. Page transitions for Onboard 1/2/3 (`PageView` with controller for swipe + indicator sync)
7. Native-splash to in-app-splash handoff (no visible seam — same background colour, immediate transition)
8. System locale detection (`PlatformDispatcher.locale` + fallback to Polish)
9. Onboarding state machine (3 states: notStarted, inProgress, completed)
10. Persistence layer abstraction (`OnboardingRepository` interface, `flutter_secure_storage`-backed impl)

**Output**: research.md with all decisions resolved. No NEEDS CLARIFICATION items remaining (the spec was already clean post-clarify session).

---

## Phase 1: Design & Contracts

### Data Model

See [`data-model.md`](./data-model.md). Onboarding has no domain entities (no Place, Verification, etc.). It has UI state and persistence keys:

- **`OnboardingStatus`** enum: `notStarted` | `inProgress` | `completed`
- **`AppLocale`** enum: `pl` | `en` | `ar`
- **`LocationPermissionStatus`** enum: `notDecided` | `granted` | `denied` (mirrors `permission_handler`'s `PermissionStatus`, narrowed to the three cases we care about)
- **`OnboardingState`** — Riverpod state shape: `{ status: OnboardingStatus, currentPage: int, locale: AppLocale }`
- **Persistence keys** (in `flutter_secure_storage`):
  - `onboarding_completed_at` — ISO-8601 timestamp set when user reaches Map for the first time
  - `selected_locale` — `pl` | `en` | `ar`

### Contracts (internal — no HTTP)

No backend API per FR-018. Contracts are Dart interface definitions for the persistence and locale-management layers. See:
- [`contracts/onboarding_repository.md`](./contracts/onboarding_repository.md) — `OnboardingRepository` interface
- [`contracts/locale_service.md`](./contracts/locale_service.md) — `LocaleNotifier` / `LocaleService` interface

Concrete implementations live in `lib/features/auth/data/onboarding_repository.dart` and `lib/features/auth/presentation/state/locale_notifier.dart`.

### Stack Constitution Update

No new technologies introduced. All packages used by this feature (`flutter_riverpod`, `go_router`, `flutter_secure_storage`, `flutter_localizations`, `permission_handler`) are already listed in `constitution-frontend.md` §I.1. No update required.

---

## Phase 2: Task Planning Approach

*This section describes what `/ai1st-dev-tasks` will do — NOT executed during `/plan`.*

**Task Generation Strategy**:
- Load `.ai/2_templates/tasks-template.md` as the base
- Generate tasks from Phase 1 design docs (data-model, contracts, structure)
- Each contract → unit test task + implementation task
- Each screen → widget test task + screen implementation task
- Each user story (TC-1 through TC-13) → integration test task or contribution to one
- ARB key population per locale → one task per locale

**Ordering Strategy** (dependency-respecting):
1. ARB keys + l10n regen (must precede any widget code that uses them)
2. Domain enums (`OnboardingStatus`, `AppLocale`, etc.)
3. `OnboardingRepository` (unit-testable in isolation)
4. `LocaleNotifier` (depends on `secureStorageProvider` already in core/storage)
5. `OnboardingNotifier` (depends on repository)
6. Shared widgets (`LanguagePicker`, `OnboardPageIndicator`, `OnboardLayout`)
7. Five screens in design order (Splash → Onboard 1 → 2 → 3 → LocationPermission)
8. `app_router.dart` modifications (wire onboarding branch into go_router)
9. `main.dart` + `app.dart` modifications (locale from notifier; first-launch routing decision)
10. Widget tests per screen
11. Integration test (`onboarding_happy_path_test.dart`)

Mark `[P]` for parallel-executable tasks (independent files — e.g., the five screen implementations can run in parallel after shared widgets land).

**Estimated Output**: ~30 numbered tasks in `tasks.md`.

---

## Dependencies Analysis

### Prerequisites

| Dependency | Source | Status | Notes |
|---|---|---|---|
| Flutter scaffold (lib/main.dart, app.dart, core/theme/, core/routing/) | Step-one scaffold (completed) | Required | All in place |
| `core/storage/secure_storage.dart` | Step-one scaffold | Required | Provider already exposed |
| `core/permissions/permissions_service.dart` | Step-one scaffold | Required | `requestLocationWhenInUse()` already implemented |
| `core/theme/tokens.dart` design tokens | Step-one scaffold | Required | All colours/typography/spacing available |
| `lib/l10n/app_*.arb` files + `l10n.yaml` | Step-one scaffold | Required | ARB pipeline wired; `flutter gen-l10n` must run after each ARB change |
| `flutter_secure_storage`, `flutter_riverpod`, `go_router`, `permission_handler` in pubspec | Step-one scaffold | Required | All present |

### Provides (to other features)

| Output | Used By | Description |
|---|---|---|
| `OnboardingRepository` with `isCompleted()` API | App bootstrap, future Settings screen | Allows other features to check whether user has completed onboarding (e.g., for "View intro again" affordance post-MVP) |
| `LocaleNotifier` (Riverpod provider) | Every screen with localised text; Settings → Język picker | The source-of-truth for the app's active locale; persists choices |
| `selected_locale` secure-storage key | Settings screen (future) | Settings reads/writes this directly to change language |
| `onboarding_completed_at` secure-storage key | Future analytics tooling if ever opt-in | Documents the moment of first successful onboarding |
| Three new shared widget patterns (`LanguagePicker`, `OnboardPageIndicator`, button styles) | Future onboarding-adjacent screens (e.g. relaunch tutorial, settings refresh) | Reusable composition pieces |
| `SoftBg` widget — warm gradient + soft radial blobs | Any screen wanting the brand's ambient warm background (login, register, modals) | Cheap (no `BackdropFilter` blur); produced by this feature |
| `FadeRiseIn` / `ScaleFadeIn` widgets + `OnboardEntranceController` mixin | Any screen wanting staggered entrance animations with built-in Reduce Motion respect | One mixin captures the FR-020 a11y rule for the whole app |
| Amiri `fontFamilyFallback` on every TextStyle in `theme.dart` | Every screen with text — Arabic glyphs now render in Amiri automatically when the primary family (Lora / PJS) lacks coverage | Solves the cross-cutting concern noted in research §10; required for FR-006 |

---

## Work Streams

### Active Streams for This Feature

- [x] **[UI]** — All screens, widgets, state, repository — single Flutter stream
- [ ] [API] — N/A (no backend)
- [ ] [DB] — N/A (no SQL/document DB; only secure_storage key-value)
- [x] **[TEST]** — Unit + widget + integration tests (rolls up with [UI] since same developer can do both in Flutter)
- [ ] [INFRA] — N/A
- [ ] [INT] — N/A (no cross-stream integration needed)

This is a single-stream feature. No parallelisation across teams; parallelism is at the file level within the implementation phase (see `[P]` markers in `tasks.md` when generated).

---

## Use Case Specific NFRs

### Performance
| Requirement | Target | Measurement |
|---|---|---|
| Fastest onboarding path (skip + browse-as-guest) | < 10 s wall clock from cold launch to Map first frame | `integration_test` with `Stopwatch` on Pixel 7 emulator |
| Splash + Onboard transitions | ≥ 60 fps | Flutter DevTools timeline / `WidgetsFlutterBinding.instance.addTimingsCallback` in tests |
| Cold-launch native splash → in-app splash handoff | No visible flicker | Visual inspection + integration test asserting no intermediate Material default theme frame |

### Accessibility
| Requirement | Target | Measurement |
|---|---|---|
| WCAG 2.1 AA contrast | 4.5:1 body, 3:1 large/UI | Manual audit using design-system tokens (verified once per screen) |
| Hit target size | ≥ 44 sp on all CTAs and language pills | Widget test asserting `Size.height >= 44 && Size.width >= 44` |
| Reduce Motion respect | In-app splash bypassed when system flag is on | Integration test with `MediaQueryData(disableAnimations: true)` injected |
| Screen-reader compatibility | TalkBack/VoiceOver names every interactive element | Widget test asserting `Semantics.label` present on language pills, CTAs, skip link |
| RTL parity | All paddings/icons mirror correctly in Arabic | Widget test running each screen under `Locale('ar')` and asserting `Directionality.of(context) == TextDirection.rtl` |

### Localisation
| Requirement | Target | Measurement |
|---|---|---|
| Locale coverage | All onboarding screens render in pl, en, ar | Widget test parameterised on each locale (3 × 5 screens = 15 widget tests) |
| Polish-first canonical strings | Specific terms match `constitution-frontend.md` §V.2 verbatim | Spec-level review — no test |

### Reliability
| Requirement | Target | Measurement |
|---|---|---|
| Persistence survives app kill | After kill-and-restart, onboarding-completed flag and selected locale are preserved | `integration_test` with `tester.binding.reassembleApplication()` |
| Persistence survives reinstall (iOS Keychain) | Onboarding flag preserved across reinstall when `KeychainAccessibility.first_unlock` is in effect | Manual smoke test on physical device (cannot be automated easily on emulator) |

---

## Acceptance Criteria

### BRD Traceability

This feature has no BRD; the spec at [`spec.md`](./spec.md) is the source of truth. Functional Requirements FR-001 through FR-020 and Non-Functional Requirements NFR-001 through NFR-004 are the canonical references. Design references: [`specs/design/design_handoff_halal_map_polskie/`](../design/design_handoff_halal_map_polskie/) — specifically Splash A/B and Welcome A/B variants in `Auth & Onboarding.html`.

### Splash

- [FR-001] System displays a Splash screen on every cold launch, auto-advancing without user input
- [FR-001] First-time users: full ~2.2 s animation; returning users: truncated ~1 s animation
- [FR-020] When OS "Reduce Motion" / "Disable Animations" is enabled, the in-app splash animation is skipped entirely
- [NFR-004] Animation maintains ≥ 60 fps on Pixel 7 emulator
- [UC-001-IMPL-01] Native `flutter_native_splash` background colour matches in-app splash background — no visible flash on handoff

### Onboarding Intro (Onboard 1 · Find, Onboard 2 · Trust, Onboard 3 · Community)

- [FR-003] Three intro pages display in order with distinct content (discovery / verification / community)
- [FR-007] "Pomiń" link on Onboard 1 and Onboard 2 jumps to Onboard 3, preserving language selection
- [FR-015] Page indicator (three dots) on every intro page reflects current position
- [FR-016] Back gesture navigates to previous page (Onboard 2/3); exits app from Onboard 1
- [UC-001-IMPL-02] `PageView` with explicit `PageController` drives both swipe and skip-link advancement; controller listens to indicator widget
- [DS-002] Headings use Lora display 500 with negative letter-spacing per design system §II.5

### Language Picker

- [FR-004] Three pill buttons (PL / EN / ع) visible in top-right corner of every onboarding screen
- [FR-005] Initial selection defaults to system locale (`PlatformDispatcher.locale`), falling back to Polish for locales not in {pl, en, ar}
- [FR-006] Selecting "ع" mirrors the screen to RTL and renders Arabic text in Amiri font
- [FR-017] Selection persists across pages and into the main app (stored to `selected_locale` key)
- [UC-001-IMPL-03] Picker uses `LocaleNotifier` Riverpod provider; selecting a pill calls `notifier.setLocale(AppLocale.X)` which triggers both UI rebuild and async secure-storage write
- [DS-003] Pills use 28 sp width × 22 sp height; active pill uses `sand-400` background + `cocoa-900` text per design

### Onboard 3 — Final CTAs

- [FR-008] Two CTAs on Onboard 3: primary "Kontynuuj" and secondary "Przeglądaj jako gość"
- [FR-009] "Kontynuuj" routes to LocationPermission (if not previously decided) or directly to Map (if decided)
- [FR-009] "Przeglądaj jako gość" routes directly to Map, bypassing LocationPermission
- [FR-012] Onboarding-completed flag set when user reaches Map by any path

### LocationPermission

- [FR-010] Pre-prompt shown only if location not previously decided at OS level
- [FR-011] Two actions: "Pozwól" triggers OS prompt; "Nie teraz" proceeds without location
- [FR-014] On denial (OS-level or "Nie teraz"), Map opens to a wide Poland view with five target cities marked (Warsaw, Kraków, Wrocław, Gdańsk, Poznań)

### Privacy & Offline

- [FR-013] No sign-in / account creation / identifying input requested anywhere in the flow
- [FR-018] Zero network calls during Splash, Onboard 1/2/3, LocationPermission (verified by integration test with no-network connectivity-monitor)
- [FR-019] Zero analytics events fire (verified by absence of any analytics SDK initialisation in the feature module)

### Persistence

- [FR-002] On cold launch: first-time users (no `onboarding_completed_at` key) → Onboard 1; returning users (key present) → Map (after splash)
- [UC-001-IMPL-04] Both keys (`onboarding_completed_at`, `selected_locale`) read synchronously from secure_storage in `main.dart` before `runApp`, used to set initial routing + locale
- [UC-001-IMPL-05] Subsequent locale changes after onboarding (via Settings screen, future) write the same key

### Edge Cases

- [UC-001-IMPL-06] Backgrounding during onboarding preserves current page + locale selection on resume
- [UC-001-IMPL-07] App-kill during onboarding causes flow to restart from Splash on next launch (flag still not set)
- [UC-001-IMPL-08] Device-rotation preserves selection state
- [UC-001-IMPL-09] Locales outside {pl, en, ar} fall back to Polish per FR-005

### Testing

- [NFR-002] Each onboarding screen has at least one widget test per locale (pl, en, ar) = 15 widget tests
- [NFR-002] Integration test exercises three paths: first-time happy path, returning-user fast path, Reduce Motion bypass
- [Universal §4] All three mandatory test types (unit, widget, integration) covered

---

*Based on Constitution — see `.ai_project_memory/constitution.md` and `.ai_project_memory/constitution-frontend.md`*
