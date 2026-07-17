import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/screens/location_permission_screen.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/onboarding_notifier.dart';
import 'package:halal_map_polskie/features/auth/presentation/widgets/language_picker.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

const _localeTitles = <String, String>{
  'pl': 'Pozwól pokazać miejsca w pobliżu',
  'en': 'Let us show you places nearby',
  'ar': 'اسمح لنا بعرض الأماكن القريبة',
};

const _allowLabels = <String, String>{
  'pl': 'Pozwól',
  'en': 'Allow',
  'ar': 'اسمح',
};

void main() {
  for (final code in _localeTitles.keys) {
    testWidgets(
        'LocationPermissionScreen in $code shows title + LanguagePicker',
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
            home: const LocationPermissionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Localised copy.
      expect(find.text(_localeTitles[code]!), findsOneWidget);
      expect(find.text(_allowLabels[code]!), findsOneWidget);

      // FR-004 fix verification — language picker must be present on this screen.
      expect(find.byType(LanguagePicker), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  }
}
