# Contract: ExternalLinkLauncher (+ AppInfo / native licenses)

**Feature**: `004-profile-screen` | **Location**: `lib/core/links/external_link_launcher.dart`

A shared, testable wrapper for opening external URLs, mirroring the existing `MapsLauncher` pattern. Backs every external-link control in the Profile screens (FR-014/FR-016) and is reusable by any future feature that opens a URL.

## Interface

```dart
abstract class ExternalLinkLauncher {
  /// Opens [uri] in the external browser/app. Returns true on success,
  /// false if no handler could open it (caller shows a localized message).
  /// Never throws to the caller for an un-launchable URL.
  Future<bool> open(Uri uri);
}

class UrlExternalLinkLauncher implements ExternalLinkLauncher {
  const UrlExternalLinkLauncher();
  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false; // graceful failure (FR-014, Constitution §1.3)
    }
  }
}

final externalLinkLauncherProvider =
    Provider<ExternalLinkLauncher>((ref) => const UrlExternalLinkLauncher());
```

### Behavior
- **Success** → returns `true`; nothing else happens in-app (the OS takes over).
- **Failure** (`false` or exception) → caller (the tapped row/button) shows a one-shot localized `SnackBar` ("couldn't open link"); no crash, user stays put.
- Uses `LaunchMode.externalApplication` (same as `MapsLauncher`) so links open in the browser / external app, not an in-app webview.

### Destination resolution
URLs come from `Env` (build-time, placeholder defaults, `--dart-define`-overridable). The notify button and both suggest controls resolve the **same** `Env.suggestFormUrl`.

## Native licenses (no URL)

"Open-source licenses" does **not** use the launcher. It calls Flutter's built-in:

```dart
showLicensePage(
  context: context,
  applicationName: 'Halal Map Polskie',
  applicationVersion: AppInfo.version, // see below
);
```

## AppInfo (version source)

```dart
abstract final class AppInfo {
  /// v1: single constant (no package_info_plus dependency). Shown verbatim
  /// per the design ("v 1.0.0"). Deferred: wire to package metadata later.
  static const version = '1.0.0';
}
```

## Test surface

- `FakeExternalLinkLauncher implements ExternalLinkLauncher` — records each `open(uri)` and returns a programmable `bool`. Injected via `externalLinkLauncherProvider.overrideWithValue(...)`.
- **Unit**: success → `true`; thrown error → `false` (no rethrow).
- **Widget**: tapping the notify button / suggest rows / website / privacy / terms calls `open` with the expected `Env` URL; a `false` result shows the localized SnackBar; tapping "Open-source licenses" pushes the license page (`find` the `LicensePage`).

## Contract guarantees
1. `open` never throws to the caller (failure ⇒ `false`).
2. Same form URL backs notify + both suggest controls (one form).
3. Licenses use the native page, never an external URL (repo private — Clarify Q1).
4. No analytics/telemetry fires on launch (Constitution §1.7).
