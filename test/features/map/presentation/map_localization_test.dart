import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/map/map_screen.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_map_engine.dart';

final _places = [
  Place.fromParts(
    name: 'Karim',
    category: Category.restaurant,
    lat: 52.245,
    lng: 21.0,
  ),
];

Future<void> _pump(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapEngineProvider.overrideWithValue(FakeMapEngine()),
        mapStyleProvider(false).overrideWith((ref) async => '{}'),
        placesProvider.overrideWith((ref) async => _places),
        locationServiceProvider.overrideWithValue(FakeLocationService(null)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MapScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Polish (canonical) search hint', (tester) async {
    await _pump(tester, const Locale('pl'));
    expect(find.text('Szukaj na mapie…'), findsOneWidget);
  });

  testWidgets('English search hint', (tester) async {
    await _pump(tester, const Locale('en'));
    expect(find.text('Search on the map…'), findsOneWidget);
  });

  testWidgets('Arabic renders right-to-left', (tester) async {
    await _pump(tester, const Locale('ar'));
    expect(find.text('ابحث على الخريطة…'), findsOneWidget);
    final dir = Directionality.of(tester.element(find.byType(MapScreen)));
    expect(dir, TextDirection.rtl);
  });
}
