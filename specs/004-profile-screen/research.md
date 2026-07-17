# Phase 0 Research: Profile Tab — Guest (v1)

**Feature**: `004-profile-screen` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

All items below are resolved — **no `NEEDS CLARIFICATION` remain**. Sources are the spec, the design handoff (`specs/design/profile/`), the constitution, and the current codebase. This feature is **presentational and additive**; it introduces **no new dependencies**.

---

## R1 — Routing: replace the Profile body, add Language/About, remove the orphaned settings stub

- **Decision**: Replace `ProfileScreen`'s placeholder body with **Screen 1** (coming-soon + settings). Add two nested `GoRoute`s under the existing Profile branch: `/profile/language` → `LanguageScreen` (Screen 2) and `/profile/about` → `AboutScreen` (Screen 3). **Remove** the existing `/profile/settings` `GoRoute` and delete `lib/features/settings/settings_screen.dart` (the "coming soon" stub) — the guest design has no separate Settings landing (spec §2 Conflict; Clarify 2026-05-31).
- **Rationale**: The 5-tab `StatefulShellRoute` already mounts Profile at `/profile`; nested routes push/pop with the platform transition (ANIMATIONS §"Navigation transitions"). The settings stub is unreachable under the new design and leaving it violates the constitution's no-dead-code rule (§ Problem-Solving). The comprehensive Settings screen (frontend constitution §4.9) is a separate future feature that reintroduces its own route.
- **Alternatives considered**: Keep the settings route unused (dead code — rejected); repurpose the stub into Language/About (couples unrelated files, worse names — rejected).
- **Source**: Manual (`lib/core/routing/app_router.dart`, spec §2/§3).

## R2 — Language picker binds to the existing locale controller (live, no restart)

- **Decision**: Screen 2 reads the active locale from `localeNotifierProvider` and writes changes via `ref.read(localeNotifierProvider.notifier).setLocale(...)` — the **single source of truth** (reused from 001). The full radio-list widget is new, but it reuses the same notifier the onboarding `LanguagePicker` pill row uses. No app restart: `app.dart`'s `MaterialApp.router` already does `final locale = ref.watch(localeNotifierProvider).locale`, so a change rebuilds the whole tree (including `Directionality` → RTL for Arabic) reactively.
- **Rationale**: FC-2 / FR-010 require one locale owner and immediate, app-wide effect; the mechanism is already wired and proven in onboarding. After selection the user **stays** on Screen 2, which itself re-renders in the chosen language (Clarify Q3).
- **Alternatives considered**: A Profile-local locale copy (violates FC-2/§1.1 — rejected); auto-pop after select (less intentional; the screen re-render is the confirmation — rejected per Clarify Q3).
- **Source**: Manual (`lib/app.dart`, `lib/features/auth/presentation/state/locale_notifier.dart`, `.../widgets/language_picker.dart`).

## R3 — External-link launcher abstraction (URLs + graceful failure)

- **Decision**: Add a small shared `ExternalLinkLauncher` abstraction in `lib/core/links/` mirroring the existing `MapsLauncher` pattern: `Future<bool> open(Uri uri)` implemented with `url_launcher`'s `launchUrl(..., mode: LaunchMode.externalApplication)`, exposed via a Riverpod `externalLinkLauncherProvider`. A `false`/throw result surfaces a brief localized `SnackBar` ("couldn't open") — no crash (FR-014, Constitution §1.3). A `FakeExternalLinkLauncher` records calls for headless widget tests.
- **Rationale**: Keeps URL launching testable and consistent with `MapsLauncher`; the bool return models the graceful-failure path the spec requires.
- **Alternatives considered**: Call `launchUrl` inline in widgets (untestable, duplicated error handling — rejected); reuse `MapsLauncher` (it is place/coordinate-specific — wrong shape).
- **Source**: Manual (`lib/core/maps/maps_launcher.dart` as the pattern; `url_launcher` already in `pubspec.yaml`).

## R4 — Open-source licenses → Flutter's native license page

- **Decision**: The "Open-source licenses" row calls Flutter's built-in `showLicensePage(context: ...)` (Material), themed via the app's `ThemeData`. No URL, no dependency.
- **Rationale**: FR-015 / Clarify Q1 — the native page renders bundled package licenses in-app and is the constitution-friendly way to surface the open-source notice while the repo stays private (no GitHub link yet).
- **Alternatives considered**: A custom licenses screen (re-implements a solved problem — rejected); an external URL (repo not public — rejected).
- **Source**: Flutter SDK (`material.dart`).

## R5 — Placeholder external URLs from a single config point

