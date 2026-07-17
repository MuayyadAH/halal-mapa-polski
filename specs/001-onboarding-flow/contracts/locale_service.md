# Contract: `LocaleNotifier` (and persistence helper)

**Feature**: 001-onboarding-flow
**Type**: Internal Dart class (Riverpod `Notifier`) — no HTTP
**Location**: `lib/features/auth/presentation/state/locale_notifier.dart`

The `LocaleNotifier` is the single source of truth for the app's active locale. It reads the initial value once at construction (from secure_storage + system locale fallback) and persists every subsequent user change.

## Interface

```dart
class LocaleNotifier extends Notifier<LocaleState> {
  static const _storageKey = 'selected_locale';

  @override
  LocaleState build() {
    // Read initial state synchronously from injected initial value.
    // The async read happens in main.dart before runApp; the result is
    // exposed via a Provider override on ProviderScope.
    final initial = ref.read(_initialLocaleProvider);
    return LocaleState(locale: initial);
  }

  /// Set the locale to a new value and persist it to secure storage.
  /// UI rebuilds immediately (sync); the storage write happens in the background.
  Future<void> setLocale(AppLocale locale) async {
    if (state.locale == locale) return;
    state = LocaleState(locale: locale);
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _storageKey, value: locale.name);
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, LocaleState>(LocaleNotifier.new);

/// Initial locale provider — overridden in ProviderScope at app bootstrap
/// with the value resolved from secure_storage + platform fallback.
///
/// **Implementation note (2026-05-27)**: shipped with a safe default of
/// `AppLocale.pl` rather than throwing. This keeps widget tests and hot
/// reloads working without requiring every test harness to set up an
/// override. Production code still overrides this in `main.dart`, so the
/// "single source of truth" guarantee is unchanged.
final initialLocaleProvider = Provider<AppLocale>((_) => AppLocale.pl);
```

## Bootstrap pattern

In `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  final storage = const FlutterSecureStorage();
  final storedLocale = await storage.read(key: 'selected_locale');
  final storedOnboardingAt = await storage.read(key: 'onboarding_completed_at');

  final initialLocale = AppLocale.fromCode(storedLocale)
      ?? _systemLocaleOrPolish();

  runApp(
    ProviderScope(
      overrides: [
        _initialLocaleProvider.overrideWithValue(initialLocale),
        _onboardingCompletedInitialProvider.overrideWithValue(
          storedOnboardingAt != null,
        ),
      ],
      child: const App(),
    ),
  );
}

AppLocale _systemLocaleOrPolish() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return AppLocale.fromCode(code) ?? AppLocale.pl;
}
```

## Contract guarantees

1. **Single source of truth** — every widget reading `localeNotifierProvider` sees the same value. No widget should call `FlutterSecureStorage` directly for the `selected_locale` key.
2. **Synchronous initial state** — `build()` returns immediately; no `AsyncValue<>` wrapping needed. The async read is done once at app bootstrap.
3. **Optimistic UI** — `setLocale` updates state before the storage write completes. If the storage write fails (rare), the UI is still correct for the session; the choice may not survive a restart, but the user sees their pick immediately. (This is acceptable for a locale preference; for auth tokens we'd be stricter.)
4. **Idempotent same-value set** — calling `setLocale(AppLocale.pl)` when already `pl` is a no-op (no state change, no storage write).
5. **Locale change rebuilds `MaterialApp`** — because `app.dart` watches `localeNotifierProvider` and passes `state.locale.toFlutterLocale()` as `MaterialApp.locale`, switching the locale rebuilds the entire `Localizations` subtree.

## Unit test surface

| Test | Assertion |
|---|---|
| `build() returns the initial locale from the override` | Set `_initialLocaleProvider` to `AppLocale.en`; `state.locale == AppLocale.en` |
| `setLocale changes state and writes to storage` | Call `setLocale(AppLocale.ar)`; state is `ar`; `storage.write` was called with `key: 'selected_locale', value: 'ar'` |
| `setLocale is idempotent for same value` | Call `setLocale(AppLocale.pl)` when already `pl`; no `storage.write` call recorded |
| `Arabic locale flips isRtl` | `LocaleState(locale: AppLocale.ar).locale.isRtl == true` |
| `unknown locale codes fall back to Polish` | `AppLocale.fromCode('de') == AppLocale.pl` |

## Widget test surface

| Test | Assertion |
|---|---|
| `App rebuilds when locale changes` | Pump `App`; capture title text in Polish; call `setLocale(en)`; pump again; title is now English |
| `Arabic locale triggers RTL` | Pump any onboarding screen with `localeNotifierProvider` overridden to `ar`; assert `Directionality.of(context) == TextDirection.rtl` |

## Why not a separate repository class

Unlike `OnboardingRepository`, the locale persistence is just a single string read and write — abstracting it behind another interface would be ceremony without benefit. The `LocaleNotifier` calls `secureStorageProvider` directly. If the surface grows (e.g., adding per-feature locale overrides, fallback chains), a dedicated `LocaleService` can be extracted later.
