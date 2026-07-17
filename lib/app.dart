import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/state/locale_notifier.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeNotifierProvider).locale;

    return MaterialApp.router(
      title: 'Halal Map Polskie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Locked to light until dark mode is fully implemented across the widget
      // layer. The widgets are built with light brand tokens and do not yet
      // branch on brightness, so following the system setting renders a broken
      // mix (dark scaffold/nav + light content). AppTheme.dark is retained as
      // the foundation for the future dark-mode feature. See
      // constitution-frontend.md §2.10 / §6.6.
      themeMode: ThemeMode.light,
      locale: locale.toFlutterLocale(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
