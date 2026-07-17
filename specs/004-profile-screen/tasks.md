# Tasks: Profile Tab — Guest (v1)

**Feature**: `004-profile-screen` · **Input**: design docs in `specs/004-profile-screen/` (plan.md, spec.md, research.md, data-model.md, contracts/)
**Tech**: Flutter / Dart, Riverpod, go_router, `intl`, `url_launcher` (via a new shared `ExternalLinkLauncher`), Flutter `material` `showLicensePage`. Reuses the 001 locale controller (`localeNotifierProvider`), the shared `FadeRiseIn`/`EntranceController`/`PressableScale` motion primitives, and `tokens.dart`. **No new dependencies** (research R10).

Tests are included (Constitution §4 + spec §6 require unit + widget + integration). Screens fetch nothing on load; the only failure surface is a SnackBar when an external launch fails. Format: `- [ ] [TaskID] [P?] [Story?] Description + file path`. `[P]` = parallelizable (different file, no incomplete deps).

---

## User Stories (priority order, from spec.md)

- **US1 (P1, MVP)** — Screen 1: Coming-soon + settings landing. Banner (clock-ring, "● Wkrótce" badge, italic-accent headline, Notify button) + Preferencje (Language row only — **no Dark-mode row**) + Społeczność (Suggest) + Informacje (About + Privacy) + footer, inside the 5-tab shell, replacing the stub. (FR-001/002/003/004/005/006/007, TC-1/2/3/4/5/6)
- **US2 (P2)** — Language screen: pl/en/ar radios bound to the shared locale controller; live, app-wide switch with **no restart**, stay on screen; no "missing language" helper. (FR-008/009/010/011, TC-7/8/9/10)
- **US3 (P3)** — About screen: app-mark card, Suggest-a-place CTA card, LINKS group (Website/Privacy/Terms → external; Open-source licenses → native page), footer. (FR-012/013/014/015, TC-11/12/13/14)
- **US4 (P4)** — Motion: staggered entrance, ambient glow/badge-float/shimmer, row/card press; reduced motion disables all. (FR-018, TC-17/18)

External-link launching (FR-014/016), the shared components (FR-017), localization (FR-019), accessibility (FR-020), and privacy (FR-021) are cross-cutting — built in Foundational and verified in the Final phase.

---

## Phase 1: Setup

- [x] T001 Confirm **no new dependencies** are required: verify `pubspec.yaml` already provides `url_launcher`, `flutter_riverpod`, `go_router`, `intl`, `flutter_localizations` (repo root); do **not** add packages (research R10)
- [x] T002 Verify implementation conflicts per plan.md: confirm `lib/features/profile/profile_screen.dart` (stub) is to be replaced, `lib/features/settings/settings_screen.dart` + the `/profile/settings` route are to be **removed**, and `lib/app.dart` stays unchanged (already reacts to `localeNotifierProvider`)

## Phase 2: Foundational (blocking prerequisites — config, l10n, launcher, shared components, cleanup)