- **Decision**: Hold the four placeholder URLs (suggest/notify form, website, privacy policy, terms of use) as compile-time values in **`Env`** (`lib/core/env/env.dart`), each `String.fromEnvironment(...)` with a placeholder `defaultValue`, so they are overridable later via `--dart-define` without touching the screens (FR-016). The "Notify me" button and "Suggest a place" rows/card share the **same** form URL.
- **Rationale**: `Env` is already the project's single configuration point for build-time values (map style/keys, API base); adding link URLs there is consistent and keeps real URLs out of git while remaining replaceable. Not secrets, so no secure storage.
- **Alternatives considered**: A separate `app_links.dart` const file (fine, but duplicates `Env`'s role — rejected for consistency); hard-coding per widget (violates FR-016/§X — rejected).
- **Source**: Manual (`lib/core/env/env.dart`).

## R6 — Shared components live in `lib/shared/widgets/`

- **Decision**: Implement **BackHeader**, **SettingRow** (with `chevron` / `external` / accent variants), and **GroupCard** once in `lib/shared/widgets/` (alongside `FadeRiseIn`, `PressableScale`), styled only from `tokens.dart` (`HmpColors`/`HmpSpacing`/`HmpRadii`/`HmpFonts`). The three screens compose them (FR-017).
- **Rationale**: They are design-system primitives the future full Settings screen (§4.9) and other settings-like surfaces will reuse; `lib/shared/widgets/` is where cross-feature primitives already live. Avoids feature→feature coupling (§1.1).
- **Alternatives considered**: Keep them under `lib/features/profile/.../widgets/` (re-promote later when Settings arrives — acceptable but defers the right home; chosen location avoids churn).
- **Source**: Manual (`lib/shared/widgets/`, constitution-frontend §III/§X).

## R7 — Motion: reuse entrance/press primitives; add gated ambient loops

- **Decision**: Reuse `EntranceController` + `FadeRiseIn` for the staggered fade-up entrance (per-block `Interval`s ≈100 ms steps; cards use a scale-in variant) and `PressableScale` for row/card press. Add three small **looping** `AnimationController`s for the ambient effects — clock-ring/app-mark **glow** (3.4 s), coming-soon **badge float** (3.2 s, `reverse`), app-mark **shimmer** (4.2 s, 800 ms delay). Every animation is gated by `MediaQuery.of(context).disableAnimations` (the entrance mixin already jumps to final state; ambient controllers simply don't `repeat()`), per FR-018 / ANIMATIONS.md.
- **Rationale**: The shared primitives already encode the reduced-motion contract; ambient loops are low-CPU `AnimatedBuilder`s over a `BoxShadow`/`Transform`. Curve `cubic-bezier(.22,1,.36,1)` ≈ `Curves.easeOutCubic`.
- **Alternatives considered**: `flutter_animate` (new dep for what the shared primitives already do — rejected).
- **Source**: Manual (`lib/shared/widgets/fade_rise_in.dart`, `pressable_scale.dart`, ANIMATIONS.md).

## R8 — Localization keys (Polish canonical, verbatim from the design string tables)

- **Decision**: Add ~Profile ARB keys to `app_pl.arb` (canonical, verbatim from the README string tables), `app_en.arb` (English from the tables), and `app_ar.arb` (placeholder, human-translated later). Keys cover: titles/kickers (profile, settings, language, info, about), banner (badge, headline + italic accent, sub, notify button), group labels (preferences, community, info, links), row labels + subs (language, suggestPlace, about, privacy, website, terms, licenses), the language native/English names, the About mission paragraph, the version line, footers, and the "couldn't open link" message. The Arabic native language name uses the Amiri font (already bundled). Run `flutter gen-l10n`.
- **Rationale**: §1.5/§V — no hard-coded strings; Polish is the source of truth and the design copy is final. The headline's italic accent word is a styled `TextSpan`, not a separate string.
- **Alternatives considered**: Hard-coding Polish in widgets (violates §1.5/§XIII — rejected).
- **Source**: Design README "String tables"; `lib/l10n/app_*.arb`.

## R9 — Testing strategy

- **Decision**:
  - **Unit**: `ExternalLinkLauncher` URI handling + `false`-path; `AppLocale` ↔ display-name/native-name mapping; the "language list = exactly pl/en/ar" invariant; `Env` link resolution.
  - **Widget**: Screen 1 (banner, three groups, no Dark-mode row, footer), Screen 2 (three radios, single-select, live locale change via a `ProviderScope` override, no helper line), Screen 3 (app-mark, suggest card, LINKS group, licenses → page) — each × {pl, en, ar incl. RTL} × {motion on/off}; `FakeExternalLinkLauncher` asserts the right URLs and the SnackBar on failure; assert `showLicensePage` is reached.
  - **Integration** (`integration_test/profile_flow_test.dart`): open Profil → open Language → pick Arabic → assert app-wide RTL + Screen 1 value updated (no restart) → open About → tap a link (fake launcher) → open licenses → back-navigate to Screen 1.
- **Rationale**: Constitution §4/§XII mandates unit + widget + integration; the launcher/locale abstractions make the UI verifiable headless.
- **Source**: Constitution §4/§XII; 003's testing approach.

## R10 — No new dependencies

- **Decision**: Ship with the **current** `pubspec.yaml`. Needed packages already present: `url_launcher` 6.3.1 (external links), `flutter_riverpod` 3.3.1 (state + provider overrides in tests), `go_router` 17.2.3 (nested routes), `flutter_localizations` + `intl` 0.20.2 (ARB). `showLicensePage` is in the Flutter `material` library. The version string is a single config value (R5/Deferred) — no `package_info_plus`.
- **Rationale**: The feature is presentational over existing infrastructure; adding deps would violate §"Ask First" for no benefit.
- **Alternatives considered**: `package_info_plus` for the version (deferred — a constant suffices for v1); `flutter_animate` (R7 — rejected).
- **Source**: Manual (`pubspec.yaml`).

---

**Outcome**: All unknowns resolved. The only deferred items are intentional and documented in spec §5 (real URLs, theme-mode controller, TR/UK locales, account screens, version source, EN/AR translations) — none block design or task generation.
