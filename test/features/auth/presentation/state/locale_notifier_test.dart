import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/storage/secure_storage.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;

  setUp(() {
    storage = _MockSecureStorage();
    when(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer(AppLocale initial) {
    return ProviderContainer(
      overrides: [
        initialLocaleProvider.overrideWithValue(initial),
        secureStorageProvider.overrideWithValue(storage),
      ],
    );
  }

  test('build returns the locale from initialLocaleProvider override', () {
    final container = makeContainer(AppLocale.en);

    expect(
      container.read(localeNotifierProvider).locale,
      AppLocale.en,
    );
  });

  test('setLocale updates state and writes the chosen code to storage',
      () async {
    final container = makeContainer(AppLocale.pl);
    final notifier = container.read(localeNotifierProvider.notifier);

    await notifier.setLocale(AppLocale.ar);

    expect(container.read(localeNotifierProvider).locale, AppLocale.ar);
    verify(
      () => storage.write(
        key: 'selected_locale',
        value: 'ar',
      ),
    ).called(1);
  });

  test('setLocale is idempotent for the same value', () async {
    final container = makeContainer(AppLocale.pl);
    final notifier = container.read(localeNotifierProvider.notifier);

    await notifier.setLocale(AppLocale.pl);

    verifyNever(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    );
  });

  test('AppLocale.fromCode falls back to Polish for unknown codes', () {
    expect(AppLocale.fromCode('de'), AppLocale.pl);
    expect(AppLocale.fromCode(null), AppLocale.pl);
    expect(AppLocale.fromCode(''), AppLocale.pl);
  });

  test('AppLocale.isRtl is true only for Arabic', () {
    expect(AppLocale.pl.isRtl, isFalse);
    expect(AppLocale.en.isRtl, isFalse);
    expect(AppLocale.ar.isRtl, isTrue);
  });
}
