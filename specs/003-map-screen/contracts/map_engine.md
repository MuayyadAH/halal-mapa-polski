# Contract — MapEngine (MapLibre abstraction)

**Location**: `lib/core/map/` (shared) · **Backs**: FR-002/FR-004/FR-005/FR-006/FR-014/FR-017 · **Source**: [research.md](../research.md) R2/R3/R15

A thin interface over `maplibre_gl` so the feature depends on an abstraction (swappable provider, fakeable in widget tests). The native map view is created by the concrete impl; the rest of the app talks to this contract.

## Interface (conceptual Dart)

```dart
class CameraTarget { final LatLng target; final double zoom; }

abstract class MapEngine {
  /// Build the map surface widget with the custom warm style (light/dark via Env).
  /// onReady fires when the style+camera are ready; onCameraIdle after movement settles.
  Widget buildMap({
    required CameraTarget initialCamera,
    required Brightness brightness,            // selects halalmap-light/dark.json
    required void Function(MapEngine) onReady,
    required void Function() onCameraIdle,
    void Function(LatLng)? onTapMap,           // tap empty map → deselect
  });

  /// Animate the camera (≈600ms ease) to a place / point.
  Future<void> flyTo(LatLng target, {double? zoom});

  /// Recenter on the user (locate-me FAB).
  Future<void> recenterOn(LatLng user, {double zoom});

  /// Project a geo coordinate to a screen point for the Flutter pin overlay (R3).
  Future<Offset> toScreenLocation(LatLng latLng);

  /// Current camera (for clustering by zoom) + viewport bounds (viewport-cull).
  double get zoom;
  LatLngBounds get visibleBounds;

  /// Show/move/hide the native user-location dot (or null to hide).
  Future<void> setUserLocation(LatLng? latLng);
}
```

> **Implemented (final):** `buildMap` takes the resolved `styleJson` (key injected by `MapConfig.loadStyle`) and a continuous `onCameraChanged(CameraSnapshot)` instead of `brightness`/`onCameraIdle`. The async `toScreenLocation` was **removed** — marker projection is done synchronously in Dart (`lib/core/map/projection.dart` `latLngToScreen`) from the live camera, for smooth tracking (see research R3). The public API is maplibre-free (plain lat/lng doubles).

## Behavior contract
- **Style**: MUST load the custom warm style (key-injected `styleJson`); MUST NOT fall back to a vanilla provider style (Constitution §II.4 / FR-002). Tile source = MapTiler (R17); key via `--dart-define`, never committed.
- **Gestures**: pan + pinch-zoom enabled; rotate + tilt **disabled** (keeps the north-up projection exact).
- **Projection**: synchronous Web-Mercator (`latLngToScreen`) driven by `onCameraChanged` so overlay pins track the map smoothly during pan/zoom (no per-marker platform round-trips).
- **Reduced motion**: `flyTo`/`recenterOn` MUST jump (no animation) when `disableAnimations` is set (caller passes the flag or the impl checks).
- **Lifecycle**: dispose the native controller with the widget.

## Test contract (R15)
- A **`FakeMapEngine`** implements this with a plain `SizedBox` surface, records `flyTo`/`recenterOn`/`setUserLocation` calls, and returns deterministic `toScreenLocation` offsets — enabling headless widget tests of pins/sheet/list/search/selection without a native map.
- Native rendering verified only in the integration test (device/emulator).
