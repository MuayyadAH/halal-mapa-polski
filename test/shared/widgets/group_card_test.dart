import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/shared/widgets/group_card.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('inserts N-1 dividers between N rows', (tester) async {
    await tester.pumpWidget(_wrap(
      const GroupCard(
        rows: [
          SettingRow(icon: Icons.language, label: 'A'),
          SettingRow(icon: Icons.info_outline, label: 'B'),
          SettingRow(icon: Icons.shield_outlined, label: 'C'),
        ],
      ),
    ),);
    expect(find.byType(SettingRow), findsNWidgets(3));
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('single row has no divider', (tester) async {
    await tester.pumpWidget(_wrap(
      const GroupCard(
        rows: [SettingRow(icon: Icons.language, label: 'Only')],
      ),
    ),);
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('renders the uppercase section label when provided',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroupCard(
        sectionLabel: 'Preferencje',
        rows: [SettingRow(icon: Icons.language, label: 'Język')],
      ),
    ),);
    expect(find.text('PREFERENCJE'), findsOneWidget);
  });
}
