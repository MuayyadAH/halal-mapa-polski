import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/map/map_screen.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/locate_me_fab.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/user_dot.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_map_engine.dart';

Widget _wrap() => const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MapScreen(),
    );

Future<void> _pump(
  WidgetTester tester, {
  required FakeMapEngine engine,
  required LatLng? location,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapEngineProvider.overrideWithValue(engine),
        mapStyleProvider(false).overrideWith((ref) async => '{}'),
        placesProvider.overrideWith((ref) async => const <Place>[]),
        locationServiceProvider
            .overrideWithValue(FakeLocationService(location)),
      ],
      child: _wrap(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('granted: shows the user dot and locate-me recenters',
      (tester) async {
    final engine = FakeMapEngine();
    await _pump(tester, engine: engine, location: (lat: 52.23, lng: 21.01));

    expect(find.byType(UserDot), findsOneWidget);

    await tester.tap(find.byType(LocateMeFab));
    await tester.pump();
    expect(engine.recenterCalls, isNotEmpty);
  });

  testWidgets('denied: no user dot, locate-me does not crash', (tester) async {
    final engine = FakeMapEngine();
    await _pump(tester, engine: engine, location: null);

    expect(find.byType(UserDot), findsNothing);

    await tester.tap(find.byType(LocateMeFab));
    await tester.pump();
    // No fix → recenter not called; the app must not crash.
    expect(engine.recenterCalls, isEmpty);
  });
}
