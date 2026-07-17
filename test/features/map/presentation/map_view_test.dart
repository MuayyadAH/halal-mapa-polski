import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/cluster_bubble.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/map_pin.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/map_view.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../support/fake_map_engine.dart';

Place _place(String n, Category c, double lat, double lng) =>
    Place.fromParts(name: n, category: c, lat: lat, lng: lng);

Future<void> _pump(
  WidgetTester tester, {
  required List<Place> places,
  required FakeMapEngine engine,
  void Function(Place)? onPinTap,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapEngineProvider.overrideWithValue(engine),
        categoryFilteredProvider.overrideWithValue(places),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapView(
            initialLat: 52.2297,
            initialLng: 21.0122,
            initialZoom: 12,
            styleJson: '{}',
            onPinTap: onPinTap,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders one teardrop pin per separated place', (tester) async {
    await _pump(
      tester,
      engine: FakeMapEngine(),
      places: [
        // Near the Warsaw initial centre but in different zoom-12 cluster
        // cells, so both project on-screen as separate pins.
        _place('A', Category.restaurant, 52.2450, 21.0000),
        _place('B', Category.masjid, 52.2150, 21.0300),
      ],
    );
    expect(find.byType(MapPin), findsNWidgets(2));
    expect(find.byType(ClusterBubble), findsNothing);
  });

  testWidgets('clusters co-located places and zooms in on cluster tap',
      (tester) async {
    final engine = FakeMapEngine();
    await _pump(
      tester,
      engine: engine,
      places: [
        _place('A', Category.shop, 52.2300, 21.0120),
        _place('B', Category.shop, 52.2301, 21.0121),
      ],
    );
    expect(find.byType(ClusterBubble), findsOneWidget);
    expect(find.byType(MapPin), findsNothing);

    await tester.tap(find.byType(ClusterBubble));
    await tester.pump();
    expect(engine.flyToCalls, isNotEmpty);
  });

  testWidgets('tapping a pin invokes onPinTap with its place', (tester) async {
    Place? tapped;
    await _pump(
      tester,
      engine: FakeMapEngine(),
      places: [_place('Bistro', Category.restaurant, 52.2297, 21.0122)],
      onPinTap: (p) => tapped = p,
    );
    await tester.tap(find.byType(MapPin));
    expect(tapped?.name, 'Bistro');
  });
}
