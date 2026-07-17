import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../domain/onboarding_state.dart';

/// Initial locale resolved at app bootstrap from secure storage and platform
/// locale. Overridden in `ProviderScope` from `main.dart` for production;
/// the default here is Polish so tests and dev-time hot reloads work without
/// requiring an explicit override.
final initialLocaleProvider = Provider<AppLocale>((_) => AppLocale.pl);

/// Single source of truth for the app's active locale.
///
/// The initial value comes from [initialLocaleProvider] (resolved before
/// `runApp` from secure storage + system locale fallback). User changes
/// update state synchronously and persist asynchronously to secure storage.
class LocaleNotifier extends Notifier<LocaleState> {
  static const storageKey = 'selected_locale';

  @override
  LocaleState build() {
    final initial = ref.read(initialLocaleProvider);
    return LocaleState(locale: initial);
  }

  Future<void> setLocale(AppLocale locale) async {
    if (state.locale == locale) return;
    state = LocaleState(locale: locale);
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: storageKey, value: locale.name);
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, LocaleState>(LocaleNotifier.new);
