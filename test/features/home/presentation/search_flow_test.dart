import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/search/recent_searches_repository.dart';
import 'package:halal_map_polskie/features/home/presentation/home_screen.dart';
import 'package:halal_map_polskie/features/home/presentation/widgets/home_search_bar.dart';
import 'package:halal_map_polskie/features/places/place_detail_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('tapping the search bar opens the search overlay',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => kSamplePlaces),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
          recentSearchesRepositoryProvider
              .overrideWithValue(FakeRecentSearchesRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Anuluj'), findsNothing);
    await tester.tap(find.byType(HomeSearchBar));
    await tester.pump();
    expect(find.text('Anuluj'), findsOneWidget);
  });

  testWidgets('Anuluj closes the search overlay', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => kSamplePlaces),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
          recentSearchesRepositoryProvider
              .overrideWithValue(FakeRecentSearchesRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(HomeSearchBar));
    await tester.pump();
    await tester.tap(find.text('Anuluj'));
    await tester.pump();

    expect(find.text('Anuluj'), findsNothing);
    expect(find.byType(HomeSearchBar), findsOneWidget);
  });

  testWidgets(
      'typing filters suggestions; tapping one opens the detail + closes',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((ref) async => kSamplePlaces),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
          recentSearchesRepositoryProvider
              .overrideWithValue(FakeRecentSearchesRepository()),
        ],
        child: routedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(HomeSearchBar));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'bar');
    await tester.pump();

    expect(find.text('Bar Halal'), findsOneWidget);
    await tester.tap(find.text('Bar Halal'));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailScreen), findsOneWidget);
    expect(find.text('Anuluj'), findsNothing);
  });

  testWidgets('pull-to-refresh re-fetches places', (tester) async {
    final repo = CountingPlaceRepository(kSamplePlaces);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeRepositoryProvider.overrideWithValue(repo),
          bookmarkRepositoryProvider
              .overrideWithValue(FakeBookmarkRepository()),
          recentSearchesRepositoryProvider
              .overrideWithValue(FakeRecentSearchesRepository()),
        ],
        child: localizedHost(const HomeScreen(), reduceMotion: true),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(repo.calls, 1);

    final indicator =
        tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    await indicator.onRefresh();
    await tester.pump();

    expect(repo.calls, 2);
  });
}
