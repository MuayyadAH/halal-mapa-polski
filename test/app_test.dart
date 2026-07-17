import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/app.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/onboarding_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'app is locked to the light theme regardless of device dark mode',
    (tester) async {
      // Simulate a device whose system setting is dark mode. The widget layer
      // is built with light brand tokens and does not branch on brightness, so
      // following the system setting would render a broken light/dark mix. The
      // app must therefore stay on the light theme. See app.dart.
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialLocaleProvider.overrideWithValue(AppLocale.pl),
            initialOnboardingCompletedProvider.overrideWithValue(true),
          ],
          child: const App(),
        ),
      );
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);

      // The resolved theme handed to the widget tree must be light even though
      // the simulated device is in dark mode.
      final BuildContext context = tester.element(find.byType(MaterialApp));
      expect(Theme.of(context).brightness, Brightness.light);
    },
  );
}
