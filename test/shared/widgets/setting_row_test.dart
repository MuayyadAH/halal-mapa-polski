import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

Widget _wrap(Widget child, {TextDirection dir = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('chevron variant renders a forward chevron (LTR)',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const SettingRow(icon: Icons.language, label: 'Język'),
    ),);
    expect(find.text('Język'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('chevron mirrors to left in RTL', (tester) async {
    await tester.pumpWidget(_wrap(
      const SettingRow(icon: Icons.language, label: 'اللغة'),
      dir: TextDirection.rtl,
    ),);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });

  testWidgets('external variant renders the external-link arrow',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const SettingRow(
        icon: Icons.public,
        label: 'Strona internetowa',
        trailing: SettingRowTrailing.external,
      ),
    ),);
    expect(find.byIcon(Icons.north_east), findsOneWidget);
  });

  testWidgets('radio reflects selected state', (tester) async {
    await tester.pumpWidget(_wrap(
      const SettingRow(
        icon: Icons.flag,
        label: 'Polski',
        trailing: SettingRowTrailing.radio,
        selected: true,
      ),
    ),);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pumpWidget(_wrap(
      const SettingRow(
        icon: Icons.flag,
        label: 'English',
        trailing: SettingRowTrailing.radio,
      ),
    ),);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('renders the optional sub-line and trailing value',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const SettingRow(
        icon: Icons.info_outline,
        label: 'O aplikacji',
        sub: 'Otwórz formularz',
        trailingValue: 'v 1.0.0',
      ),
    ),);
    expect(find.text('Otwórz formularz'), findsOneWidget);
    expect(find.text('v 1.0.0'), findsOneWidget);
  });

  testWidgets('tapping the row fires onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(_wrap(
      SettingRow(
        icon: Icons.language,
        label: 'Język',
        onTap: () => tapped++,
      ),
    ),);
    await tester.tap(find.text('Język'));
    expect(tapped, 1);
  });

  testWidgets('external row exposes a semantics hint that it opens externally',
      (tester) async {
    await tester.pumpWidget(_wrap(
      SettingRow(
        icon: Icons.public,
        label: 'Strona internetowa',
        trailing: SettingRowTrailing.external,
        onTap: () {},
      ),
    ),);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            (w.properties.hint?.toLowerCase().contains('external') ?? false),
      ),
      findsOneWidget,
    );
  });
}
