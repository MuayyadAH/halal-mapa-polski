import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/features/auth/data/onboarding_repository.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/onboarding_notifier.dart';
import 'package:mocktail/mocktail.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late _MockOnboardingRepository repo;

  setUp(() {
    repo = _MockOnboardingRepository();
    when(() => repo.markCompleted()).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer({required bool completedAtBoot}) {
    return ProviderContainer(
      overrides: [
        initialOnboardingCompletedProvider.overrideWithValue(completedAtBoot),
        onboardingRepositoryProvider.overrideWithValue(repo),
      ],
    );
  }

  test('first-time user starts in notStarted on page 0', () {
    final container = makeContainer(completedAtBoot: false);
    final state = container.read(onboardingNotifierProvider);

    expect(state.status, OnboardingStatus.notStarted);
    expect(state.currentIntroPage, 0);
  });

  test('returning user starts in completed', () {
    final container = makeContainer(completedAtBoot: true);
    final state = container.read(onboardingNotifierProvider);

    expect(state.status, OnboardingStatus.completed);
  });

  test('enterFlow transitions notStarted -> inProgress', () {
    final container = makeContainer(completedAtBoot: false);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.enterFlow();

    expect(
      container.read(onboardingNotifierProvider).status,
      OnboardingStatus.inProgress,
    );
  });

  test('enterFlow is a no-op when already completed', () {
    final container = makeContainer(completedAtBoot: true);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.enterFlow();

    expect(
      container.read(onboardingNotifierProvider).status,
      OnboardingStatus.completed,
    );
  });

  test('advancePage increments and clamps at the last intro page', () {
    final container = makeContainer(completedAtBoot: false);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.advancePage(); // 0 -> 1
    expect(container.read(onboardingNotifierProvider).currentIntroPage, 1);
    notifier.advancePage(); // 1 -> 2
    expect(container.read(onboardingNotifierProvider).currentIntroPage, 2);
    notifier.advancePage(); // 2 -> 2 (clamped)
    expect(container.read(onboardingNotifierProvider).currentIntroPage, 2);
  });

  test('skipToEnd jumps to the last intro page', () {
    final container = makeContainer(completedAtBoot: false);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.skipToEnd();

    expect(container.read(onboardingNotifierProvider).currentIntroPage, 2);
  });

  test('setCurrentPage clamps within [0, 2]', () {
    final container = makeContainer(completedAtBoot: false);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    notifier.setCurrentPage(5);
    expect(container.read(onboardingNotifierProvider).currentIntroPage, 2);

    notifier.setCurrentPage(-1);
    expect(container.read(onboardingNotifierProvider).currentIntroPage, 0);
  });

  test('complete persists to repository and sets status to completed',
      () async {
    final container = makeContainer(completedAtBoot: false);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    await notifier.complete();

    expect(
      container.read(onboardingNotifierProvider).status,
      OnboardingStatus.completed,
    );
    verify(() => repo.markCompleted()).called(1);
  });

  test('complete is idempotent for already-completed state', () async {
    final container = makeContainer(completedAtBoot: true);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    await notifier.complete();

    verifyNever(() => repo.markCompleted());
  });
}
