# Contract: `MapsLauncher`

**Feature**: 002-home-screen
**Type**: Internal Dart service over `url_launcher` (external maps deep-link; Spec FR-015, §10)
**Location**: `lib/core/maps/maps_launcher.dart` (shared — the Map feature may reuse it)

## Interface

```dart
abstract class MapsLauncher {
  /// Opens the given place in the OS maps app (or browser fallback).
  /// Returns true if a handler was launched.
  Future<bool> openPlace(Place place);
}
```

## Concrete implementation

```dart
class UrlMapsLauncher implements MapsLauncher {
  const UrlMapsLauncher();

  @override
  Future<bool> openPlace(Place place) {
    final uri = _placeUri(place);
    // externalApplication → prefers the installed maps app; the OS falls back
    // to the browser for the https URL when no maps app is present.
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Uri _placeUri(Place place) {
    // Google Maps universal URL (api=1) — works on Android, iOS, and web.
    if (place.lat != null && place.lng != null) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}',
      );
    }
    final q = Uri.encodeComponent('${place.name} ${place.city}');
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  }
}

final mapsLauncherProvider = Provider<MapsLauncher>((ref) => const UrlMapsLauncher());
```

## Contract guarantees

1. Prefers a maps app via `LaunchMode.externalApplication`; if none is installed, the OS opens the `https://www.google.com/maps/...` URL in the default browser — graceful degradation, no crash (Spec edge case "no maps app installed").
2. Uses the place's coordinates (always present in the v1 data); a `name` query is a defensive fallback (Spec FR-015, FA-3).
3. This is a one-way OS hand-off — it makes **no** backend/API call by Home itself (Spec FR-022 holds; the launched app does its own networking).
4. The query string is always URL-encoded.

## Test surface (for `/ai1st-dev-tasks`)

`_placeUri` is `@visibleForTesting` (pure, no plugin) and unit-tested:

| Test | Assertion |
|------|-----------|
| `uri uses coordinates when present` | place with lat/lng → URL contains `query=<lat>,<lng>` |
| `uri falls back to name+city query` | place without coords → URL contains URL-encoded `name city` |
| `query is URL-encoded` | name with spaces/diacritics encodes correctly (no raw spaces) |

Widget test (TC-17) asserts a card-body tap invokes `MapsLauncher.openPlace` (via a mock launcher injected through the provider) and not the bookmark toggle.