- [x] T003 [P] Add placeholder external-link URLs (`SUGGEST_FORM_URL`, `WEBSITE_URL`, `PRIVACY_URL`, `TERMS_URL` via `String.fromEnvironment` with placeholder defaults) and `appVersion = '1.0.0'` to `lib/core/env/env.dart` (research R5, data-model `ExternalDestinations`)
- [x] T004 [P] Add Profile ARB keys to `lib/l10n/app_pl.arb` (canonical, **verbatim** from the design README string tables: `profileTitle`, `comingSoonBadge`, `comingSoonHeadline`+accent, `comingSoonSub`, `notifyButton`, `groupPreferences`, `groupCommunity`, `groupInfo`, `groupLinks`, `rowLanguage`, `rowSuggestPlace`+sub, `rowAbout`, `rowPrivacy`, `rowWebsite`, `rowTerms`, `rowLicenses`, `languageKicker`, `languageTitle`, `chooseLanguage`, `aboutKicker`, `aboutTitle`, `appMission`, `versionLine`, `footerMission`, `footerCopyright`, `linkOpenFailed`), then `lib/l10n/app_en.arb` (English from tables) and `lib/l10n/app_ar.arb` (placeholder), and run `flutter gen-l10n`
- [x] T005 [P] Add `AppLocale.nativeName` (`Polski`/`English`/`العربية`) and `AppLocale.englishName` (`Polish`/`English`/`Arabic`) helpers to `lib/features/auth/domain/onboarding_state.dart` (data-model — used by the Language list)
- [x] T006 Verify the tokens needed by the Profile design exist in `lib/core/theme/tokens.dart` (cocoa→umber banner gradient, sand glow, parchment card fill + hairline, `verify`-green radio, accent umber tile) and add any missing as named tokens (Constitution §X — no magic literals)
- [x] T007 Create `ExternalLinkLauncher` interface + `UrlExternalLinkLauncher` (graceful `false` on failure) + `externalLinkLauncherProvider` + `AppInfo.version` in `lib/core/links/external_link_launcher.dart` per `contracts/external_link_launcher.md` (dep: T003)
- [x] T008 [P] Create `FakeExternalLinkLauncher` (records `open(uri)` calls, programmable return) in `test/support/fake_external_link_launcher.dart`
- [x] T009 [P] Unit test `ExternalLinkLauncher`: success → `true`; thrown error → `false` (no rethrow); same `Env.suggestFormUrl` resolves for notify + suggest in `test/core/links/external_link_launcher_test.dart` (dep: T007)
- [x] T010 [P] Create shared `BackHeader` (back-chevron tile + optional kicker + title; `Directionality`-aware chevron; `showBack` toggle; pops route) in `lib/shared/widgets/back_header.dart` per `contracts/profile_components.md` (dep: T006)
- [x] T011 [P] Create shared `SettingRow` (icon tile + label + optional sub + optional trailing value; `chevron`/`external`/`radio`/`none` trailing; `accent` + `selected` flags; wrapped in `PressableScale`; external rows announce "opens externally") in `lib/shared/widgets/setting_row.dart` per `contracts/profile_components.md` (dep: T006)
- [x] T012 [P] Create shared `GroupCard` (translucent parchment card, radius 18, hairline border, soft shadow; optional uppercase section label; 1px dividers between rows, none after last) in `lib/shared/widgets/group_card.dart` per `contracts/profile_components.md` (dep: T006)
- [x] T013 [P] Widget test `BackHeader`: title/kicker render; back chevron only when `showBack`; tap pops (test router); chevron mirrors in RTL in `test/shared/widgets/back_header_test.dart` (dep: T010)
- [x] T014 [P] Widget test `SettingRow`: each trailing variant renders correct affordance; `external` exposes "opens externally" semantics; `radio` reflects `selected`; tap fires `onTap`; ≥44 dp; accent tint; pl/en/ar + RTL in `test/shared/widgets/setting_row_test.dart` (dep: T011)
- [x] T015 [P] Widget test `GroupCard`: N rows → N−1 dividers; section label rendered when provided in `test/shared/widgets/group_card_test.dart` (dep: T012)
- [x] T016 Remove the orphaned `/profile/settings` `GoRoute` from `lib/core/routing/app_router.dart` and delete `lib/features/settings/settings_screen.dart`; run `flutter analyze` and confirm clean (no dangling import/dead code) — Clarify 2026-05-31

---

## Phase 3: US1 — Screen 1 Coming-soon + settings (P1, MVP)

**Goal**: Open Profil → one scrollable page inside the 5-tab shell: coming-soon banner + Preferencje (Language only) + Społeczność (Suggest) + Informacje (About + Privacy) + footer. **Independent test**: with `FakeExternalLinkLauncher` + a `localeNotifierProvider` override, the three groups render (no Dark-mode row), the banner shows its content, Notify/Suggest/Privacy call the launcher with the right `Env` URLs, and the footer renders — across pl/en/ar + RTL.

