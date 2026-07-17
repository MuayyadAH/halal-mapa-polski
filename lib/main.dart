import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/prefs_provider.dart';
import 'features/auth/domain/onboarding_state.dart';
import 'features/auth/presentation/state/locale_notifier.dart';
import 'features/auth/presentation/state/onboarding_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read persisted preferences synchronously before the first frame so the
  // router and locale start in the correct state without a flicker.
  const storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final storedLocale = await storage.read(key: LocaleNotifier.storageKey);
  final storedCompletedAt = await storage.read(key: 'onboarding_completed_at');

  // Non-sensitive prefs (bookmarks, places cache) — loaded once and injected
  // so feature code reads them synchronously.
  final prefs = await SharedPreferences.getInstance();

  final initialLocale = storedLocale != null
      ? AppLocale.fromCode(storedLocale)
      : _systemLocaleOrPolish();

  runApp(
    ProviderScope(
      overrides: [
        initialLocaleProvider.overrideWithValue(initialLocale),
        initialOnboardingCompletedProvider
            .overrideWithValue(storedCompletedAt != null),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}

AppLocale _systemLocaleOrPolish() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return AppLocale.fromCode(code);
}
