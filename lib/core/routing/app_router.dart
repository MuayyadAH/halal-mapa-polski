import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/animated_splash_screen.dart';
import '../../features/auth/presentation/screens/location_permission_screen.dart';
import '../../features/auth/presentation/screens/onboard_intro_screen.dart';
import '../../features/contribute/contribute_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/profile/about_screen.dart';
import '../../features/profile/language_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/saved/saved_screen.dart';
import 'scaffold_with_tabs.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash decides whether to route to onboarding or home.
      GoRoute(
        path: '/splash',
        builder: (_, __) => const AnimatedSplashScreen(),
      ),

      // Onboarding flow — sits outside the 5-tab shell so the bottom nav
      // is hidden during onboarding.
      GoRoute(
        path: '/onboarding/intro',
        builder: (_, __) => const OnboardIntroScreen(),
      ),
      GoRoute(
        path: '/onboarding/location',
        builder: (_, __) => const LocationPermissionScreen(),
      ),

      // Main app — 5-tab StatefulShellRoute.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithTabs(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contribute',
                builder: (_, __) => const ContributeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (_, __) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'language',
                    builder: (_, __) => const LanguageScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (_, __) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
