import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/map/map_screen.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_filter_notifier.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/map_category_chips.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/mini_card.dart';
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
  Place.fromParts(
    name: 'Meczet',
    category: Category.masjid,
    lat: 52.215,
    lng: 21.03,
  ),
];

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [
      mapEngineProvider.overrideWithValue(FakeMapEngine()),
      mapStyleProvider(false).overrideWith((ref) async => '{}'),
      placesProvider.overrideWith((ref) async => _places),
      locationServiceProvider.overrideWithValue(FakeLocationService(null)),
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
  testWidgets('chip selects a single category; Wszystko clears it',
      (tester) async {
    final container = await _pump(tester);

    expect(find.byType(MiniCard), findsNWidgets(2));

    final chips = find.byType(MapCategoryChips);
    await tester
        .tap(find.descendant(of: chips, matching: find.text('Meczety')));
    await tester.pumpAndSettle();
    expect(container.read(activeCategoriesProvider), {Category.masjid});
    expect(find.byType(MiniCard), findsOneWidget);

    await tester.tap(
      find.descendant(of: chips, matching: find.text('Wszystko')),
    );
    await tester.pumpAndSettle();
    expect(container.read(activeCategoriesProvider), isEmpty);
    expect(find.byType(MiniCard), findsNWidgets(2));
  });
}