- [x] T017 [P] [US1] Create `ComingSoonBanner` (cocoa→umber gradient card, clock-ring, "● Wkrótce" badge, Lora headline with italic-accent last word via `TextSpan`, subline, "Powiadom mnie" `PrimaryButton` → `externalLinkLauncherProvider.open(Env.suggestFormUrl)` with failure SnackBar) — static (motion in US4) — in `lib/features/profile/presentation/widgets/coming_soon_banner.dart` (deps: T004, T006, T007)
- [x] T018 [P] [US1] Create `ProfileFooter` (centered two-line app+version / mission, localized) in `lib/features/profile/presentation/widgets/profile_footer.dart` (deps: T004, T003)
- [x] T019 [US1] Replace the stub `ProfileScreen`: `lib/features/profile/profile_screen.dart` = scroll column of `BackHeader(title: profileTitle, showBack: false)` + `ComingSoonBanner` + `GroupCard`(Preferencje → Language `SettingRow` value=active language, chevron → `context.go('/profile/language')`) + `GroupCard`(Społeczność → Suggest `SettingRow` accent+external → launcher) + `GroupCard`(Informacje → About `SettingRow` value=`v ${AppInfo.version}`, chevron → `/profile/about`; Privacy `SettingRow` external → launcher) + `ProfileFooter`; **no Dark-mode row** (deps: T010, T011, T012, T017, T018)
- [x] T020 [P] [US1] Widget test `ProfileScreen`: renders inside a tab shell with no own dock; three groups present; Preferencje has exactly the Language row and **no Dark-mode row**; Language row value = active locale; footer present in `test/features/profile/profile_screen_test.dart` (dep: T019)
- [x] T021 [P] [US1] Widget test: tapping Notify, Suggest, and Privacy calls `FakeExternalLinkLauncher.open` with `Env.suggestFormUrl` / `Env.suggestFormUrl` / `Env.privacyUrl`; a `false` return shows the localized SnackBar; pl/en/ar + RTL in `test/features/profile/profile_screen_links_test.dart` (deps: T019, T008)
- [x] T022 [US1] Integration test scaffold: launch → select the Profil tab → Screen 1 renders inside the 5-tab shell in `integration_test/profile_flow_test.dart`

---

## Phase 4: US2 — Language screen (P2)

**Goal**: Tap Language → a screen listing exactly pl/en/ar radios; selecting one switches the whole app live (no restart, RTL for Arabic) and stays on the re-rendered screen; no helper line. **Independent test**: with a `localeNotifierProvider` override, exactly three radios render (one selected); tapping another calls `setLocale`, moves the radio, and re-renders; no "missing language" text; RTL for ar.

- [x] T023 [US2] Create `LanguageScreen`: `BackHeader(kicker: languageKicker, title: languageTitle)` + section label + a `GroupCard` of three `SettingRow`(trailing: radio) rows built from `[pl, en, ar]` (native name; Arabic in `HmpFonts.arabic`; English name as trailing value; `selected = locale == active`; tap → `ref.read(localeNotifierProvider.notifier).setLocale(...)`); **no** helper line in `lib/features/profile/presentation/language_screen.dart` (deps: T005, T011, locale controller)
- [x] T024 [US2] Add the nested `/profile/language` `GoRoute` → `LanguageScreen` under the Profile branch in `lib/core/routing/app_router.dart` (deps: T023, T016)
- [x] T025 [P] [US2] Widget test `LanguageScreen`: exactly three rows (pl/en/ar) in order, no TR/UK; one selected; tapping another calls `setLocale` and updates the selected radio; **no** "missing language" helper present; screen re-renders in the new language; ar renders RTL + Amiri in `test/features/profile/language_screen_test.dart` (dep: T023)
- [x] T026 [US2] Extend `integration_test/profile_flow_test.dart`: open Language → pick **Arabic** → assert app-wide RTL applied and Screen 1's Language row value updated, with no app restart (deps: T024, T022)

---

## Phase 5: US3 — About screen (P3)

**Goal**: Tap About → app-mark card + Suggest CTA card + LINKS group + footer; external links open via the launcher, Open-source licenses opens the native page. **Independent test**: with `FakeExternalLinkLauncher`, Website/Privacy/Terms call `open` with the right `Env` URLs, the suggest card opens `Env.suggestFormUrl`, and Open-source licenses pushes the native `LicensePage`.

