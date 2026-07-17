import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Warsaw city centre — the default camera target when device location is
/// unavailable (003-map-screen R5/FR-006).
const double kWarsawLat = 52.2297;
const double kWarsawLng = 21.0122;
const double kDefaultZoom = 12.0;

const double _earthRadiusM = 6371000.0;

/// Great-circle distance in metres between two lat/lng points (haversine).
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _deg2rad(lat2 - lat1);
  final dLng = _deg2rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) *
          math.cos(_deg2rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _earthRadiusM * c;
}

double _deg2rad(double deg) => deg * (math.pi / 180.0);

/// Adaptive, locale-formatted distance (003-map-screen FR-009; Clarify
/// 2026-05-31): whole tens of metres under 1 km ("350 m"); kilometres with one
/// decimal at/above 1 km ("1,2 km" in pl — `intl` localizes the separator).
String formatDistance(double meters, String localeName) {
  if (meters < 1000) {
    final rounded = (meters / 10).round() * 10;
    return '$rounded m';
  }
  final km = meters / 1000.0;
  final fmt = NumberFormat('#0.0', localeName);
  return '${fmt.format(km)} km';
}
