import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/profile/language_screen.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('lists exactly three languages (pl/en/ar), no TR/UK',
      (tester) async {
    await pumpProfile(tester, initialLocation: '/profile/language');
    expect(find.byType(SettingRow), findsNWidgets(3));
    expect(find.text('Polski'), findsWidgets);
    expect(find.text('العربية'), findsWidgets);
    // Turkish / Ukrainian must not appear.
    expect(find.textContaining('Türkçe'), findsNothing);
    expect(find.textContaining('Українськ'), findsNothing);
  });

  testWidgets('exactly one language is selected initially', (tester) async {
    await pumpProfile(tester, initialLocation: '/profile/language');
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('shows no "missing language" helper or external link',
      (tester) async {
    await pumpProfile(tester, initialLocation: '/profile/language');
    expect(find.textContaining('Daj nam'), findsNothing);
    expect(find.textContaining('Let us know'), findsNothing);
    expect(find.byIcon(Icons.north_east), findsNothing);
  });

  testWidgets('selecting a language switches the app live (no restart)',
      (tester) async {
    await pumpProfile(tester, initialLocation: '/profile/language');
    // Starts in Polish: the screen title reads "Język".
    expect(find.text('Język'), findsOneWidget);

    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();

    // The whole screen re-rendered in English — the title is now "Language",
    // and we are still on the Language screen (stayed, no restart/pop).
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Język'), findsNothing);
    expect(find.byType(LanguageScreen), findsOneWidget);
  });

  testWidgets('Arabic renders the screen right-to-left', (tester) async {
    await pumpProfile(
      tester,
      initialLocation: '/profile/language',
      locale: AppLocale.ar,
    );
    final dir = Directionality.of(tester.element(find.byType(LanguageScreen)));
    expect(dir, TextDirection.rtl);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