- [x] T027 [P] [US3] Create `AppMarkCard` (gradient map-pin glyph (static; glow in US4), app name `Halal Map Polskie`, `versionLine`, mission paragraph) in `lib/features/profile/presentation/widgets/app_mark_card.dart` (deps: T004, T006)
- [x] T028 [P] [US3] Create `SuggestPlaceCard` (tappable umber-tinted card, pin-plus tile, title + sub, external arrow → `externalLinkLauncherProvider.open(Env.suggestFormUrl)` with failure SnackBar) in `lib/features/profile/presentation/widgets/suggest_place_card.dart` (deps: T004, T006, T007)
- [x] T029 [US3] Create `AboutScreen`: `BackHeader(kicker: aboutKicker, title: aboutTitle)` + `AppMarkCard` + `SuggestPlaceCard` + `GroupCard`(Linki → Website/Privacy/Terms `SettingRow` external → launcher; Open-source licenses `SettingRow` chevron → `showLicensePage(applicationName: 'Halal Map Polskie', applicationVersion: AppInfo.version)`) + `ProfileFooter` in `lib/features/profile/presentation/about_screen.dart` (deps: T010, T011, T012, T018, T027, T028)
- [x] T030 [US3] Add the nested `/profile/about` `GoRoute` → `AboutScreen` under the Profile branch in `lib/core/routing/app_router.dart` (deps: T029, T016)
- [x] T031 [P] [US3] Widget test `AboutScreen`: app-mark card + suggest card + LINKS group render; Website/Privacy/Terms/Suggest call `FakeExternalLinkLauncher.open` with `Env.websiteUrl`/`privacyUrl`/`termsUrl`/`suggestFormUrl`; Open-source licenses pushes `LicensePage` (no external URL); pl/en/ar + RTL in `test/features/profile/about_screen_test.dart` (deps: T029, T008)
- [x] T032 [US3] Extend `integration_test/profile_flow_test.dart`: open About → tap an external link (assert fake launcher called) → open Open-source licenses (assert native page) → back-navigate to Screen 1 (deps: T030, T026)

---

## Phase 6: US4 — Motion (entrance + ambient + press; reduced-motion safe) (P4)

**Goal**: All three screens animate per `ANIMATIONS.md` and disable everything under OS reduced motion. **Independent test**: with animations enabled, blocks fade/scale in and ambient loops run; with `MediaQuery.disableAnimations = true`, all blocks render at final state instantly, no ambient loops, and language selection still updates.

- [x] T033 [US4] Add staggered entrance to all three screens via `EntranceController` + `FadeRiseIn` (cards use scale-in ~0.96→1; ~100 ms stagger per block) in `profile_screen.dart`, `language_screen.dart`, `about_screen.dart` (deps: T019, T023, T029)
- [x] T034 [P] [US4] Add ambient loops gated by `MediaQuery.disableAnimations`: clock-ring glow (3.4 s) + badge float (3.2 s, reverse) in `coming_soon_banner.dart`; app-mark glow (3.4 s) + shimmer (4.2 s, 800 ms delay) in `app_mark_card.dart` (deps: T017, T027)
- [x] T035 [P] [US4] Ensure row/card press-scale via `PressableScale` on `SettingRow`, `SuggestPlaceCard`, and the Notify button (confirm/extend; honors reduced motion) in `lib/shared/widgets/setting_row.dart` + the two card widgets (deps: T011, T028, T017)
- [x] T036 [P] [US4] Widget test (reduced motion): with `disableAnimations` on, the three screens render at final opacity/scale, no ambient loop tickers active, no press scale; radio selection still updates in `test/features/profile/profile_motion_test.dart` (deps: T033, T034, T035)

---

## Phase 7: Polish & Cross-Cutting Concerns

- [x] T037 [P] Accessibility pass: semantic labels on every row/button/radio/back chevron (external rows announced as opening externally), tap targets ≥ 44 dp, usable at OS-maximum font scale — verified across the three screens in `test/features/profile/profile_a11y_test.dart` (deps: T019, T023, T029)
- [x] T038 [P] Localization + RTL parity: assert no hard-coded user-visible strings; Polish copy verbatim; full RTL mirroring (chevrons/arrows flip, Amiri for Arabic) across all three screens × pl/en/ar in `test/features/profile/profile_l10n_rtl_test.dart` (deps: T019, T023, T029)
- [x] T039 Privacy guardrail check: confirm no analytics/tracking call exists on any Profile screen and no PII is collected/transmitted (code review + grep; the only network actions are user-initiated `ExternalLinkLauncher` hand-offs) (FR-021)
- [ ] T040 Visual-parity review against the design captures (`specs/design/profile/claude_code_handoff_profile/reference/screens-overview.png`, `01-coming-soon.png`, and the HTML reference): verify layout, cocoa/cream tokens, Lora/Amiri typography, banner gradient + glow, radii/spacing, and interactive states for all three screens; record diffs (optional golden tests under `test/features/profile/golden/`)
- [x] T041 Run `flutter analyze` (clean, incl. no dead code from the removed settings stub), `dart format .`, and `flutter gen-l10n`; confirm widgets reference `tokens.dart` (no magic literals) (deps: all)
- [x] T042 Run the full integration test on the Pixel 7 / API 34 emulator (`flutter test integration_test/profile_flow_test.dart`) and the unit + widget suites (`flutter test`); confirm pristine output (Constitution §4) (deps: all)

