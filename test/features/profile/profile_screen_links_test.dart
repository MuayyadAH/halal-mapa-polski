import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/env/env.dart';

import '../../support/profile_test_harness.dart';

void main() {
  testWidgets('Notify button opens the suggest form URL', (tester) async {
    final fake = await pumpProfile(tester);
    final notify = find.text('Powiadom mnie, gdy będzie gotowe');
    await tester.ensureVisible(notify);
    await tester.tap(notify);
    await tester.pumpAndSettle();
    expect(fake.opened, [Uri.parse(Env.suggestFormUrl)]);
  });

  testWidgets('Suggest row opens the suggest form URL', (tester) async {
    final fake = await pumpProfile(tester);
    final suggest = find.text('Zaproponuj miejsce');
    await tester.ensureVisible(suggest);
    await tester.tap(suggest);
    await tester.pumpAndSettle();
    expect(fake.opened, [Uri.parse(Env.suggestFormUrl)]);
  });

  testWidgets('Privacy row opens the privacy URL', (tester) async {
    final fake = await pumpProfile(tester);
    final privacy = find.text('Polityka prywatności');
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pumpAndSettle();
    expect(fake.opened, [Uri.parse(Env.privacyUrl)]);
  });

  testWidgets('a failed launch shows a localized SnackBar', (tester) async {
    await pumpProfile(tester, linkSucceeds: false);
    final privacy = find.text('Polityka prywatności');
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pumpAndSettle();
    expect(find.text('Nie udało się otworzyć linku'), findsOneWidget);
  });
}
