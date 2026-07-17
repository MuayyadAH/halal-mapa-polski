import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/features/home/presentation/widgets/mini_map.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the localized place count and opens the map on tap',
      (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: localizedHost(
          MiniMap(placeCount: 343, onOpenMap: () => opened++),
          reduceMotion: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('343'), findsOneWidget);

    await tester.tap(find.byType(MiniMap));
    await tester.pump();
    expect(opened, 1);
  });

  testWidgets('renders statically under reduced motion (settles)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: localizedHost(
          MiniMap(placeCount: 5, onOpenMap: () {}),
          reduceMotion: true,
        ),
      ),
    );
    // If ambient controllers were running, pumpAndSettle would time out.
    await tester.pumpAndSettle();
    expect(find.byType(MiniMap), findsOneWidget);
  });
}
