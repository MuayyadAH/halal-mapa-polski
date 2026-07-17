import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/app.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/storage/prefs_provider.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/onboarding_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Returning user boots through splash and lands on the home shell',
    (tester) async {
      // The 5-tab shell builds every branch (incl. Home), so we stub the
      // shared place data + prefs to keep the boot hermetic (no network).
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialLocaleProvider.overrideWithValue(AppLocale.pl),
            initialOnboardingCompletedProvider.overrideWithValue(true),
            sharedPreferencesProvider.overrideWithValue(prefs),
            placesProvider.overrideWith((ref) async => <Place>[]),
          ],
          child: const App(),
        ),
      );

      // Returning users see a truncated ~1s splash, then the shell. The Home
      // mini-map runs looping ambient animations, so we advance the clock with
      // bounded pumps rather than pumpAndSettle (which never settles).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // "Strona" is the home tab label in the bottom navigation.
      expect(find.text('Strona'), findsAtLeastNWidgets(1));
    },
  );
}
