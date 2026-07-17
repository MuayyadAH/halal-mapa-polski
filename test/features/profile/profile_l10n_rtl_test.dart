import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/profile/about_screen.dart';
import 'package:halal_map_polskie/features/profile/profile_screen.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('Profile title is Polish by default', (tester) async {
    await pumpProfile(tester);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('Profile title localizes to English', (tester) async {
    await pumpProfile(tester, locale: AppLocale.en);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Profile title localizes to Arabic', (tester) async {
    await pumpProfile(tester, locale: AppLocale.ar);
    expect(find.text('الملف الشخصي'), findsOneWidget);
  });

  testWidgets('Arabic mirrors the Profile screen to RTL', (tester) async {
    await pumpProfile(tester, locale: AppLocale.ar);
    final dir = Directionality.of(tester.element(find.byType(ProfileScreen)));
    expect(dir, TextDirection.rtl);
  });

  testWidgets('About screen localizes and mirrors in Arabic', (tester) async {
    await pumpProfile(
      tester,
      initialLocation: '/profile/about',
      locale: AppLocale.ar,
    );
    final dir = Directionality.of(tester.element(find.byType(AboutScreen)));
    expect(dir, TextDirection.rtl);
    expect(find.text('روابط'), findsOneWidget); // "Links" group label (ar)
  });
}
