import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/screens/animated_splash_screen.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/onboarding_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

void main() {
  for (final code in const ['pl', 'en', 'ar']) {
    testWidgets('AnimatedSplashScreen mounts in $code without crashing',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialLocaleProvider.overrideWithValue(AppLocale.fromCode(code)),
            initialOnboardingCompletedProvider.overrideWithValue(false),
          ],
          child: MaterialApp(
            locale: Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // The real splash calls `context.go(...)` once its animation
            // completes; without a router that would throw. We deliberately
            // pump only once (single frame) so the post-frame nav callback
            // doesn't fire, and we just verify mounting + rendering.
            home: const AnimatedSplashScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(AnimatedSplashScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
