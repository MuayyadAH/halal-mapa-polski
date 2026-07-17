import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/env/env.dart';
import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/back_header.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';
import 'package:halal_map_polskie/shared/widgets/group_card.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

import 'presentation/link_actions.dart';
import 'presentation/widgets/coming_soon_banner.dart';
import 'presentation/widgets/profile_footer.dart';

/// Screen 1 — the guest Profile landing (004-profile-screen): a coming-soon
/// banner paired with minimal settings (Language / Suggest / About / Privacy)
/// on one scrollable page inside the 5-tab shell. No login/account UI, no
/// Dark-mode row (FR-001..FR-007).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin, EntranceController<ProfileScreen> {
  String _activeLanguageName(AppLocalizations l10n, AppLocale locale) {
    return switch (locale) {
      AppLocale.pl => l10n.languageNamePl,
      AppLocale.en => l10n.languageNameEn,
      AppLocale.ar => l10n.languageNameAr,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeNotifierProvider).locale;

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HmpColors.homeBgGradientStart,
              HmpColors.homeBgGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 104),
            children: [
              FadeRiseIn(
                controller: entrance,
                start: 0.0,
                end: 0.40,
                child: BackHeader(title: l10n.profileTitle, showBack: false),
              ),
              const SizedBox(height: 18),
              FadeRiseIn(
                controller: entrance,
                start: 0.08,
                end: 0.50,
                child: const ComingSoonBanner(),
              ),
              const SizedBox(height: HmpSpacing.sectionGap),
              FadeRiseIn(
                controller: entrance,
                start: 0.16,
                end: 0.58,
                child: GroupCard(
                  sectionLabel: l10n.groupPreferences,
                  rows: [
                    SettingRow(
                      icon: Icons.language,
                      label: l10n.rowLanguage,
                      trailingValue: _activeLanguageName(l10n, locale),
                      onTap: () => context.push('/profile/language'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HmpSpacing.sectionGap),
              FadeRiseIn(
                controller: entrance,
                start: 0.24,
                end: 0.66,
                child: GroupCard(
                  sectionLabel: l10n.groupCommunity,
                  rows: [
                    SettingRow(
                      icon: Icons.add_location_alt_outlined,
                      label: l10n.rowSuggestPlace,
                      sub: l10n.rowSuggestPlaceSub,
                      trailing: SettingRowTrailing.external,
                      accent: true,
                      onTap: () =>
                          openExternalLink(context, ref, Env.suggestFormUrl),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HmpSpacing.sectionGap),
              FadeRiseIn(
                controller: entrance,
                start: 0.32,
                end: 0.74,
                child: GroupCard(
                  sectionLabel: l10n.groupInfo,
                  rows: [
                    SettingRow(
                      icon: Icons.info_outline,
                      label: l10n.rowAbout,
                      trailingValue: 'v ${AppInfo.version}',
                      onTap: () => context.push('/profile/about'),
                    ),
                    SettingRow(
                      icon: Icons.shield_outlined,
                      label: l10n.rowPrivacy,
                      trailing: SettingRowTrailing.external,
                      onTap: () =>
                          openExternalLink(context, ref, Env.privacyUrl),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeRiseIn(
                controller: entrance,
                start: 0.40,
                end: 0.82,
                child: ProfileFooter(secondLine: l10n.footerMission),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
