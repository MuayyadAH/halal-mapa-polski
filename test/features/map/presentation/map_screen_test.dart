import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/map/map_screen.dart';
import 'package:halal_map_polskie/features/map/presentation/state/map_providers.dart';
import 'package:halal_map_polskie/features/map/presentation/widgets/map_empty_error.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../support/fake_map_engine.dart';

Widget _wrap() => const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MapScreen(),
    );

void main() {
  testWidgets('shows a loading indicator while places load', (tester) async {
    final completer = Completer<List<Place>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapEngineProvider.overrideWithValue(FakeMapEngine()),
          mapStyleProvider(false).overrideWith((ref) async => '{}'),
          placesProvider.overrideWith((ref) => completer.future),
        ],
        child: _wrap(),
      ),
    );
    await tester.pump(); // resolve style future
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(MapEmptyError), findsNothing);

    completer.complete(const []); // avoid pending timer
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty/error + retry when fetch fails with no data',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapEngineProvider.overrideWithValue(FakeMapEngine()),
          mapStyleProvider(false).overrideWith((ref) async => '{}'),
          placesProvider.overrideWith(
            (ref) => Future<List<Place>>.error(Exception('boom')),
          ),
        ],
        child: _wrap(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MapEmptyError), findsOneWidget);
  });
}
