import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/data/onboarding_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;
  late SecureStorageOnboardingRepository repo;

  setUp(() {
    storage = _MockSecureStorage();
    repo = SecureStorageOnboardingRepository(storage);
  });

  group('readCompletedAt', () {
    test('returns null when storage is empty', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      expect(await repo.readCompletedAt(), isNull);
    });

    test('returns parsed UTC DateTime when storage has valid ISO-8601',
        () async {
      const iso = '2026-05-27T14:32:11.123Z';
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => iso);

      final result = await repo.readCompletedAt();
      expect(result, DateTime.parse(iso));
      expect(result!.isUtc, isTrue);
    });

    test('returns null when stored value is corrupt', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'not-a-date');

      expect(await repo.readCompletedAt(), isNull);
    });
  });

  group('markCompleted', () {
    test('persists a UTC ISO-8601 timestamp', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(
        () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenAnswer((_) async {});

      await repo.markCompleted();

      final captured = verify(
        () => storage.write(
          key: 'onboarding_completed_at',
          value: captureAny(named: 'value'),
        ),
      ).captured.single as String;

      final parsed = DateTime.parse(captured);
      expect(parsed.isUtc, isTrue);
      expect(DateTime.now().difference(parsed).inSeconds.abs(), lessThan(5));
    });

    test('is idempotent — second call does not overwrite', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '2026-01-01T00:00:00.000Z');

      await repo.markCompleted();

      verifyNever(
        () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
      );
    });
  });

  group('reset', () {
    test('deletes the timestamp key', () async {
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await repo.reset();

      verify(() => storage.delete(key: 'onboarding_completed_at')).called(1);
    });
  });
}
