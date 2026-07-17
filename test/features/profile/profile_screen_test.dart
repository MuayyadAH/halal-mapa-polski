import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/profile/profile_screen.dart';
import 'package:halal_map_polskie/shared/widgets/group_card.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('renders the three settings groups and no Dark-mode row',
      (tester) async {
    await pumpProfile(tester);

    // Section labels for all three groups (uppercased by GroupCard).
    expect(find.text('PREFERENCJE'), findsOneWidget);
    expect(find.text('SPOŁECZNOŚĆ'), findsOneWidget);
    expect(find.text('INFORMACJE'), findsOneWidget);
    expect(find.byType(GroupCard), findsNWidgets(3));

    // Profile title (tab root, no back chevron).
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);

    // Preferences group has exactly one row (Language) — no Dark-mode row.
    expect(find.text('Język'), findsOneWidget);
    expect(find.textContaining('ciemny'), findsNothing); // "Tryb ciemny"
    expect(find.textContaining('Dark'), findsNothing);
  });

  testWidgets('Language row shows the active language as its value',
      (tester) async {
    await pumpProfile(tester, locale: AppLocale.en);
    // With English active, the row value is the English native name.
    expect(find.widgetWithText(SettingRow, 'English'), findsWidgets);
  });

  testWidgets('shows no login / account UI (guest only)', (tester) async {
    await pumpProfile(tester);
    expect(find.byType(TextField), findsNothing); // no sign-in form
    expect(find.textContaining('@'), findsNothing); // no email field/label
  });

  testWidgets('renders the footer', (tester) async {
    await pumpProfile(tester);
    expect(
      find.textContaining('społeczności muzułmańskiej'),
      findsOneWidget,
    );
  });

  testWidgets('renders inside a tab-less standalone scaffold (no own dock)',
      (tester) async {
    await pumpProfile(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });
}
