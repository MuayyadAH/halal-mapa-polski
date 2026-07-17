# Phase 0 Research — Onboarding Flow

**Feature**: 001-onboarding-flow
**Date**: 2026-05-27

The spec (`spec.md`) has no `[NEEDS CLARIFICATION]` markers after two rounds of dialogue + one clarify session. This research consolidates **technical decisions** required to implement the feature — how the existing scaffold (Riverpod 3 + go_router 17 + flutter_secure_storage 10 + Flutter 3.44) fits the spec's requirements.

---

## 1. Splash animation implementation

**Decision (implemented 2026-05-27)**: Single `AnimationController` driving `Interval`-clipped curves over a 2200ms total (first-time) / 1000ms (returning) timeline. The pin teardrop and crescent are drawn via `CustomPaint` (rather than SVG assets or Rive) using `Path.computeMetrics()` for the stroke-draw effect — see `_BrandMarkPainter` in `animated_splash_screen.dart`. Five sub-animations interleave: pin stroke draw, pin fill fade, crescent scale-in (elasticOut), wordmark fade+rise, loader fade. The loader's spin is a separate looping `AnimationController` so it can outlive the main timeline.

**Rationale**: The design's animation has overlapping but offset stages; `TweenSequence` plus `Interval` is the idiomatic Flutter way to express that. Avoids the bookkeeping cost of multiple controllers and gives a single timeline to abort (for Reduce Motion).

**Alternatives considered**:
- `Rive` (.riv asset) — gives the designer fine control but introduces a runtime dependency we don't otherwise need; postponed to post-MVP polish if/when the design team produces a Rive file
- Multiple separate `AnimationController`s — more code, harder to abort cleanly, harder to test as a single timeline
- `Lottie` — same as Rive concern; the design provided animation timings in code, not as a Lottie JSON

**Source**: Manual — Flutter animations docs are well-known.

---

## 2. Reduce Motion / Disable Animations detection

**Decision**: Read `MediaQuery.disableAnimationsOf(context)` (or `MediaQuery.of(context).disableAnimations` for older Flutter — 3.44 supports the dedicated accessor). When `true`, the splash widget builds the post-animation final state directly and immediately invokes its `onComplete` callback in the next frame via `WidgetsBinding.instance.addPostFrameCallback`.

**Rationale**: Built into Flutter; respects the OS-level setting on both iOS ("Reduce Motion" toggle) and Android ("Animator duration scale = Off"). One source of truth, no custom logic needed.

**Alternatives considered**:
- Platform channel to read iOS/Android settings directly — redundant; Flutter already exposes this
- App-level "Reduce Motion" toggle in Settings — adds UI we don't need (OS setting is sufficient)

**Source**: Manual — Flutter `MediaQuery` API.

---

## 3. Language picker widget pattern

**Decision**: A `LanguagePicker` widget composed of three `_LanguagePill` widgets in a `Row`. Each pill `onTap` calls `ref.read(localeNotifierProvider.notifier).setLocale(AppLocale.X)`. The pill listens to `localeNotifierProvider` and styles itself as active or inactive based on `state.locale`. Width 28 sp × height 22 sp per design.

**Rationale**: Riverpod's separation of `read` (action) and `watch` (state) keeps the pill widget testable. Custom widget (not a Material `ChoiceChip`) because the visual treatment is too specific — sand-400 active background, cream pill border, no chip drop shadow.

**Alternatives considered**:
- `ChoiceChip` from Material — wrong visual; would require heavy theming overrides
- `SegmentedButton` from Material 3 — too wide; design uses three tiny independent pills

**Source**: Manual — Riverpod + custom widget pattern.

---

## 4. First-launch detection on app bootstrap

**Decision**: In `main.dart`, before `runApp(...)`, do an async read of the two secure_storage keys (`onboarding_completed_at`, `selected_locale`) via `FlutterSecureStorage().read(key: ...)`. Pass the resolved values into `App` via constructor parameters. `App` uses them to seed `LocaleNotifier`'s initial state and to decide the router's initial location (`/onboarding` if onboarding-not-completed, `/home` otherwise).

**Rationale**: The keys are tiny (< 50 bytes total); secure_storage reads are fast on cold launch (~5–20 ms typical). Doing them synchronously before `runApp` avoids a flicker where the app renders a default screen first and then re-routes once the flag is read.

**Caveat**: Secure storage reads must complete before the first frame. The native splash from `flutter_native_splash` is still visible during this brief async work, so the user sees the brand icon — not a blank screen. No second loading state is needed.

**Alternatives considered**:
- Async read inside `App.build()` with a placeholder loading widget — introduces a flicker between native splash and first real frame; user sees a Material default screen briefly
- Store the flag in `SharedPreferences` instead — simpler but violates the constitution's "no `SharedPreferences` for PII or sensitive flags" rule; the onboarding flag isn't sensitive but the locale preference is tied to user identity and worth keeping consistent
- Block at the `FlutterNativeSplash.preserve` / `remove` API — yes, doing this; the read happens between `preserve` and `remove`

