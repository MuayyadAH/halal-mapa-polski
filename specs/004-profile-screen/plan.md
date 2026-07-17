# Implementation Plan: Profile Tab — Guest (v1)

**Branch**: `004-profile-screen` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

## Summary

Build the launch (v1) **Profil** tab as a guest experience — three screens rendered inside the existing `/profile` branch of the 5-tab `StatefulShellRoute` (no own dock — FR-001). **Screen 1** (`ProfileScreen`, replacing today's stub body) is one scrollable column over the warm gradient: a cocoa→umber **coming-soon banner** (glowing clock ring, floating "● Wkrótce" badge, Lora headline with an italic accent word, "Powiadom mnie" button) paired on the **same page** with minimal settings — a **Preferencje** group (Language row only — **no Dark-mode row**), a **Społeczność** group (Suggest-a-place, external), and an **Informacje** group (About + Privacy) — closed by a two-line footer. **Screen 2** (`LanguageScreen`, pushed at `/profile/language`) is a radio list of exactly **pl/en/ar** (Arabic in Amiri) bound to the shared `localeNotifierProvider`, so selecting a language switches the whole app **live, no restart** (RTL flips for Arabic) and the user stays on the re-rendered screen. **Screen 3** (`AboutScreen`, pushed at `/profile/about`) carries an app-mark card (glowing pin, mission), a Suggest-a-place CTA card, and a **Linki** group (Website / Privacy / Terms / Open-source licenses).

The feature is **presentational and additive over existing infrastructure — zero new dependencies** (R10). It reuses the 001 locale controller (FC-2), the shared `FadeRiseIn`/`EntranceController`/`PressableScale` motion primitives, `url_launcher`, theme tokens, and the 5-tab shell. New code is: three screens, three **shared design-system widgets** (`BackHeader`, `SettingRow`, `GroupCard` in `lib/shared/widgets/`), a small shared **`ExternalLinkLauncher`** (`lib/core/links/`, mirroring `MapsLauncher`) opening placeholder `Env` URLs, and ~Profile ARB keys. The orphaned `/profile/settings` route and `SettingsScreen` stub are **removed** (Clarify 2026-05-31). Open-source licenses uses Flutter's native `showLicensePage`; no GitHub link (repo private — Clarify Q1).

---

## Implementation Conflicts

**Status**: No Conflicts Found (additive; one intentional removal)

- `lib/features/profile/profile_screen.dart` is a placeholder (`AppBar` + "coming soon") → **replaced** by Screen 1 (custom `BackHeader` + scroll column; no `AppBar`, no own dock).
- `lib/features/settings/settings_screen.dart` + the `/profile/settings` `GoRoute` are **removed** (orphaned under the guest design; Clarify 2026-05-31). `app_router.dart` Profile branch gains nested `/profile/language` and `/profile/about` routes. Verify `flutter analyze` clean (no dangling imports).
- `lib/app.dart` **unchanged** — it already reacts to `localeNotifierProvider` (live locale switch); the Language screen just writes the existing notifier.
- `lib/core/env/env.dart` **modified** — adds 4 placeholder link URLs (`String.fromEnvironment`, `--dart-define`-overridable).
- `lib/l10n/app_*.arb` **modified** — adds ~Profile keys/locale (additive; PL canonical verbatim, EN from tables, AR placeholder); run `flutter gen-l10n`.
- New shared widgets in `lib/shared/widgets/` (`back_header.dart`, `setting_row.dart`, `group_card.dart`) — additive; reusable by the future Settings screen.
- `pubspec.yaml` **unchanged** (R10). No platform-manifest changes (no permissions; `url_launcher` already configured by 002).
- No conflict with 001/002/003 — disjoint feature module; reuses shared locale controller, motion primitives, tokens, `url_launcher`, and the shell.

**Conflict Check Date**: 2026-05-31 · **Checked Against**: `specs/001-onboarding-flow/plan.md`, `specs/002-home-screen/plan.md`, `specs/003-map-screen/plan.md`.

---

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter stable (per `pubspec.yaml`)
**Primary Dependencies** (all existing — no additions):
- `flutter_riverpod` 3.3.1 — reads/writes `localeNotifierProvider`; `externalLinkLauncherProvider`; test overrides
- `go_router` 17.2.3 — existing `/profile` branch; adds nested `/profile/language` + `/profile/about`; removes `/profile/settings`
- `url_launcher` 6.3.1 (existing) — external destinations via the new shared `ExternalLinkLauncher`
- `flutter_localizations` + `intl` 0.20.2 — ARB localization (pl/en/ar) incl. RTL
- Flutter `material` — `showLicensePage` (Open-source licenses), platform page transitions
- Shared `lib/shared/widgets/` — `FadeRiseIn` + `EntranceController` (staggered entrance), `PressableScale` (press); fonts Lora / Plus Jakarta Sans / Amiri already bundled

**Storage**: none new. App locale persists via the existing secure-storage key `selected_locale` (001). Profile screens persist nothing.
**Data source**: none — the screens fetch nothing on load. The only network actions are user-initiated external-link hand-offs (placeholder `Env` URLs). **No analytics/tracking** (§1.7).
**Testing**:
- Unit: `ExternalLinkLauncher` (success→true, error→false); `AppLocale` native/English-name mapping; "language list = exactly pl/en/ar" invariant; `Env` link resolution.
- Widget: 3 screens + 3 shared widgets, each × {pl, en, ar incl. RTL} × {motion on/off}; `FakeExternalLinkLauncher` asserts URLs + failure SnackBar; assert `showLicensePage` reached; assert no Dark-mode row and no Language helper.
- Integration (`integration_test/profile_flow_test.dart`): open Profil → Language → pick Arabic (assert app-wide RTL + Screen 1 value, no restart) → About → tap link (fake) → licenses → back.

**Target Platform**: iOS 13+ / Android API 23+ (Pixel 7 / API 34 reference).
**Project Type**: mobile (Flutter; no backend in repo).
**Performance Goals**: entrance/ambient/press ≥ 60 fps (NFR-001); Screen 1 first frame ≤ ~1 s (NFR-004); ambient loops low-CPU.
**Constraints**: guest-only (no login/account UI beyond the banner — FR-003); pl/en/ar only, no TR/UK (FC-4); placeholder URLs from a single config point (FR-016); no GitHub link / repo private (Clarify Q1); WCAG 2.1 AA incl. RTL (NFR-002/003); Polish canonical ARB + tokens only (§1.5/§X); zero new dependencies (R10).
**Scale/Scope**: 3 screens + 3 shared widgets + ~6–9 leaf widgets (banner, badge, clock-ring, app-mark card, suggest card, language row, footer) + 1 core abstraction (`ExternalLinkLauncher`) + small `Env`/`AppLocale` helpers; 3 locales (~30 keys each).

## Constitution Check

**Applicable**: frontend + universal. **Sources**: `constitution.md` §1.1–1.7/§2/§4; `constitution-frontend.md` §I–§XIII.

### Compliance Checklist
- [x] **§1.1**: Feature-first — screens under `lib/features/profile/`; cross-feature primitives (`ExternalLinkLauncher`) under `lib/core/links/`; design-system widgets under `lib/shared/widgets/`
- [x] **§1.2**: Naming conventions (snake_case files, PascalCase types)
- [x] **§1.3**: Error handling — external launch failure → localized SnackBar, never a crash/dead-end; no other failure surfaces (nothing fetched)
- [x] **§1.5 / FR-019**: Localization & RTL — ARB only (PL canonical verbatim); `EdgeInsetsDirectional`; ar RTL + Amiri tested
- [x] **§1.6 / FR-003**: Guest-first; honest coming-soon banner (no fake login); no verification/account surfaces invented
- [x] **§1.7 / FR-021**: No analytics/trackers; no PII collected/transmitted; only user-initiated link hand-offs
- [x] **§2**: Placeholder link URLs via `Env`/`--dart-define` (not secrets, not committed-as-real); no keys in code
- [x] **§4 / §XII**: Unit + widget + integration tests; launcher/locale abstractions make UI testable headless
- [x] **Frontend §I.1**: Stack — reuses existing deps; **no new dependency** (R10); `url_launcher` purpose extended (recorded in §I.1)
- [x] **§II / §X / §XIII**: Tokens from `tokens.dart` only; no magic literals; no hardcoded strings; no `EdgeInsets.only(left/right)`; icon-set glyphs (no hand-rolled SVG)
- [x] **§III**: Adds reusable `BackHeader`/`SettingRow`/`GroupCard` to the shared widget library
- [x] **§IV.8 / §IV.9**: Implements the guest Profile (ProfileGuest) + Language + About; the account-centric Profile/Contributions and the full Settings screen are deferred (recorded in §4.8)
- [x] **§V**: pl/en/ar; Polish canonical & verbatim
- [x] **§VI / FR-018**: Staggered entrance, ambient glow/float/shimmer, press-scale per ANIMATIONS.md; reduced motion disables all
- [x] **§IX**: Riverpod only (reuses `localeNotifierProvider`; adds `externalLinkLauncherProvider`)
- [x] **§XI / FR-020**: a11y — labels on every control (external rows announced as external), ≥ 44 dp, font-scale, RTL; warm-palette contrast checked

**Violations**: none requiring justification. Two intentional, documented scope choices (no functionality disabled): (1) account-centric Profile/Contributions, the full Settings screen, the Dark-mode row, and a GitHub link are **deferred** (no accounts / no theme-mode controller / repo private — spec §5); (2) external URLs are placeholders pending real content. Both are honest deferrals, not broken/disabled features. See Complexity Tracking.

---

## Project Structure

### Documentation (this feature)
```
specs/004-profile-screen/
├── spec.md · plan.md · research.md · data-model.md · quickstart.md
├── contracts/
│   ├── external_link_launcher.md   # URL launcher + native licenses + AppInfo version
│   └── profile_components.md        # BackHeader / SettingRow / GroupCard widget contracts
├── checklists/requirements.md
└── tasks.md                         # Phase 2 — NOT created by /plan
```

### Source Code (repository root)
```
lib/
├── core/
│   ├── links/
│   │   └── external_link_launcher.dart   # NEW — ExternalLinkLauncher + Url impl + provider + AppInfo (R3/R4/R5)
│   ├── env/env.dart                       # MODIFIED — add SUGGEST_FORM_URL/WEBSITE_URL/PRIVACY_URL/TERMS_URL (R5)
│   ├── routing/app_router.dart            # MODIFIED — add /profile/language + /profile/about; REMOVE /profile/settings (R1)
│   └── theme/tokens.dart                  # reused (no change expected; verify banner gradient/sand tokens exist)
├── features/
│   ├── profile/
│   │   ├── profile_screen.dart            # REPLACES stub — Screen 1 (banner + settings groups + footer)
│   │   └── presentation/
│   │       ├── language_screen.dart       # NEW — Screen 2 (pl/en/ar radios → localeNotifier)
│   │       ├── about_screen.dart          # NEW — Screen 3 (app-mark + suggest card + links)
│   │       └── widgets/
│   │           ├── coming_soon_banner.dart   # NEW — gradient card, clock-ring glow, floating badge, notify button
│   │           ├── app_mark_card.dart        # NEW — gradient pin glyph (glow) + name + version + mission
│   │           ├── suggest_place_card.dart   # NEW — About CTA card (external form)
│   │           └── profile_footer.dart       # NEW — centered two-line footer
│   └── settings/settings_screen.dart      # REMOVED (orphaned stub — R1)
├── features/auth/.../locale_notifier.dart # reused (single locale source — FC-2)
├── shared/widgets/
│   ├── back_header.dart                   # NEW — shared (R6)
│   ├── setting_row.dart                   # NEW — shared (chevron/external/radio/accent variants) (R6)
│   ├── group_card.dart                    # NEW — shared (R6)
│   ├── fade_rise_in.dart · pressable_scale.dart  # reused (entrance + press)
└── l10n/app_{pl,en,ar}.arb                # MODIFIED — ~Profile keys (R8)

test/
├── core/links/external_link_launcher_test.dart
├── shared/widgets/{back_header,setting_row,group_card}_test.dart
└── features/profile/{profile_screen,language_screen,about_screen}_test.dart   # ×locales, motion on/off, FakeExternalLinkLauncher
integration_test/profile_flow_test.dart
```

**Structure Decision**: Screens stay **presentation-only** under `lib/features/profile/`. The locale controller is **reused** (not copied — FC-2). The three settings components are **promoted to `lib/shared/widgets/`** (design-system primitives the future Settings screen will reuse), and the URL launcher is a **shared core** abstraction (`lib/core/links/`) mirroring `MapsLauncher` — both decisions follow the 002/003 precedent of putting reusable plumbing in `core`/`shared` rather than in a feature.

## Phase 0: Outline & Research
See [`research.md`](./research.md): R1 (routing: replace Profile body, add Language/About, remove settings stub), R2 (Language picker binds to existing `localeNotifierProvider`; live, no restart), R3 (`ExternalLinkLauncher` abstraction + graceful failure), R4 (native `showLicensePage`), R5 (placeholder URLs + version in `Env`/const), R6 (shared `BackHeader`/`SettingRow`/`GroupCard`), R7 (reuse entrance/press primitives + gated ambient loops), R8 (ARB keys, PL canonical), R9 (testing strategy), R10 (**no new dependencies**). **No NEEDS CLARIFICATION remain.**

## Phase 1: Design & Contracts
- **Data model** — [`data-model.md`](./data-model.md): reused `AppLocale`/`localeNotifierProvider` (only persisted state); transient `LanguageOption` view model (invariant: exactly pl/en/ar, one selected); build-time `ExternalDestinations` (`Env`, placeholder, `--dart-define`); no new persisted entities; no load-time data/`AsyncValue`.
- **Contracts** — [`external_link_launcher.md`](./contracts/external_link_launcher.md) (URL launcher + Fake + native licenses + `AppInfo.version`); [`profile_components.md`](./contracts/profile_components.md) (BackHeader/SettingRow/GroupCard widget APIs + test surface).
- **Stack constitution update** — `constitution-frontend.md` §I.1 `url_launcher` row extended (Profile external links + `ExternalLinkLauncher` + native licenses); §4.8 adds the shipped **ProfileGuest** entry. No new tech row (R10).
- **Post-design re-check**: passes; the documented deferrals (account screens, full Settings, Dark-mode, GitHub link, real URLs) stand — none are disabled features.

## Phase 2: Task Planning Approach
*Describes what `/ai1st-dev-tasks` will do — not executed here.*

**Ordering** (dependency-respecting):
1. `Env`: add 4 placeholder link URLs. ARB: add Profile keys (pl/en/ar) + `flutter gen-l10n`. `AppLocale` native/English-name helpers.
2. Core: `ExternalLinkLauncher` (+ `UrlExternalLinkLauncher`, provider, `AppInfo`) + `FakeExternalLinkLauncher`; unit tests.
3. Shared widgets: `back_header.dart`, `setting_row.dart` (chevron/external/radio/accent), `group_card.dart`; widget tests (×locales, RTL, reduced motion).
4. Profile leaf widgets: `coming_soon_banner` (clock-ring glow + floating badge + notify button), `app_mark_card` (glow), `suggest_place_card`, `profile_footer`.
5. Screens: `profile_screen` (Screen 1 assembly: banner + 3 groups + footer, staggered entrance), `language_screen` (Screen 2: radios → `setLocale`, stay-on-screen), `about_screen` (Screen 3: app-mark + suggest + links + licenses).
6. Routing: add `/profile/language` + `/profile/about`; **remove** `/profile/settings` + delete `settings_screen.dart`; verify `flutter analyze` clean.
7. Tests: widget (3 screens × {pl,en,ar} × motion on/off; FakeExternalLinkLauncher; no Dark-mode row; no Language helper; licenses page) → integration (`profile_flow_test.dart`).

Mark `[P]` for independent files (shared widgets, leaf widgets, unit tests). **Estimated**: ~28–34 tasks. Include a task to confirm no regression from removing the settings stub.

---

## Dependencies Analysis

### Prerequisites
| Dependency | Source | Status | Notes |
|------------|--------|--------|-------|
| 5-tab shell + `/profile` branch | scaffold/001 | Required | Screens render inside; nested routes added |
| `localeNotifierProvider` / `AppLocale` | 001 | Required | Single locale source; live switch (FC-2/FR-010) |
| `FadeRiseIn` / `EntranceController` / `PressableScale` | 001/002 (`lib/shared/widgets/`) | Required | Entrance + press motion (FR-018) |
| `url_launcher` | 002 (pubspec) | Required | External links via new `ExternalLinkLauncher` |
| `tokens.dart` (HmpColors/Spacing/Radii/Fonts) | scaffold | Required | All styling (§X) |
| Fonts (Lora / Plus Jakarta / Amiri) | scaffold (pubspec) | Required | Headings + Arabic native name |
| `Env` config point | scaffold | Required | Placeholder link URLs (R5) |

### Provides (to other features)
| Output | Used By | Description |
|--------|---------|-------------|
| `BackHeader` / `SettingRow` / `GroupCard` | full Settings screen (§4.9), any settings-like surface | Shared design-system list primitives |
| `ExternalLinkLauncher` (+ provider, Fake) | About/Contact, donations (post-MVP), any URL hand-off | One testable URL launcher across the app |
| Guest Profile shell | post-login Profile feature | Banner is swapped for the account experience when sign-in ships |

---

## Work Streams
- [x] **[UI]** — 3 screens + shared/leaf widgets + `ExternalLinkLauncher` + ARB (single Flutter stream)
- [x] **[TEST]** — unit + widget (FakeExternalLinkLauncher, ×locales, motion) + integration (rolls up with [UI])
- [ ] [API]/[DB]/[INFRA]/[INT] — N/A (no backend, no storage changes, no new deps/platform config, no cross-stream coordination)

---

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Guest Profile defers account-centric Profile/Contributions + full Settings (diverges from §4.8/§4.9) | No accounts / no theme-mode controller at launch | Faking a login or an inert settings screen would mislead users; the honest coming-soon banner + minimal usable settings is the constitution-aligned choice (§1.6); deferred items return with auth/theme features |
| Placeholder external URLs (suggest/website/privacy/terms) | Real content/legal pages don't exist yet | Hiding the rows would diverge from the design; placeholders in `Env` are replaceable via `--dart-define` with no screen change (FR-016) |
| Three components promoted to `lib/shared/widgets/` | The future Settings screen reuses them; avoids feature→feature import (§1.1) | Implementing under `features/profile/` then re-promoting later causes churn |

---

## Use Case Specific NFRs

### Performance
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Entrance + ambient (glow/float/shimmer) + press | ≥ 60 fps; ambient low-CPU | DevTools timeline, Pixel 7 (NFR-001) |
| Screen 1 first frame | ≤ ~1 s after tab select | Manual / integration (NFR-004) |

### Accessibility / Localization
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| Targets / labels | ≥ 44 dp; every control labeled; external rows announced as external | Widget tests (FR-020) |
| Locale + RTL | pl/en/ar incl. RTL + Amiri | Widget tests per locale (NFR-002) |
| Contrast | WCAG AA on warm cream/cocoa/umber palette | Manual/contrast check (NFR-003) |

### Privacy
| Requirement | Target | Measurement |
|-------------|--------|-------------|
| No analytics/PII | zero trackers; no PII on these screens | Code review + test (no analytics calls) (FR-021) |

---

## Acceptance Criteria

### BRD Traceability
No BRD; [`spec.md`](./spec.md) is canonical (FR-001…FR-021, NFR-001…004, TC-1…TC-21). Design: `specs/design/profile/` (README, PROMPT, ANIMATIONS). No data source (presentational).

### Shell & Screen 1 (coming-soon + settings)
- [FR-001] Renders inside the 5-tab shell; no own dock (TC-1)
- [FR-002] Coming-soon banner: clock-ring, "● Wkrótce" badge, italic-accent headline, subline, notify button; on the same page as settings (TC-2)
- [FR-003] No login/account/avatar/stats/contributions UI; banner is the only account reference (TC-3)
- [FR-004][FR-005] Groups: Preferencje (Language row only — **no Dark-mode row**), Społeczność (Suggest), Informacje (About + Privacy) (TC-4)
- [FR-006] Language row value = active language; updates after a Screen 2 change (TC-5)
- [FR-007] Centered two-line footer (TC-6)

### Screen 2 (Language)
- [FR-008] Push with kicker Ustawienia / title Język; back pops (TC-7)
- [FR-009][FC-4] Exactly pl/en/ar radios (Arabic in Amiri); no TR/UK (TC-8)
- [FR-010] Single-select; live app-wide locale switch, **no restart**, stay on screen; Screen 1 value reflects it (TC-9)
- [FR-011] No "missing language" helper / external link (TC-10)

### Screen 3 (About)
- [FR-012] Push with kicker Informacje / title O aplikacji; back pops (TC-11)
- [FR-013] App-mark card + Suggest CTA card + LINKS group + two-line footer (TC-12)

### External destinations
- [FR-014][FR-016] Banner button / Suggest / Website / Privacy / Terms open placeholder `Env` URLs via `ExternalLinkLauncher`; failure → localized SnackBar, no crash (TC-13, TC-15)
- [FR-015] Open-source licenses → native `showLicensePage` (TC-14)

### Components, motion, i18n, a11y, privacy
- [FR-017] Shared BackHeader/SettingRow/GroupCard implemented once, reused across screens, tokens only (TC-16)
- [FR-018][DS-ANIMATIONS] Staggered entrance + ambient glow/float/shimmer + press; reduced motion disables all (TC-17, TC-18)
- [FR-019][NFR-002] ARB pl/en/ar incl. RTL; Polish canonical; no hardcoded strings (TC-19)
- [FR-020][NFR-003] Labels on all controls (external announced), ≥ 44 dp, font-scale, RTL, contrast (TC-20)
- [FR-021] No analytics/tracking; no PII (TC-21)
- [NFR-001/004] ≥ 60 fps; Screen 1 first frame ≤ ~1 s

### Testing
- [Universal §4/§XII] Unit + widget (FakeExternalLinkLauncher, ×locales, motion on/off) + integration present; each TC-1…TC-21 covered by ≥ 1 test

---

*Based on Constitution — see `.ai_project_memory/constitution.md` and `.ai_project_memory/constitution-frontend.md`*
