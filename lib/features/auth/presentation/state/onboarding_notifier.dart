import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/onboarding_repository.dart';
import '../../domain/onboarding_state.dart';

/// Whether onboarding has been completed on this device. Resolved at app
/// bootstrap from secure storage; overridden in `ProviderScope` from
/// `main.dart` for production. Default `false` keeps tests and hot reloads
/// working without an explicit override.
final initialOnboardingCompletedProvider = Provider<bool>((_) => false);

/// Drives onboarding navigation state and persists completion.
class OnboardingNotifier extends Notifier<OnboardingState> {
  static const _lastIntroPage = 2;

  @override
  OnboardingState build() {
    final completed = ref.read(initialOnboardingCompletedProvider);
    return completed
        ? const OnboardingState.completed()
        : const OnboardingState.notStarted();
  }

  /// Called when the user enters the first onboarding screen.
  void enterFlow() {
    if (state.status == OnboardingStatus.completed) return;
    state = state.copyWith(status: OnboardingStatus.inProgress);
  }

  /// Advances the current intro page index, clamped to the last page.
  void advancePage() {
    if (state.status == OnboardingStatus.completed) return;
    final next = (state.currentIntroPage + 1).clamp(0, _lastIntroPage);
    state = state.copyWith(currentIntroPage: next);
  }

  /// Sets the current intro page directly (e.g., when the user swipes the PageView).
  void setCurrentPage(int page) {
    if (state.status == OnboardingStatus.completed) return;
    final clamped = page.clamp(0, _lastIntroPage);
    if (clamped == state.currentIntroPage) return;
    state = state.copyWith(currentIntroPage: clamped);
  }

  /// Jumps directly to the last intro page (triggered by the "Pomiń" link).
  void skipToEnd() {
    if (state.status == OnboardingStatus.completed) return;
    state = state.copyWith(currentIntroPage: _lastIntroPage);
  }

  /// Marks onboarding as completed and persists the timestamp. Called when
  /// the user first reaches the Map via any path.
  Future<void> complete() async {
    if (state.status == OnboardingStatus.completed) return;
    state = state.copyWith(status: OnboardingStatus.completed);
    await ref.read(onboardingRepositoryProvider).markCompleted();
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
