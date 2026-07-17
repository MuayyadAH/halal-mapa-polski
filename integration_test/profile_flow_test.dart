import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/env/env.dart';
import 'package:halal_map_polskie/features/profile/about_screen.dart';
import 'package:halal_map_polskie/features/profile/language_screen.dart';
import 'package:halal_map_polskie/features/profile/profile_screen.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/profile_test_harness.dart';

/// End-to-end guest Profile flow (004-profile-screen TC-7/8/9/11/12/13/14):
/// open Profil → Language → switch to Arabic (live, app-wide RTL, no restart)
/// → back → About → open an external link → open the native license page.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guest can switch language and reach About + links',
      (tester) async {
    final fake = await pumpProfile(tester); // Screen 1, Polish

    // Screen 1 renders with the Language row (Polish value).
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Polski'), findsOneWidget);

    // Open the Language picker.
    await tester.tap(find.text('Język'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageScreen), findsOneWidget);

    // Switch to Arabic → the app flips to RTL live (no restart).
    await tester.tap(find.text('العربية').first);
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(LanguageScreen))),
      TextDirection.rtl,
    );

    // Back to Screen 1 (RTL back chevron) → the Language value reflects Arabic.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('العربية'), findsWidgets);

    // Open About (Arabic label) and open the Website link.
    await tester.tap(find.text('حول التطبيق'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    final website = find.text('الموقع الإلكتروني');
    await tester.ensureVisible(website);
    await tester.tap(website);
    await tester.pumpAndSettle();
    expect(fake.opened, contains(Uri.parse(Env.websiteUrl)));

    // Open-source licenses → native license page.
    final licenses = find.text('تراخيص المصادر المفتوحة');
    await tester.ensureVisible(licenses);
    await tester.tap(licenses);
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
