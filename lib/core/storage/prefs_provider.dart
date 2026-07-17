import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Synchronous access to [SharedPreferences].
///
/// The instance is obtained once in `main()` (async) and injected via a
/// `ProviderScope` override, so feature code can read prefs synchronously
/// without any async-init ceremony. Used for non-sensitive data only
/// (bookmarks, the places fetch cache) — never tokens/PII (constitution §2).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() after '
    'SharedPreferences.getInstance()',
  ),
);
