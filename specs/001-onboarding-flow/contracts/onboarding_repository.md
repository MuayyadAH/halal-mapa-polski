# Contract: `OnboardingRepository`

**Feature**: 001-onboarding-flow
**Type**: Internal Dart interface (no HTTP — feature is offline per FR-018)
**Location**: `lib/features/auth/data/onboarding_repository.dart`

## Interface

```dart
abstract class OnboardingRepository {
  /// Returns the timestamp when the user first completed onboarding,
  /// or null if onboarding has never been completed on this device.
  Future<DateTime?> readCompletedAt();

  /// Marks onboarding as completed at the current UTC time.
  /// Idempotent — calling it again does not change an existing timestamp.
  Future<void> markCompleted();

  /// Removes the completion record. Used only by test fixtures.
  /// Not exposed to UI code.
  @visibleForTesting
  Future<void> reset();
}
```

## Concrete implementation

```dart
class SecureStorageOnboardingRepository implements OnboardingRepository {
  SecureStorageOnboardingRepository(this._storage);
  final FlutterSecureStorage _storage;

  static const _key = 'onboarding_completed_at';

  @override
  Future<DateTime?> readCompletedAt() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return DateTime.tryParse(raw); // null on parse failure → treat as not completed
  }

  @override
  Future<void> markCompleted() async {
    final existing = await _storage.read(key: _key);
    if (existing != null) return; // idempotent
    await _storage.write(key: _key, value: DateTime.now().toUtc().toIso8601String());
  }

  @override
  Future<void> reset() async {
    await _storage.delete(key: _key);
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SecureStorageOnboardingRepository(ref.watch(secureStorageProvider));
});
```

## Contract guarantees

1. `readCompletedAt()` never throws — read errors return `null` (treated as "not completed").
2. `markCompleted()` is idempotent — second call is a no-op if a timestamp already exists.
3. `markCompleted()` always uses **UTC** for the stored timestamp to avoid timezone issues across devices.
4. `reset()` is test-only; production code must never call it. Enforced by the `@visibleForTesting` annotation and code-review discipline.

## Unit test surface (for `/ai1st-dev-tasks` to generate)

| Test | Assertion |
|---|---|
| `readCompletedAt returns null when storage is empty` | `await repo.readCompletedAt() == null` after fresh storage |
| `markCompleted persists a parseable ISO-8601 UTC timestamp` | Read raw value back; `DateTime.parse(raw).isUtc == true`; difference from `DateTime.now()` < 1 second |
| `markCompleted is idempotent` | Call twice; second call does not modify the stored value |
| `readCompletedAt returns null when stored value is corrupt` | Manually write `"not-a-date"`; `readCompletedAt() == null` |
| `reset clears the timestamp` | Mark complete, reset, then `readCompletedAt() == null` |

Tests use a mocked `FlutterSecureStorage` via `mocktail` (or an in-memory fake — even simpler) so they don't require platform plugins.
