import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/features/home/presentation/home_screen.dart';
import 'package:halal_map_polskie/features/home/presentation/widgets/home_error_state.dart';
import 'package:halal_map_polskie/features/home/presentation/widgets/home_skeletons.dart';
import 'package:halal_map_polskie/features/home/presentation/widgets/place_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows skeletons while loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) => Completer<List<Place>>().future),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    expect(find.byType(FeaturedSkeletonRow), findsOneWidget);
  });

  testWidgets('shows error state with retry when the fetch fails',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async {
            throw Exception('boom');
          }),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    // Riverpod auto-retries failed providers, so do not pumpAndSettle here.
    await tester.pump(); // build (loading)
    await tester.pump(); // future rejects → hasError
    tester.takeException();
    expect(find.byType(HomeErrorState), findsOneWidget);
  });

  testWidgets('renders featured cards from loaded data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => kSamplePlaces),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(PlaceCard), findsWidgets);
  });

  testWidgets('category chip filters the featured row to masjids',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => kSamplePlaces),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Meczety'));
    await tester.pump();

    final cards = tester.widgetList<PlaceCard>(find.byType(PlaceCard));
    expect(cards, isNotEmpty);
    expect(
      cards.every(
        (PlaceCard c) =>
            c.place.name == 'Centrum Kultury Islamu' ||
            c.place.name == 'Meczet Gdańsk',
      ),
      isTrue,
    );
  });
}
