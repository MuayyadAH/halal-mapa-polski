import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/storage/prefs_provider.dart';
import 'package:halal_map_polskie/features/home/presentation/home_screen.dart';
import 'package:halal_map_polskie/features/home/presentation/widgets/place_card.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Place _p(String n, Category c) =>
    Place.fromParts(name: n, category: c, lat: 1, lng: 2);

final _places = [
  _p('Centrum Kultury Islamu', Category.masjid),
  _p('Bar Halal', Category.restaurant),
  _p('Sklep Orient', Category.shop),
  _p('Meczet Gdańsk', Category.masjid),
];

Widget _app(SharedPreferences prefs) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/map',
        builder: (_, __) => const Scaffold(body: Center(child: Text('MAP'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      placesProvider.overrideWith((ref) async => _places),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pl'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open Home → filter → bookmark persists → open Map',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_app(prefs));
    await tester.pump();
    await tester.pump();

    // Cards render from the (mocked) live source.
    expect(find.byType(PlaceCard), findsWidgets);

    // Filter to masjids.
    await tester.tap(find.text('Meczety'));
    await tester.pump();
    expect(find.byType(PlaceCard), findsWidgets);

    // Bookmark the first card.
    await tester.tap(find.byIcon(Icons.bookmark_border).first);
    await tester.pump();
    expect(prefs.getStringList('bookmarked_place_ids'), isNotEmpty);

    // Simulate a restart over the same prefs → bookmark survives.
    await tester.pumpWidget(_app(prefs));
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.bookmark), findsWidgets);

    // Open the map from the mini-map.
    await tester.tap(find.text('Otwórz mapę ›'));
    await tester.pumpAndSettle();
    expect(find.text('MAP'), findsOneWidget);
  });
}
