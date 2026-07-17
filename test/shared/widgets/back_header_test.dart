import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/shared/widgets/back_header.dart';

void main() {
  testWidgets('renders title, and kicker when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BackHeader(title: 'Język', kicker: 'Ustawienia')),
      ),
    );
    expect(find.text('Język'), findsOneWidget);
    expect(find.text('USTAWIENIA'), findsOneWidget); // kicker is uppercased
  });

  testWidgets('shows the back tile only when showBack is true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BackHeader(title: 'Profil', showBack: false)),
      ),
    );
    expect(find.byIcon(Icons.chevron_left), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BackHeader(title: 'Język'))),
    );
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });

  testWidgets('tapping the back tile pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const Scaffold(body: BackHeader(title: 'T')),
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('T'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('T'), findsNothing);
    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('back chevron mirrors in RTL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: BackHeader(title: 'اللغة')),
        ),
      ),
    );
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
  });
}
