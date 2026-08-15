import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/features/home/presentation/widgets/place_card.dart';
import 'package:halal_map_polskie/features/places/place_detail_screen.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows name + category badge, no rating/distance',
      (tester) async {
    final place = samplePlace(name: 'Bar Halal', category: Category.restaurant);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
        ],
        child: localizedHost(
          Center(child: PlaceCard(place: place)),
          reduceMotion: true,
        ),
      ),
    );

    expect(find.text('Bar Halal'), findsOneWidget);
    expect(find.textContaining('Restauracje'), findsOneWidget); // badge label
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.textContaining('km'), findsNothing);
  });

  testWidgets('tapping the card body opens the in-app place detail',
      (tester) async {
    final place = samplePlace(name: 'Bar Halal', category: Category.restaurant);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => [place]),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
        ],
        child: routedHost(
          Center(child: PlaceCard(place: place)),
          reduceMotion: true,
        ),
      ),
    );

    await tester.tap(find.text('Bar Halal'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailScreen), findsOneWidget);
    expect(find.text('Bar Halal'), findsOneWidget); // detail shows the name
  });

  testWidgets('tapping the bookmark toggles state (not maps)', (tester) async {
    final launcher = FakeMapsLauncher();
    final place = samplePlace(name: 'Bar Halal', category: Category.restaurant);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
          mapsLauncherProvider.overrideWithValue(launcher),
        ],
        child: localizedHost(
          Center(child: PlaceCard(place: place)),
          reduceMotion: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();

    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(launcher.opened, isEmpty);
  });
}
