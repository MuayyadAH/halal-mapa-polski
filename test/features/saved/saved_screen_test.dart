import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/places/place_detail_screen.dart';
import 'package:halal_map_polskie/features/saved/saved_screen.dart';

import '../../helpers/pump_app.dart';
import '../../support/fake_location_service.dart';

final _restaurant = Place.fromParts(
  name: 'Bar Halal',
  category: Category.restaurant,
  lat: 52.23,
  lng: 21.01,
);

final _mosque = Place.fromParts(
  name: 'Meczet Centrum',
  category: Category.masjid,
  lat: 52.2,
  lng: 21.0,
);

Widget _host({required Set<String> bookmarked}) {
  return ProviderScope(
    overrides: [
      placesProvider.overrideWith((ref) async => [_restaurant, _mosque]),
      bookmarkRepositoryProvider
          .overrideWithValue(FakeBookmarkRepository(bookmarked)),
      locationServiceProvider.overrideWithValue(FakeLocationService(null)),
    ],
    child: routedHost(const SavedScreen(), reduceMotion: true),
  );
}

void main() {
  testWidgets('empty state shows guest-first copy and map CTA — no sign-in',
      (tester) async {
    await tester.pumpWidget(_host(bookmarked: {}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Nic tu jeszcze nie ma'), findsOneWidget);
    expect(find.text('Otwórz mapę'), findsOneWidget);
    expect(find.textContaining('Zaloguj'), findsNothing);
  });

  testWidgets('lists bookmarked places with count header and filter chips',
      (tester) async {
    await tester.pumpWidget(_host(bookmarked: {_restaurant.id, _mosque.id}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Bar Halal'), findsOneWidget);
    expect(find.text('Meczet Centrum'), findsOneWidget);
    expect(find.text('2 miejsca'), findsOneWidget);
    expect(find.text('Wszystko'), findsOneWidget);

    // Filter down to mosques only ("Meczety" also appears as row meta —
    // the chip renders first).
    await tester.tap(find.text('Meczety').first);
    await tester.pump();
    expect(find.text('Meczet Centrum'), findsOneWidget);
    expect(find.text('Bar Halal'), findsNothing);
  });

  testWidgets('unsave removes the row (and empty state returns for the last)',
      (tester) async {
    await tester.pumpWidget(_host(bookmarked: {_restaurant.id}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Bar Halal'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump();

    expect(find.text('Bar Halal'), findsNothing);
    expect(find.text('Nic tu jeszcze nie ma'), findsOneWidget);
  });

  testWidgets('tapping a row opens the in-app place detail', (tester) async {
    await tester.pumpWidget(_host(bookmarked: {_restaurant.id}));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Bar Halal'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailScreen), findsOneWidget);
  });
}
