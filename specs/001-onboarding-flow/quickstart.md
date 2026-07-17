# Quickstart — Onboarding Flow

**Feature**: 001-onboarding-flow
**Audience**: Developer working on this feature

## Setup (one-time)

Assumes the step-one scaffold is already in place (see project README).

```powershell
# From C:\Users\kaka-\IdeaProjects\n-ai1st-kit\project-repos\halal-map-polskie\
flutter pub get
flutter gen-l10n   # after ARB files are updated as part of the feature work
```

## Running the feature

```powershell
# Default (Polish locale, first-launch state if no prior data)
flutter run

# Force a specific locale at launch (overrides system locale)
flutter run --dart-define=DEBUG_LOCALE=ar    # Arabic with RTL
flutter run --dart-define=DEBUG_LOCALE=en    # English
```

> Note: `DEBUG_LOCALE` is a dev-only flag wired up during this feature's implementation (TBD task in `tasks.md`). It bypasses `selected_locale` and `system locale` for testing.

## Testing each state

### First-time user (full flow)

```powershell
# 1. Wipe app data on the emulator to clear secure_storage
adb shell pm clear pl.halalmap.app

# 2. Launch
flutter run
```

Expected: Splash (2.2s animation) → Onboard 1 → Onboard 2 → Onboard 3 → LocationPermission → Map.

### Returning user (fast path)

After completing onboarding once, simply re-launch (kill + restart):

```powershell
# In emulator: long-press app → close, or use adb
adb shell am force-stop pl.halalmap.app
flutter run
```

Expected: Splash (truncated ~1s) → Map. No onboarding screens.

### Reduce Motion bypass

```powershell
# Enable Reduce Animation on the emulator
adb shell settings put global animator_duration_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global window_animation_scale 0

# Restart the app
adb shell am force-stop pl.halalmap.app
flutter run
```

Expected: Native splash → directly to Onboard 1 (first-time) or Map (returning). No in-app splash animation.

To restore animations:
```powershell
adb shell settings put global animator_duration_scale 1
adb shell settings put global transition_animation_scale 1
adb shell settings put global window_animation_scale 1
```

### Location permission states

```powershell
# Reset location permission to "never asked"
adb shell pm reset-permissions pl.halalmap.app

# OR specifically grant/deny
adb shell pm grant pl.halalmap.app android.permission.ACCESS_COARSE_LOCATION
adb shell pm revoke pl.halalmap.app android.permission.ACCESS_COARSE_LOCATION
```

After resetting permissions and completing Onboard 3 via "Kontynuuj" → the LocationPermission screen should appear. After granting (or denying), subsequent "Kontynuuj" paths skip the pre-prompt and go straight to Map.

### Language switch round-trip

1. Launch fresh (data cleared).
2. On Onboard 1, tap "EN" — entire screen switches to English.
3. Tap "ع" — switches to Arabic with RTL.
4. Tap "Dalej" / swipe — language persists on Onboard 2.
5. Complete onboarding → Map opens in selected language.
6. Kill app, relaunch — Map opens immediately in the persisted language.

## Tests

### Unit tests

```powershell
flutter test test/features/auth/
```

Coverage: `OnboardingRepository`, `LocaleNotifier`, `OnboardingNotifier`, animation controller logic.

### Widget tests (per locale)

```powershell
flutter test test/features/auth/presentation/screens/
```

Each screen has tests for pl / en / ar variants — 5 screens × 3 locales = 15 widget tests minimum.

### Integration test

```powershell
flutter test integration_test/onboarding_happy_path_test.dart
```

Three integration scenarios:
1. **First-time happy path** — cold launch with data cleared → assert Splash → Onboard 1/2/3 → LocationPermission → Map, all in < 10 seconds for the fastest "Pomiń + Browse as guest" route.
2. **Returning-user fast path** — completed flag set → cold launch → assert Splash (truncated) → Map.
3. **Reduce Motion bypass** — `MediaQuery(disableAnimations: true)` injected → assert in-app splash skipped.

## Debug checklist

Before opening a PR for this feature:

- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — all unit + widget tests green
- [ ] `flutter test integration_test/` — all 3 integration scenarios green on Pixel 7 emulator
- [ ] Manually verified each of the three locales on the emulator
- [ ] Manually verified Reduce Motion bypass on the emulator
- [ ] Manually verified Polish-system + AR-selected scenario (user on Polish phone, picks Arabic at onboarding)
- [ ] Polish copy reviewed against `.ai_project_memory/constitution-frontend.md` §V.2 (verbatim labels: Pomiń, Kontynuuj, Przeglądaj jako gość, Pozwól, Nie teraz)
- [ ] No backend API calls fired during onboarding (verified via Charles Proxy or Android Studio Network Inspector — should see zero requests)

## Known constraints (this feature only)

- **iOS not tested** — development on Windows; iOS smoke testing requires a Mac builder. Deferred until iOS CI exists. Widget tests are platform-agnostic so they cover most cases.
- **EN/AR translations are placeholders** — Polish is canonical. EN/AR translations will be replaced by a human translator before public release (per `constitution-frontend.md` §V.4).
- **Hero illustrations on Onboard 1/2/3 are placeholder SVGs** — final commissioned art is post-MVP.
