import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/dio_client.dart';
import '../../storage/prefs_provider.dart';
import '../domain/category.dart';
import '../domain/place.dart';
import 'places_config.dart';

/// Loads places for the whole app. v1 reads the published Google Sheet (CSV);
/// a backend implementation can replace it later without touching callers.
/// Shared by Home and the future Map feature. See contracts/place_repository.md.
abstract class PlaceRepository {
  Future<List<Place>> fetchPlaces();
}

class GoogleSheetPlaceRepository implements PlaceRepository {
  GoogleSheetPlaceRepository(
    this._dio,
    this._prefs, {
    this.sheetId = kPlacesSheetId,
  });

  final Dio _dio;
  final SharedPreferences _prefs;
  final String sheetId;

  static const _cacheKey = 'places_cache_csv';

  @override
  Future<List<Place>> fetchPlaces() async {
    try {
      final res = await _dio.get<String>(
        placesCsvUrl(sheetId),
        options: Options(responseType: ResponseType.plain),
      );
      final csv = res.data ?? '';
      final places = parsePlacesCsv(csv);
      // Only cache a non-empty, parseable result.
      if (places.isNotEmpty) {
        await _prefs.setString(_cacheKey, csv);
      }
      return places;
    } catch (_) {
      final cached = _prefs.getString(_cacheKey);
      if (cached != null) return parsePlacesCsv(cached);
      rethrow; // → AsyncError → graceful empty/error UI with retry
    }
  }
}

/// Pure CSV → [Place] mapping. Maps by header name (tolerant of column
/// reordering) and skips rows with a blank name, unparseable coordinates, or
/// an unknown category — never throws on a bad row.
@visibleForTesting
List<Place> parsePlacesCsv(String csv) {
  if (csv.trim().isEmpty) return const [];
  // Delimiter pinned: the sheet export is always comma-separated, so v8's
  // content-based auto-detection is disabled to keep parsing deterministic.
  final rows = Csv(autoDetect: false).decode(csv);
  if (rows.isEmpty) return const [];

  final header = rows.first.map((c) => c.toString().trim()).toList();
  int col(String name) => header.indexOf(name);
  final iLng = col('Longitude');
  final iLat = col('Latitude');
  final iName = col('Name');
  final iCat = col('Category');
  final iComment = col('Comment');
  final iMawaqit = col('Mawaqit Link');

  String cell(List<dynamic> row, int i) =>
      (i >= 0 && i < row.length) ? row[i].toString().trim() : '';

  final out = <Place>[];
  for (final row in rows.skip(1)) {
    final name = cell(row, iName);
    final lat = double.tryParse(cell(row, iLat));
    final lng = double.tryParse(cell(row, iLng));
    final category = Category.parsePolish(cell(row, iCat));
    if (name.isEmpty || lat == null || lng == null || category == null) {
      continue;
    }
    out.add(
      Place.fromParts(
        name: name,
        category: category,
        lat: lat,
        lng: lng,
        comment: _nullIfBlank(cell(row, iComment)),
        mawaqitLink: _nullIfBlank(cell(row, iMawaqit)),
      ),
    );
  }
  return out;
}

String? _nullIfBlank(String s) => s.isEmpty ? null : s;

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return GoogleSheetPlaceRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

/// Shared source of place data. Home and the future Map both watch this.
final placesProvider = FutureProvider<List<Place>>((ref) {
  return ref.watch(placeRepositoryProvider).fetchPlaces();
});