**Source**: Manual — Flutter bootstrap pattern + secure_storage API.

---

## 5. go_router routing for the onboarding shell

**Decision**: Add a new top-level `GoRoute` at `/onboarding` (with sub-routes `/onboarding/find`, `/onboarding/trust`, `/onboarding/community`, `/onboarding/location`) **outside** the existing `StatefulShellRoute.indexedStack` that holds the 5-tab navigation. The onboarding routes do not show the bottom tab bar (it's only rendered inside the shell). Splash is a separate top-level route (`/splash`) that decides where to go next based on the onboarding flag.

**Rationale**: Onboarding is a flow, not a tab. Tabs don't apply. Wrapping it in the shell would visually leak the bottom-nav into onboarding, which is wrong.

The router's `initialLocation` decision happens in `app.dart`: `initialLocation: onboardingCompleted ? '/home' : '/splash'`. Returning users go through Splash too (truncated animation), but the splash widget's `onComplete` immediately routes to `/home`.

**Alternatives considered**:
- Make onboarding a separate `MaterialApp` that swaps in once complete — fragile, breaks deep-linking from notifications later
- Onboarding as a modal `showDialog` overlay — defeats the immersive welcome experience the design calls for
- Conditional routing inside the shell route — couples onboarding to the tab structure, which is bad coupling

**Source**: Manual — go_router 17.x routing patterns.

---

## 6. Page transitions for Onboard 1/2/3

**Decision**: A `PageView` widget with a `PageController` inside a dedicated `OnboardShell` widget at `/onboarding/intro`. The 3 onboard screens are pages within the PageView. Swipe gestures advance the page; the "Pomiń" link calls `controller.animateToPage(2)` directly. The shell renders the language picker, page indicator, and content slot.

**Rationale**: Native swipe behaviour is part of the UX expectation for intro screens. `PageView` is the standard Flutter widget for this. Putting all 3 pages under one route (`/onboarding/intro`) instead of three separate routes (`/onboarding/find`, `/onboarding/trust`, `/onboarding/community`) avoids URL clutter and makes the `PageView` lifecycle clean.

**Update from plan.md Project Structure**: The earlier plan listed three separate routes for the onboard pages. Replace with a single `/onboarding/intro` route holding the PageView. The `PageView`'s current page index is exposed via a Riverpod provider so the page-indicator widget can reactively re-render. The "current page" state is local to the onboarding session — not persisted.

**Alternatives considered**:
- Three separate go_router routes for Onboard 1/2/3 — works but adds URL noise and complicates the page indicator state synchronisation
- `TabBarView` with hidden `TabBar` — overkill; PageView is lighter

**Source**: Manual — Flutter standard widgets.

---

## 7. Native-splash to in-app-splash handoff

**Decision**: The native splash background colour (`#faf5e9` light / `#1a100e` dark — already configured in `pubspec.yaml` via `flutter_native_splash:`) matches the in-app `AnimatedSplash` widget's background colour. The in-app splash starts from the same visual state the native splash ended on, then proceeds with the staggered animation.

**Rationale**: Eliminates the visual seam. The user perceives one continuous splash, even though there are technically two surfaces (native OS splash → Flutter `AnimatedSplash` widget).

**Implementation note (resolved 2026-05-27)**: `flutter_native_splash` was NOT re-added at runtime. Flutter's default behaviour keeps the native splash visible until the first frame renders, and our matching background colour means the handoff to the in-app `AnimatedSplashScreen` is seamless without explicit `preserve()` / `remove()` calls. The native splash + launcher icons (generated earlier via the one-shot tools) remain in `android/app/src/main/res/` and `ios/Runner/Assets.xcassets/`; only the dev-dependency that produced them is gone. To regenerate them later, temporarily re-add `flutter_native_splash` / `flutter_launcher_icons` to dev_dependencies, run their generators, then remove the packages again.

**Alternatives considered**:
- Skip the preserve/remove call and rely on Flutter's default behaviour — causes a brief flash of the Material default theme between native splash and first Flutter frame
- Use a plain `Container(color: ...)` as the first widget — same flash problem if the secure_storage read isn't done yet

**Source**: Manual — `flutter_native_splash` package + Flutter bootstrap docs.

---

## 8. System locale detection

**Decision**: `WidgetsBinding.instance.platformDispatcher.locale.languageCode` read once at app start. If the value is in `{'pl', 'en', 'ar'}` → use it as the default. Otherwise → fall back to `pl`.

**Rationale**: `PlatformDispatcher.locale` is the canonical Flutter API for the device's primary locale. Single call, no platform channels needed.

**Caveat**: On first launch, `selected_locale` in secure_storage is empty, so we use the platform-derived default. As soon as the user taps a pill, we write the choice. On subsequent launches, the stored value overrides the platform locale (so a Polish-system user who picked English doesn't get reset).

**Alternatives considered**:
- `Localizations.localeOf(context)` — only available inside `MaterialApp`, can't be used before `runApp`
- Native platform channel read — same data, more code

**Source**: Manual — Flutter `PlatformDispatcher` API.

---

## 9. Onboarding state machine

**Decision**: Single Riverpod `Notifier<OnboardingState>` (`OnboardingNotifier`) with three actions:
- `advancePage()` — moves from current intro page to next (clamped at 2 = Onboard 3)
- `skipToEnd()` — jumps current intro page to 2
- `complete()` — sets `OnboardingStatus.completed`, writes `onboarding_completed_at`, and triggers the router to navigate to Map

State shape: `{ status: OnboardingStatus, currentIntroPage: int (0..2) }`. The `locale` is intentionally **not** part of `OnboardingState` — it lives in a separate `LocaleNotifier` because locale outlives onboarding (it's the app-wide active locale).

**Rationale**: Onboarding-specific state (current page, status) belongs together; locale is global. Separating them keeps each notifier small and testable.

**Alternatives considered**:
- Single mega-notifier holding everything (locale, page, status, location-permission status) — too much; harder to test in isolation
- StateMachine package (e.g. `state_machine`) — overkill for 3 states

**Source**: Manual — Riverpod `Notifier` patterns.

---

## 10. Persistence layer abstraction

**Decision**: Define `OnboardingRepository` as an abstract Dart class in `lib/features/auth/data/onboarding_repository.dart` with two methods:
- `Future<DateTime?> readCompletedAt()` — returns null if onboarding never completed
- `Future<void> markCompleted()` — writes ISO-8601 timestamp of `DateTime.now().toUtc()`

Concrete impl: `SecureStorageOnboardingRepository` wrapping the existing `secureStorageProvider` from `core/storage/secure_storage.dart`. Riverpod-exposed via `onboardingRepositoryProvider`.

The `LocaleNotifier` separately reads/writes the `selected_locale` key via the same `secureStorageProvider` directly (no separate repository — too thin to warrant one).

**Rationale**: The repository pattern gives us a clean unit-test target (mock the repository, test the notifier in isolation). The locale persistence is simpler — a string read/write — and doesn't need its own abstraction layer.

**Alternatives considered**:
- One generic `OnboardingPreferencesRepository` holding both keys — couples locale (global) to onboarding (one-time flow); leaks abstraction
- No abstraction, call `FlutterSecureStorage` directly from notifiers — testable only with full mocking of the platform plugin; harder than abstracting one interface

**Source**: Manual — repository pattern + Riverpod testing patterns.

---

## Cross-cutting concerns

### Locale switching with active widgets visible

When the user taps "EN" while on Onboard 2, the locale change must propagate immediately. The mechanism: `App` is a `ConsumerWidget` that watches `localeNotifierProvider` and passes `state.locale.toFlutterLocale()` as `MaterialApp.locale`. Changing the locale rebuilds the entire `MaterialApp` subtree with the new `Localizations` widget, which re-resolves all `AppLocalizations.of(context).xxx` calls. Stale text disappears within one frame.

### Arabic + Lora display headings

Lora doesn't render Arabic well. The `AppTheme` text styles need a per-locale font override: when the active locale is `ar`, `displayMedium` (and any heading TextStyle that defaults to Lora) should fall back to Amiri. This can be done with `Theme.of(context).textTheme.displayMedium?.copyWith(fontFamily: HmpFonts.arabic)` inside Arabic-locale screens, or globally via a `Theme.of(context)`-aware accessor. **Decision: globally** — `app.dart`'s `theme:` and `darkTheme:` already pick up the locale; we'll add a per-locale conditional in `core/theme/theme.dart` that switches the heading font when locale is `ar`.

This is a small but real cross-cutting decision that affects every screen with a heading, not just onboarding. Worth surfacing here.

### Testing without a real emulator on Windows

The user is on Windows + Android emulator. iOS testing requires macOS — not available. So the integration test in this feature is Android-only for v1. iOS smoke testing is deferred (post-MVP) until a Mac builder is available. The widget tests run on any platform with the Flutter SDK, so 90 %+ of test coverage is platform-agnostic.

---

## Summary

All 10 research topics resolved. Zero NEEDS CLARIFICATION markers remaining. The implementation is straightforward Flutter feature work using the established scaffold; no new technologies, no architectural risk.

**Ready to proceed to Phase 1 design artifacts** (`data-model.md`, `contracts/`, `quickstart.md`).
