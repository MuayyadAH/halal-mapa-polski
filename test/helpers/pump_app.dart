import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/search/recent_searches_repository.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// In-memory bookmark store for widget tests.
class FakeBookmarkRepository implements BookmarkRepository {
  FakeBookmarkRepository([Set<String>? initial]) : _set = {...?initial};
  Set<String> _set;

  @override
  Set<String> load() => _set;

  @override
  Future<void> save(Set<String> placeIds) async => _set = {...placeIds};
}

/// Records the places it was asked to open (no real url_launcher).
class FakeMapsLauncher implements MapsLauncher {
  final List<Place> opened = [];

  @override
  Future<bool> openPlace(Place place) async {
    opened.add(place);
    return true;
  }
}

/// In-memory recent-searches store for widget tests.
class FakeRecentSearchesRepository implements RecentSearchesRepository {
  FakeRecentSearchesRepository([List<String>? initial]) : _list = [...?initial];
  List<String> _list;

  @override
  List<String> load() => _list;

  @override
  Future<void> save(List<String> queries) async => _list = [...queries];
}

/// Counts fetch calls — for the pull-to-refresh test.
class CountingPlaceRepository implements PlaceRepository {
  CountingPlaceRepository(this.data);
  final List<Place> data;
  int calls = 0;

  @override
  Future<List<Place>> fetchPlaces() async {
    calls++;
    return data;
  }
}

Place samplePlace({
  String name = 'Test Meczet',
  Category category = Category.masjid,
  double lat = 52.23,
  double lng = 21.01,
}) =>
    Place.fromParts(name: name, category: category, lat: lat, lng: lng);

final List<Place> kSamplePlaces = <Place>[
  samplePlace(name: 'Centrum Kultury Islamu'),
  samplePlace(
    name: 'Bar Halal',
    category: Category.restaurant,
    lat: 50.06,
    lng: 19.94,
  ),
  samplePlace(
    name: 'Sklep Orient',
    category: Category.shop,
    lat: 51.1,
    lng: 17.03,
  ),
  samplePlace(
    name: 'Mizar',
    category: Category.cemetery,
    lat: 53.17,
    lng: 23.81,
  ),
  samplePlace(name: 'Meczet Gdańsk', lat: 54.39, lng: 18.57),
];

/// Wraps [child] in a localized MaterialApp (no ProviderScope — tests supply
/// their own inline so override typing stays inference-based, matching the
/// project's existing test style).
Widget localizedHost(
  Widget child, {
  Locale locale = const Locale('pl'),
  bool reduceMotion = false,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: child),
    ),
  );
}
