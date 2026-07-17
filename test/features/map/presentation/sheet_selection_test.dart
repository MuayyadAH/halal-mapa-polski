import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
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

class _FakeLauncher implements MapsLauncher {
  final opened = <Place>[];

  @override
  Future<bool> openPlace(Place place) async {
    opened.add(place);
    return true;
  }
}

Place _p(String name, double lat, double lng) => Place.fromParts(
      name: name,
      category: Category.restaurant,
      lat: lat,
      lng: lng,
    );

final _places = [
  _p('Anatolia', 52.2450, 21.0000),
  _p('Bistro', 52.2150, 21.0300),
];

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  FakeMapEngine? engine,
  _FakeLauncher? launcher,
}) async {
  final container = ProviderContainer(
    overrides: [
      mapEngineProvider.overrideWithValue(engine ?? FakeMapEngine()),
      mapStyleProvider(false).overrideWith((ref) async => '{}'),
      placesProvider.overrideWith((ref) async => _places),
      locationServiceProvider.overrideWithValue(FakeLocationService(null)),
      if (launcher != null) mapsLauncherProvider.overrideWithValue(launcher),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
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
  testWidgets('renders a mini-card per place and selects on pin tap',
      (tester) async {
    final container = await _pump(tester);

    expect(find.byType(MiniCard), findsNWidgets(_places.length));
    expect(container.read(selectedPlaceIdProvider), isNull);

    await tester.tap(find.byType(MapPin).first);
    await tester.pump();
    expect(container.read(selectedPlaceIdProvider), isNotNull);
  });

  testWidgets('tapping a card selects its pin and flies the camera',
      (tester) async {
    final engine = FakeMapEngine();
    final container = await _pump(tester, engine: engine);

    await tester.tap(find.byType(MiniCard).first);
    await tester.pump();

    expect(container.read(selectedPlaceIdProvider), isNotNull);
    expect(engine.flyToCalls, isNotEmpty);
  });

  testWidgets('navigate button opens external maps', (tester) async {
    final launcher = _FakeLauncher();
    await _pump(tester, launcher: launcher);

    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pump();

    expect(launcher.opened, isNotEmpty);
  });
}