---

## Dependencies

### Task Dependencies
- Setup (T001–T002) → before everything.
- Foundational (T003–T016) → before the user-story phases. Within it: T003 → T007 → {T008/T009}; T006 → {T010/T011/T012} → {T013/T014/T015}; T016 (cleanup) independent but before route additions (T024/T030).
- **US1 (T017–T022)**: T004/T006/T007 → T017; T003/T004 → T018; {T010/T011/T012/T017/T018} → T019 → {T020/T021/T022}.
- **US2 (T023–T026)**: T005/T011 → T023 → T024 → T025; T024 → T026.
- **US3 (T027–T032)**: T027/T028 → T029 → T030 → T031; T030 → T032.
- **US4 (T033–T036)**: needs the screens/widgets (T019/T023/T029/T017/T027/T028) → T033/T034/T035 → T036.
- **Polish (T037–T042)**: after the relevant screens exist; T041/T042 last.

### Story Completion Order
US1 (MVP) → US2 → US3 → US4 → Polish. US2 and US3 are independent of each other (both only need Foundational); US1 navigation targets are wired when US2/US3 land. US4 is purely additive over US1–US3.

### Notes
- `[P]` tasks = different files, no incomplete deps. The shared widgets (T010/T011/T012), their tests (T013/T014/T015), the two banner/footer widgets, and the per-screen test files are the main parallel clusters.
- No backend, no storage changes, no new dependencies, no platform-manifest changes.
- Commit after each task; verify tests fail before implementing where TDD applies.

## Parallel Execution Examples

### Foundational shared components (one executor, sequential within file, parallel across files)
```
T010 [P] BackHeader        → lib/shared/widgets/back_header.dart
T011 [P] SettingRow        → lib/shared/widgets/setting_row.dart
T012 [P] GroupCard         → lib/shared/widgets/group_card.dart
(then) T013/T014/T015 [P]  → their *_test.dart files
```

### US1 leaf widgets in parallel
```
T017 [P] [US1] ComingSoonBanner  → .../widgets/coming_soon_banner.dart
T018 [P] [US1] ProfileFooter     → .../widgets/profile_footer.dart
```

### Cross-story (after Foundational) — independent screens
```
Executor A (US2): T023 LanguageScreen → language_screen.dart
Executor B (US3): T027/T028 AppMarkCard + SuggestPlaceCard → about widgets
```

## Implementation Strategy

- **MVP = US1 only**: Screen 1 renders inside the shell with the banner + the three settings groups + footer, external links working, fully localized. Shippable as the guest Profile landing even before Language/About sub-screens land (rows can show until their routes are wired in US2/US3).
- **Incremental**: add US2 (Language, the one interactive setting), then US3 (About), then US4 (motion polish), then the cross-cutting Polish phase. Each phase is independently testable.

## Task Completeness Checklist
- [x] Every spec FR (FR-001…FR-021) maps to ≥1 task; every TC (TC-1…TC-21) maps to a test task
- [x] Both contracts (`external_link_launcher.md`, `profile_components.md`) have implementation + test tasks
- [x] Data-model items (reused `AppLocale` + helpers, `ExternalDestinations`/`Env`, `LanguageOption`) covered
- [x] Mandatory test types present: unit (T009), widget (T013–T015, T020/T021, T025, T031, T036, T037, T038), integration (T022/T026/T032/T042)
- [x] Settings-stub removal tasked (T016) with an `analyze`-clean gate (T041)
- [x] Every task has checkbox, ID, optional [P]/[US], and an exact file path
