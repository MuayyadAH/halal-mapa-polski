import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('Profile landing: all tappable controls are labeled',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpProfile(tester);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('About screen: all tappable controls are labeled',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpProfile(tester, initialLocation: '/profile/about');
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('Language screen: all tappable controls are labeled',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpProfile(tester, initialLocation: '/profile/language');
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
