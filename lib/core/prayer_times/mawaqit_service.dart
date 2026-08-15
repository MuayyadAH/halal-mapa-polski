import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/dio_client.dart';
import '../location/distance.dart';
import '../location/location_service.dart';
import '../places/data/place_repository.dart';
import '../places/domain/category.dart';
import '../places/domain/place.dart';
import '../storage/prefs_provider.dart';
import 'mawaqit.dart';

/// Fetches a mosque's Mawaqit page and caches the parsed conf locally so
/// prayer times keep working offline (the yearly calendar covers the whole
/// year; a fetched conf is refreshed when its year rolls over or it lacks a
/// calendar for the requested day). "Mawaqit only" per product decision —
/// there is no on-device fallback calculation.
abstract class MawaqitRepository {
  /// Conf for [url], serving cache when it covers today. Null when the page
  /// can't be fetched or parsed and no usable cache exists. Never throws.
  Future<MawaqitConf?> confFor(String url);
}

class HttpMawaqitRepository implements MawaqitRepository {
  HttpMawaqitRepository(this._dio, this._prefs, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final Dio _dio;
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  static const _cachePrefix = 'mawaqit_conf_v1_';

  @override
  Future<MawaqitConf?> confFor(String url) async {
    final now = _now();
    final cached = _readCache(url);
    if (cached != null && _covers(cached, now)) return cached;

    try {
      final res = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {'accept': 'text/html'},
        ),
      );
      final conf = parseMawaqitHtml(res.data ?? '', now);
      if (conf != null) {
        await _prefs.setString(
          '$_cachePrefix$url',
          jsonEncode(conf.toJson()),
        );
        return conf;
      }
    } catch (_) {
      // fall through to stale cache
    }
    return cached; // possibly stale/null — better than nothing offline
  }

  /// Whether [conf] can produce times for [now]'s date (and tomorrow's fajr
  /// window that [nextPrayer] may need).
  bool _covers(MawaqitConf conf, DateTime now) =>
      conf.timesFor(now) != null &&
      conf.timesFor(now.add(const Duration(days: 1))) != null;

  MawaqitConf? _readCache(String url) {
    final raw = _prefs.getString('$_cachePrefix$url');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return null;
      return MawaqitConf.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }
}

final mawaqitRepositoryProvider = Provider<MawaqitRepository>((ref) {
  return HttpMawaqitRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

/// Conf for a single mosque's Mawaqit URL. Family-keyed by the URL string.
final mawaqitConfProvider =
    FutureProvider.family<MawaqitConf?, String>((ref, url) {
  return ref.watch(mawaqitRepositoryProvider).confFor(url);
});

/// The nearest mosque that has a Mawaqit link (Warsaw-centre fallback when
/// the device is not located). Powers the Home prayer pill. Null while places
/// load or when no mosque carries a link.
final nearestMawaqitMosqueProvider = Provider<Place?>((ref) {
  final places = ref.watch(placesProvider).value;
  if (places == null) return null;
  final user = ref.watch(userLatLngProvider);
  final lat = user?.lat ?? kWarsawLat;
  final lng = user?.lng ?? kWarsawLng;

  Place? nearest;
  double best = double.infinity;
  for (final p in places) {
    if (p.category != Category.masjid) continue;
    final link = p.mawaqitLink;
    if (link == null || link.isEmpty) continue;
    final d = distanceMeters(lat, lng, p.lat, p.lng);
    if (d < best) {
      best = d;
      nearest = p;
    }
  }
  return nearest;
});
