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
import 'package:halal_map_polskie/features/map/presentation/state/map_selection_notifier.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/map_pin.dart';
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

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool reduceMotion,
}) async {
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
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: const MapScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets(
      'reduced motion: tree settles (no infinite pulse) and selection still '
      'works', (tester) async {
    final container = await _pump(tester, reduceMotion: true);

    expect(find.byType(MapPin), findsNWidgets(2));
    expect(find.byType(MiniCard), findsNWidgets(2));

    await tester.tap(find.byType(MapPin).first);
    // Would hang if the selected pin's pulse animation ran under reduced motion.
    await tester.pumpAndSettle();
    expect(container.read(selectedPlaceIdProvider), isNotNull);
  });

  testWidgets('animations on: pins render and selection updates',
      (tester) async {
    final container = await _pump(tester, reduceMotion: false);

    expect(find.byType(MapPin), findsNWidgets(2));

    await tester.tap(find.byType(MapPin).first);
    // Do NOT pumpAndSettle — the selected pulse repeats forever when animations
    // are on; pump a few frames instead.
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(selectedPlaceIdProvider), isNotNull);
  });
}
