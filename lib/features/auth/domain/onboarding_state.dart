import 'dart:ui' show Locale;

/// Status of the onboarding flow on the current device.
/// Derived from the presence of `onboarding_completed_at` in secure storage.
enum OnboardingStatus { notStarted, inProgress, completed }

/// MVP locales: Polish primary, English and Arabic user-selectable.
/// Turkish + Ukrainian shown in the design's Settings picker are out of scope
/// for this feature (see spec.md "Out of Scope").
enum AppLocale {
  pl,
  en,
  ar;

  Locale toFlutterLocale() => Locale(name);

  bool get isRtl => this == AppLocale.ar;

  /// The MVP languages the in-app picker offers, in display order
  /// (004-profile-screen FR-009). Turkish/Ukrainian are excluded (§5.1).
  static const pickerOrder = <AppLocale>[
    AppLocale.pl,
    AppLocale.en,
    AppLocale.ar,
  ];

  /// Maps a raw locale code (from secure storage or platform locale) to one
  /// of the three MVP locales. Unknown codes fall back to Polish per FR-005.
  static AppLocale fromCode(String? code) {
    return switch (code) {
      'pl' => AppLocale.pl,
      'en' => AppLocale.en,
      'ar' => AppLocale.ar,
      _ => AppLocale.pl,
    };
  }
}

/// Narrowed mirror of `permission_handler`'s PermissionStatus, holding only
/// the three states that affect onboarding routing (FR-010).
enum LocationPermissionStatus { notDecided, granted, denied }

/// State held by [OnboardingNotifier] during the onboarding session.
class OnboardingState {
  const OnboardingState({
    required this.status,
    required this.currentIntroPage,
  });

  /// Initial state for a returning user (onboarding already completed).
  const OnboardingState.completed()
      : status = OnboardingStatus.completed,
        currentIntroPage = 0;

  /// Initial state for a first-time user (onboarding has never been completed).
  const OnboardingState.notStarted()
      : status = OnboardingStatus.notStarted,
        currentIntroPage = 0;

  final OnboardingStatus status;

  /// 0 = Onboard 1·Find, 1 = Onboard 2·Trust, 2 = Onboard 3·Community.
  final int currentIntroPage;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentIntroPage,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      currentIntroPage: currentIntroPage ?? this.currentIntroPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          currentIntroPage == other.currentIntroPage;

  @override
  int get hashCode => Object.hash(status, currentIntroPage);
}

/// State held by [LocaleNotifier].
class LocaleState {
  const LocaleState({required this.locale});

  final AppLocale locale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocaleState &&
          runtimeType == other.runtimeType &&
          locale == other.locale;

  @override
  int get hashCode => locale.hashCode;
}
