import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/search/recent_searches.dart';
import 'package:halal_map_polskie/core/storage/prefs_provider.dart';
import 'package:halal_map_polskie/features/map/map_screen.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_filter_notifier.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_selection_notifier.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/map_search_overlay.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_map_engine.dart';

final _places = [
  Place.fromParts(
    name: 'Meczet Łazienki',
    category: Category.masjid,
    lat: 52.215,
    lng: 21.03,
  ),
  Place.fromParts(
    name: 'Bistro Karim',
    category: Category.restaurant,
    lat: 52.245,
    lng: 21.0,
  ),
];

Future<ProviderContainer> _pump(
  WidgetTester tester,
  FakeMapEngine engine,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      mapEngineProvider.overrideWithValue(engine),
      mapStyleProvider(false).overrideWith((ref) async => '{}'),
      placesProvider.overrideWith((ref) async => _places),
      locationServiceProvider.overrideWithValue(FakeLocationService(null)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MapScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets(
      'search finds across the full dataset (accent-insensitive) and a '
      'filtered-out result clears the filter, selects + flies', (tester) async {
    final engine = FakeMapEngine();
    final container = await _pump(tester, engine);

    // Start filtered to mosques only — the restaurant is filtered out.
    container
        .read(activeCategoriesProvider.notifier)
        .selectOnly(Category.masjid);
    await tester.pumpAndSettle();

    // Open the search overlay.
    await tester.tap(find.text('Szukaj na mapie…'));
    await tester.pumpAndSettle();
    expect(find.byType(MapSearchOverlay), findsOneWidget);

    // Accent-insensitive match across ALL places (incl. the filtered-out one).
    await tester.enterText(find.byType(TextField), 'karim');
    await tester.pumpAndSettle();
    expect(find.text('Bistro Karim'), findsOneWidget);

    await tester.tap(find.text('Bistro Karim'));
    // Not pumpAndSettle: the now-selected pin pulses forever (animations on).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Overlay closed, filter cleared so the pin is visible, selected + flown.
    expect(find.byType(MapSearchOverlay), findsNothing);
    expect(container.read(activeCategoriesProvider), isEmpty);
    expect(container.read(selectedPlaceIdProvider), isNotNull);
    expect(engine.flyToCalls, isNotEmpty);

    // The query was recorded as a recent (unified store).
    expect(container.read(recentSearchesProvider), isNotEmpty);
  });
}
