import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/storage/secure_storage.dart';

/// Persists the "onboarding completed" timestamp.
///
/// The value itself (a UTC ISO-8601 string) is informational — only the
/// presence or absence of the key matters for routing decisions.
abstract class OnboardingRepository {
  Future<DateTime?> readCompletedAt();

  Future<void> markCompleted();

  @visibleForTesting
  Future<void> reset();
}

class SecureStorageOnboardingRepository implements OnboardingRepository {
  SecureStorageOnboardingRepository(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'onboarding_completed_at';

  @override
  Future<DateTime?> readCompletedAt() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> markCompleted() async {
    final existing = await _storage.read(key: _key);
    if (existing != null) return;
    await _storage.write(
      key: _key,
      value: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> reset() async {
    await _storage.delete(key: _key);
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SecureStorageOnboardingRepository(ref.watch(secureStorageProvider));
});
