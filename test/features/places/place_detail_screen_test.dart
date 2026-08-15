import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/prayer_times/mawaqit.dart';
import 'package:halal_map_polskie/core/prayer_times/mawaqit_service.dart';
import 'package:halal_map_polskie/features/places/place_detail_screen.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../helpers/pump_app.dart';
import '../../support/fake_location_service.dart';

final _place = Place.fromParts(
  name: 'Bar Halal',
  category: Category.restaurant,
  lat: 52.23,
  lng: 21.01,
  comment: 'Świetny kebab przy dworcu',
);

final _mosque = Place.fromParts(
  name: 'Meczet Centrum',
  category: Category.masjid,
  lat: 52.2,
  lng: 21.0,
  mawaqitLink: 'https://mawaqit.net/pl/meczet-centrum',
);

Widget _host(
  String placeId, {
  List<Place>? places,
  MapsLauncher? launcher,
}) {
  return ProviderScope(
    overrides: [
      placesProvider.overrideWith((ref) async => places ?? [_place, _mosque]),
      bookmarkRepositoryProvider.overrideWithValue(FakeBookmarkRepository()),
      locationServiceProvider.overrideWithValue(FakeLocationService(null)),
      if (launcher != null) mapsLauncherProvider.overrideWithValue(launcher),
    ],
    child: MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PlaceDetailScreen(placeId: placeId),
    ),
  );
}

void main() {
  testWidgets('shows name, category kicker, community chip and comment quote',
      (tester) async {
    await tester.pumpWidget(_host(_place.id));
    await tester.pump();
    await tester.pump();

    expect(find.text('Bar Halal'), findsOneWidget);
    expect(find.text('RESTAURACJE'), findsOneWidget);
    expect(find.text('Zweryfikowane przez społeczność'), findsOneWidget);
    expect(find.text('Świetny kebab przy dworcu'), findsOneWidget);
  });

  testWidgets('navigate button opens the place in external maps',
      (tester) async {
    final launcher = FakeMapsLauncher();
    await tester.pumpWidget(_host(_place.id, launcher: launcher));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Nawiguj'));
    await tester.pump();
    expect(launcher.opened.single.id, _place.id);
  });

  testWidgets('action-bar bookmark toggles the saved state', (tester) async {
    await tester.pumpWidget(_host(_place.id));
    await tester.pump();
    await tester.pump();

    // Hero + action bar each render a bookmark control; both start unsaved.
    expect(find.byIcon(Icons.bookmark_border), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.bookmark_border).last);
    await tester.pump();
    expect(find.byIcon(Icons.bookmark), findsNWidgets(2));
  });

  testWidgets('mosque with a Mawaqit link shows in-app prayer times',
      (tester) async {
    final today = DateTime.now();
    final conf = MawaqitConf(
      fetchedOn: DateTime(today.year, today.month, today.day),
      mosqueName: 'Meczet Centrum',
      todayTimes: const ['04:00', '12:45', '16:30', '20:15', '22:00'],
      jumua: '13:30',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => [_place, _mosque]),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
          locationServiceProvider.overrideWithValue(FakeLocationService(null)),
          mawaqitConfProvider(_mosque.mawaqitLink!)
              .overrideWith((ref) async => conf),
        ],
        child: MaterialApp(
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlaceDetailScreen(placeId: _mosque.id),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Godziny modlitw'), findsOneWidget);
    expect(find.text('12:45'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);
    expect(find.textContaining("Jumu'ah"), findsOneWidget);
  });

  testWidgets('unknown id renders the not-found state', (tester) async {
    await tester.pumpWidget(_host('missing|0|0'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Nie znaleziono miejsca'), findsOneWidget);
  });
}
