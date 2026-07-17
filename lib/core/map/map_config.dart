import 'package:flutter/services.dart' show rootBundle;

import '../env/env.dart';

/// Resolves the custom warm MapLibre style for the Map feature.
///
/// The style JSONs live in assets with a `{key}` placeholder for the MapTiler
/// tiles key; [loadStyle] reads the asset and injects [Env.mapTilesKey]
/// (passed via `--dart-define=MAP_TILES_KEY=...`, never committed — §2).
abstract final class MapConfig {
  static String _asset({required bool isDark}) => isDark
      ? 'assets/map_styles/halalmap-dark.json'
      : 'assets/map_styles/halalmap-light.json';

  /// Full style JSON string ready for `MapLibreMap.styleString`, with the
  /// MapTiler key injected. Returns the unsubstituted style (warm background
  /// only, no tiles) when no key is configured — graceful, never throws.
  static Future<String> loadStyle({required bool isDark}) async {
    final raw = await rootBundle.loadString(_asset(isDark: isDark));
    return raw.replaceAll('{key}', Env.mapTilesKey);
  }

  const MapConfig._();
}
