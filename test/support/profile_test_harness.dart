import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/features/profile/about_screen.dart';
import 'package:halal_map_polskie/features/profile/language_screen.dart';
import 'package:halal_map_polskie/features/profile/profile_screen.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import 'fake_external_link_launcher.dart';

/// A minimal app harness for the Profile screens: a reactive locale (mirroring
/// `app.dart`) and the three nested Profile routes. The router is built once
/// (like `appRouterProvider`) so a locale change does not reset navigation.
class ProfileTestHarness extends ConsumerStatefulWidget {
  const ProfileTestHarness({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  ConsumerState<ProfileTestHarness> createState() => _ProfileTestHarnessState();
}

class _ProfileTestHarnessState extends ConsumerState<ProfileTestHarness> {
  late final GoRouter _router = GoRouter(
    initialLocation: widget.initialLocation,
    routes: [
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
        routes: [
          GoRoute(path: 'language', builder: (_, __) => const LanguageScreen()),
          GoRoute(path: 'about', builder: (_, __) => const AboutScreen()),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeNotifierProvider).locale;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale.toFlutterLocale(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

/// Pumps [ProfileTestHarness] inside a [ProviderScope] with the initial locale
/// and a [FakeExternalLinkLauncher] override. Returns the fake for assertions.
Future<FakeExternalLinkLauncher> pumpProfile(
  WidgetTester tester, {
  String initialLocation = '/profile',
  AppLocale locale = AppLocale.pl,
  bool linkSucceeds = true,
  bool reduceMotion = true,
}) async {
  // Reduced motion stops the ambient loops (which would hang pumpAndSettle) and
  // jumps the entrance controller to its final state — deterministic by default.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  // Tall viewport so the whole scrollable column is laid out (the lazy ListView
  // would otherwise leave lower groups/footer unbuilt at the default 600px).
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final fake = FakeExternalLinkLauncher(result: linkSucceeds);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialLocaleProvider.overrideWithValue(locale),
        externalLinkLauncherProvider.overrideWithValue(fake),
      ],
      child: ProfileTestHarness(initialLocation: initialLocation),
    ),
  );
  if (reduceMotion) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(); // first frame
    await tester.pump(const Duration(milliseconds: 800)); // entrance
  }
  return fake;
}
