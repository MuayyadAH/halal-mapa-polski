import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/screens/onboard_trust_screen.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

const _localeTitles = <String, String>{
  'pl': 'Zaufaj społeczności',
  'en': 'Trust the community',
  'ar': 'ثق بالمجتمع',
};

void main() {
  for (final entry in _localeTitles.entries) {
    final code = entry.key;
    final title = entry.value;

    testWidgets('OnboardTrustScreen renders headline in $code', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialLocaleProvider.overrideWithValue(AppLocale.fromCode(code)),
          ],
          child: MaterialApp(
            locale: Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: OnboardTrustScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
