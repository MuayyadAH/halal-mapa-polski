import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/profile/profile_screen.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('reduced motion renders content at final state (no hang)',
      (tester) async {
    // pumpProfile defaults to reduced motion → ambient loops never start and
    // the entrance controller jumps to its final value; pumpAndSettle returns.
    await pumpProfile(tester);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets(
      'with motion enabled the screen builds and animates without error',
      (tester) async {
    await pumpProfile(tester, reduceMotion: false);
    expect(find.text('Profil'), findsOneWidget);
    // Ambient loops are running; tear down the tree to cancel their tickers
    // before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
