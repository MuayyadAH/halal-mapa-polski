# Phase 1 Data Model — Onboarding Flow

**Feature**: 001-onboarding-flow
**Date**: 2026-05-27

Onboarding has **no domain entities** in the architectural sense — no Place, Verification, Review, etc. are created or modified by this flow. The data this feature owns is:

1. **Two persisted preference keys** in `flutter_secure_storage`
2. **Three UI-state enums** used by Riverpod notifiers
3. **Two state classes** held in memory during the onboarding session

---

## 1. Persisted Keys (`flutter_secure_storage`)

Both keys live in the same `FlutterSecureStorage` instance exposed by `secureStorageProvider` (already in `lib/core/storage/secure_storage.dart`). The keys are namespaced under no prefix — they're the first preferences this app stores. Future features should namespace deliberately (e.g. `auth.token`, `cache.*`).

### `onboarding_completed_at`

| | |
|---|---|
| **Key** | `onboarding_completed_at` |
| **Value type** | `String` — ISO-8601 UTC timestamp (e.g. `2026-05-27T14:32:11.123Z`) |
| **Set when** | The user first reaches the Map screen via any path (Kontynuuj + grant, Kontynuuj + deny, Przeglądaj jako gość) |
| **Read when** | App bootstrap in `main.dart`, before `runApp` |
| **Cleared when** | User clears app data (Android) or fully uninstalls (iOS with non-`first_unlock` keychain accessibility — but we use `first_unlock`, so iOS reinstall preserves) |
| **Format** | ISO-8601 with milliseconds, UTC suffix. Example: `2026-05-27T14:32:11.123Z` |
| **Nullable interpretation** | `null` (key absent) = onboarding not completed → show onboarding. Non-null = completed → skip to Map. |

The timestamp itself is informational — not used for any logic. Only the presence/absence of the key matters. Storing a timestamp (vs a plain boolean) makes future analytics or telemetry possible without re-architecting.

### `selected_locale`

| | |
|---|---|
| **Key** | `selected_locale` |
| **Value type** | `String` — exactly one of `pl`, `en`, `ar` |
| **Set when** | (a) On first launch when the user makes an explicit choice via the language picker, or (b) on subsequent launches via Settings → Język |
| **Read when** | App bootstrap in `main.dart`, before `runApp` |
| **Cleared when** | Same as `onboarding_completed_at` |
| **Nullable interpretation** | `null` = no explicit choice yet → use system locale (`PlatformDispatcher.locale.languageCode`) if it's in {pl, en, ar}; otherwise fall back to `pl` |

If the user changes language during onboarding but doesn't complete onboarding (kills the app mid-flow), the chosen locale **is** persisted at the moment of tapping a pill, not at the moment of completing onboarding. This means a user who exits mid-onboarding still gets their chosen language on next launch when they re-enter onboarding from Splash.

---

## 2. Enums

### `OnboardingStatus`

```dart
enum OnboardingStatus {
  notStarted,
  inProgress,
  completed,
}
```

Derived state — not persisted. Computed from `onboarding_completed_at` presence:
- `notStarted` — `onboarding_completed_at` is null AND user has not yet entered the flow
- `inProgress` — `onboarding_completed_at` is null AND user is currently on a splash / onboard / location screen
- `completed` — `onboarding_completed_at` is non-null

`inProgress` is a transient runtime state for the current session. On next cold launch, if the user didn't complete, the status is `notStarted` again.

### `AppLocale`

```dart
enum AppLocale {
  pl,
  en,
  ar;

  Locale toFlutterLocale() => Locale(name); // 'pl', 'en', 'ar'

  static AppLocale fromCode(String? code) {
    return switch (code) {
      'pl' => AppLocale.pl,
      'en' => AppLocale.en,
      'ar' => AppLocale.ar,
      _ => AppLocale.pl, // fallback
    };
  }

  bool get isRtl => this == AppLocale.ar;
}
```

Three values matching the MVP locale scope. `fromCode` is the bridge from raw string (storage or platform locale) to typed enum. `isRtl` derives the text direction for the `Directionality` widget.

### `LocationPermissionStatus`

```dart
enum LocationPermissionStatus {
  notDecided,
  granted,
  denied;
}
```

