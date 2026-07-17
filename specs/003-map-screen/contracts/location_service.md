# Contract — LocationService

**Location**: `lib/core/location/` (shared) · **Backs**: FR-006/FR-014/NFR-005 · **Source**: [research.md](../research.md) R5/R6

Wraps `geolocator` + the existing `PermissionsService` so location is fakeable and privacy-correct.

## Interface (conceptual Dart)

```dart
enum LocationStatus { granted, denied, serviceOff }

abstract class LocationService {
  /// Ensure permission (reuses PermissionsService.requestLocationWhenInUse).
  Future<LocationStatus> ensurePermission();

  /// One-shot current position at APPROXIMATE accuracy (Constitution §1.7).
  /// Returns null if denied / services off / timeout.
  Future<LatLng?> currentLatLng();

  /// Optional stream for the live user dot (approximate; while-in-use only).
  Stream<LatLng> watchLatLng();
}
```

Riverpod surface:
- `locationServiceProvider : Provider<LocationService>`
- `locationProvider : FutureProvider<LatLng?>` — resolves once on Map open (null on denial).
- `userLatLngProvider : Provider<LatLng?>` — derived current value for distance/dot/sort.

## Behavior contract
- **Privacy (NFR-005 / §1.7)**: request **only-while-using**; accuracy **reduced/approximate** by default; NEVER background or precise location for this feature.
- **Permission**: delegate the prompt to `PermissionsService.requestLocationWhenInUse()`; on `granted`/`limited` proceed; otherwise return null.
- **Fallback**: a null result MUST NOT crash or block — the Map renders the Warsaw overview (`warsaw`, `defaultZoom`), hides the user dot, hides distance, and hides the "Najbliższe" sort (FR-006/FR-020).
- **Locate-me (FR-014)**: if status is `denied`, `ensurePermission()` may re-prompt; if still denied, no-op with a brief, localized hint (no crash).
- **No persistence**: position is session-only, never stored or identity-linked.

## Distance helpers (same module)
- `double distanceMeters(LatLng a, LatLng b)` — haversine (pure).
- `String formatDistance(double meters, Locale locale)` — adaptive m/km, intl-localized (FR-009).

## Test contract
- A **`FakeLocationService`** returns scripted status/positions (granted+fix, denied, service-off, slow→late fix) for unit/widget/integration tests. `distanceMeters`/`formatDistance` are pure and unit-tested directly (e.g. 350 m, 1.2 km, locale decimal separator).
