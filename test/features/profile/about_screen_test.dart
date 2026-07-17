import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/env/env.dart';
import 'package:halal_map_polskie/features/profile/presentation/widgets/app_mark_card.dart';
import 'package:halal_map_polskie/features/profile/presentation/widgets/suggest_place_card.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('renders the app-mark card, suggest card, and LINKS group',
      (tester) async {
    await pumpProfile(tester, initialLocation: '/profile/about');
    expect(find.byType(AppMarkCard), findsOneWidget);
    expect(find.byType(SuggestPlaceCard), findsOneWidget);
    expect(find.text('Halal Map Polskie'), findsWidgets);
    expect(find.textContaining('Wersja 1.0.0'), findsOneWidget);
    expect(find.text('Strona internetowa'), findsOneWidget);
    expect(find.text('Regulamin'), findsOneWidget);
    expect(find.text('Licencje open-source'), findsOneWidget);
  });

  testWidgets('Website / Terms rows open their external URLs', (tester) async {
    final fake = await pumpProfile(tester, initialLocation: '/profile/about');

    final website = find.text('Strona internetowa');
    await tester.ensureVisible(website);
    await tester.tap(website);
    await tester.pumpAndSettle();

    final terms = find.text('Regulamin');
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();

    expect(fake.opened, [
      Uri.parse(Env.websiteUrl),
      Uri.parse(Env.termsUrl),
    ]);
  });

  testWidgets('Open-source licenses opens the native license page (no URL)',
      (tester) async {
    final fake = await pumpProfile(tester, initialLocation: '/profile/about');
    final licenses = find.text('Licencje open-source');
    await tester.ensureVisible(licenses);
    await tester.tap(licenses);
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
    expect(fake.opened, isEmpty); // native page, not an external launch
  });
}