Mirrors a subset of `permission_handler`'s `PermissionStatus`, narrowed to the three states that affect routing:
- `notDecided` — never asked OR `PermissionStatus.denied` with `shouldShowRequestPermissionRationale == true` (Android) / first launch (iOS). Show the pre-prompt.
- `granted` — OS-level granted (`PermissionStatus.granted` or `.limited`). Skip pre-prompt.
- `denied` — User denied; pre-prompt skipped on subsequent launches (app respects the user's decision until they manually re-enable in Settings).

Computed via a helper that calls `Permission.locationWhenInUse.status` and maps the result.

---

## 3. Runtime State Classes

### `OnboardingState`

```dart
class OnboardingState {
  final OnboardingStatus status;
  final int currentIntroPage; // 0, 1, or 2 (clamped)

  const OnboardingState({
    required this.status,
    required this.currentIntroPage,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentIntroPage,
  }) => OnboardingState(
    status: status ?? this.status,
    currentIntroPage: currentIntroPage ?? this.currentIntroPage,
  );
}
```

Held by `OnboardingNotifier` (Riverpod). The `currentIntroPage` is synced with the `PageView`'s `PageController.page` value via a listener.

### `LocaleState`

```dart
class LocaleState {
  final AppLocale locale;

  const LocaleState({required this.locale});
}
```

Held by `LocaleNotifier`. Minimal — just the active locale. Could be a plain `Notifier<AppLocale>` without the wrapper, but a state class leaves room for adding fields later (e.g., a "pending change is being persisted" bool) without breaking listeners.

---

## 4. State Transition Diagram

```
┌─────────────────────────┐
│  notStarted             │
│  (cold launch + no flag)│
└──────────┬──────────────┘
           │ user reaches Splash → Onboard 1
           ▼
┌─────────────────────────────────────────┐
│  inProgress                              │
│  currentIntroPage: 0 → 1 → 2             │
│                                          │
│  Transitions:                            │
│  - advancePage() / swipe                 │
│  - skipToEnd() — set currentIntroPage=2  │
│  - back gesture — decrement page or exit │
└──────────┬──────────────────────────────┘
           │ user taps Kontynuuj or Przeglądaj jako gość
           │ + reaches Map first frame
           ▼
┌─────────────────────────┐
│  completed              │
│  flag written, key set  │
└─────────────────────────┘
```

The `inProgress → completed` edge writes to secure_storage and also writes any selected locale change that hasn't been persisted yet (defensive — the locale should already be persisted on each pill tap, but a final write is safer).

There is no `completed → notStarted` transition in the app. Onboarding only re-shows after the OS clears app data (Android) or full uninstall (iOS, given `KeychainAccessibility.first_unlock`).

---

## 5. Validation Rules

| Rule | Source | Where enforced |
|---|---|---|
| `selected_locale` must be one of `pl`, `en`, `ar` | FR-004 | `AppLocale.fromCode` falls back to `pl` for invalid values |
| `onboarding_completed_at` must be valid ISO-8601 if non-null | UC-001-IMPL-04 | Read-side parse with `DateTime.tryParse`; if fail, treat as null (re-onboard) |
| `currentIntroPage` clamped to 0..2 | FR-003 | `OnboardingNotifier.advancePage()` and `skipToEnd()` clamp; `PageController.animateToPage` is constrained by the PageView's child count |
| Language pills must always render in same order PL → EN → ع | Design — Welcome B layout | Widget structure; no dynamic reordering |

---

## 6. Relationships & Ownership

```
LocaleNotifier (Riverpod, global, app-lifetime)
  │
  ├── reads/writes ──> secureStorageProvider.write(key='selected_locale')
  │
  └── exposes ──> LocaleState { locale: AppLocale } ──> watched by App, every screen

OnboardingNotifier (Riverpod, global, app-lifetime)
  │
  ├── reads/writes ──> OnboardingRepository
  │                       │
  │                       └── wraps ──> secureStorageProvider.read/write(key='onboarding_completed_at')
  │
  └── exposes ──> OnboardingState { status, currentIntroPage } ──> watched by router + onboarding screens
```

Both notifiers are top-level `NotifierProvider`s (no family parameters). The router (`appRouterProvider`) watches `OnboardingNotifier` to decide initial location; `App` watches `LocaleNotifier` to set `MaterialApp.locale`.

---

## 7. Migration & Versioning

This is the first feature to use `flutter_secure_storage`. The two keys defined here establish the convention. Future features should:
- Use clear key prefixes (e.g. `auth.access_token`, `cache.places_v1`)
- Document any breaking changes to existing key formats here in `data-model.md` updates
- For the onboarding-completed key specifically: if we ever need to "re-run" onboarding for existing users (e.g., a major UX revamp), we'd add a `migration_v2_required` key and check it alongside the original flag, rather than overwriting `onboarding_completed_at`

No migration is needed for this initial release — the keys don't exist yet on any user's device.
