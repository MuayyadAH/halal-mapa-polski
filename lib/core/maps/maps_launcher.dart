import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../places/domain/place.dart';

/// Opens a place in the external maps app (or browser fallback). Stands in for
/// an in-app place detail in v1 (FR-015). Shared so the Map feature can reuse
/// it. See contracts/maps_launcher.md.
abstract class MapsLauncher {
  Future<bool> openPlace(Place place);
}

class UrlMapsLauncher implements MapsLauncher {
  const UrlMapsLauncher();

  @override
  Future<bool> openPlace(Place place) {
    // externalApplication prefers the installed maps app; the OS falls back to
    // the browser for the https URL when no maps app is present.
    return launchUrl(placeUri(place), mode: LaunchMode.externalApplication);
  }

  /// Google Maps universal URL (works on Android, iOS, web). Coordinates are
  /// present for every v1 row; the name query is a defensive fallback.
  @visibleForTesting
  static Uri placeUri(Place place) {
    final query = '${place.lat},${place.lng}';
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${Uri.encodeComponent(query)}',
    );
  }
}

final mapsLauncherProvider =
    Provider<MapsLauncher>((ref) => const UrlMapsLauncher());
