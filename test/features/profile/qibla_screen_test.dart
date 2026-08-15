import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/qibla/qibla.dart';
import 'package:halal_map_polskie/features/profile/qibla_screen.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../support/fake_location_service.dart';

class _FakeCompass implements CompassService {
  _FakeCompass(this.heading);
  final double? heading;

  @override
  Stream<double?> headings() => Stream<double?>.value(heading);
}

Widget _host({double? heading, ({double lat, double lng})? position}) {
  return ProviderScope(
    overrides: [
      compassServiceProvider.overrideWithValue(_FakeCompass(heading)),
      locationServiceProvider.overrideWithValue(FakeLocationService(position)),
    ],
    child: const MaterialApp(
      locale: Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: QiblaScreen(),
    ),
  );
}

void main() {
  group('qiblaBearing', () {
    test('from Warsaw points south-east (~136°)', () {
      final b = qiblaBearing(kWarsawLat, kWarsawLng);
      expect(b, greaterThan(125));
      expect(b, lessThan(150));
    });

    test('from just north of the Kaaba points due south', () {
      final b = qiblaBearing(kKaabaLat + 5, kKaabaLng);
      expect(b, closeTo(180, 0.5));
    });

    test('normalizes into 0..360', () {
      // Jakarta — the qibla points north-west (~295°).
      final b = qiblaBearing(-6.2, 106.8);
      expect(b, greaterThan(270));
      expect(b, lessThan(320));
    });
  });

  testWidgets('shows bearing, distance and no-compass note without a sensor',
      (tester) async {
    await tester.pumpWidget(_host(heading: null));
    await tester.pump();

    expect(find.text('Qibla'), findsOneWidget);
    expect(find.textContaining('° od północy'), findsOneWidget);
    expect(find.textContaining('km do Mekki'), findsOneWidget);
    expect(find.textContaining('Brak czujnika kompasu'), findsOneWidget);
  });

  testWidgets('facing the qibla shows the aligned state', (tester) async {
    final bearing = qiblaBearing(kWarsawLat, kWarsawLng);
    await tester.pumpWidget(_host(heading: bearing));
    await tester.pump();
    await tester.pump();

    expect(find.text('Skierowane na Qiblę'), findsOneWidget);
    expect(find.textContaining('Brak czujnika'), findsNothing);
  });
}
