import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/screens/onboard_community_screen.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

const _localeTitles = <String, String>{
  'pl': 'Zbudowane przez muzułmanów w Polsce',
  'en': 'Built by Muslims in Poland',
  'ar': 'بُني من قِبل المسلمين في بولندا',
};

const _localeStatLabels = <String, String>{
  'pl': 'miejsc zweryfikowanych w tym tygodniu',
  'en': 'places verified this week',
  'ar': 'أماكن موثّقة هذا الأسبوع',
};

void main() {
  for (final code in _localeTitles.keys) {
    testWidgets(
      'OnboardCommunityScreen renders headline + stat label in $code',
      (tester) async {
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
              home: const Scaffold(body: OnboardCommunityScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // The big "147" stat number is locale-agnostic.
        expect(find.text('147'), findsOneWidget);

        // Headline + caption switch on locale change.
        expect(find.text(_localeTitles[code]!), findsOneWidget);
        expect(find.text(_localeStatLabels[code]!), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );
  }
}
