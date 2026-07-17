import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/env/env.dart';
import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/back_header.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';
import 'package:halal_map_polskie/shared/widgets/group_card.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

import 'presentation/link_actions.dart';
import 'presentation/widgets/app_mark_card.dart';
import 'presentation/widgets/profile_footer.dart';
import 'presentation/widgets/suggest_place_card.dart';

/// Screen 3 — About (004-profile-screen FR-012/FR-013): app-mark card, a
/// Suggest-a-place CTA, a LINKS group (Website/Privacy/Terms → external;
/// Open-source licenses → native license page), and a footer.
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen>
    with TickerProviderStateMixin, EntranceController<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
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
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            children: [
              FadeRiseIn(
                controller: entrance,
                start: 0.0,
                end: 0.4,
                child: BackHeader(
                  kicker: l10n.aboutKicker,
                  title: l10n.aboutTitle,
                ),
              ),
              const SizedBox(height: 22),
              FadeRiseIn(
                controller: entrance,
                start: 0.08,
                end: 0.5,
                child: const AppMarkCard(),
              ),
              const SizedBox(height: HmpSpacing.sectionGap),
              FadeRiseIn(
                controller: entrance,
                start: 0.18,
                end: 0.6,
                child: SuggestPlaceCard(
                  onTap: () =>
                      openExternalLink(context, ref, Env.suggestFormUrl),
                ),
              ),
              const SizedBox(height: HmpSpacing.sectionGap),
              FadeRiseIn(
                controller: entrance,
                start: 0.28,
                end: 0.7,
                child: GroupCard(
                  sectionLabel: l10n.groupLinks,
                  rows: [
                    SettingRow(
                      icon: Icons.public,
                      label: l10n.rowWebsite,
                      trailing: SettingRowTrailing.external,
                      onTap: () =>
                          openExternalLink(context, ref, Env.websiteUrl),
                    ),
                    SettingRow(
                      icon: Icons.shield_outlined,
                      label: l10n.rowPrivacy,
                      trailing: SettingRowTrailing.external,
                      onTap: () =>
                          openExternalLink(context, ref, Env.privacyUrl),
                    ),
                    SettingRow(
                      icon: Icons.description_outlined,
                      label: l10n.rowTerms,
                      trailing: SettingRowTrailing.external,
                      onTap: () => openExternalLink(context, ref, Env.termsUrl),
                    ),
                    SettingRow(
                      icon: Icons.code,
                      label: l10n.rowLicenses,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: l10n.appTitle,
                        applicationVersion: AppInfo.version,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeRiseIn(
                controller: entrance,
                start: 0.38,
                end: 0.8,
                child: ProfileFooter(secondLine: l10n.footerCopyright),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
