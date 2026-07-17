import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/features/auth/domain/onboarding_state.dart';
import 'package:halal_map_polskie/features/auth/presentation/state/locale_notifier.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/back_header.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';
import 'package:halal_map_polskie/shared/widgets/group_card.dart';
import 'package:halal_map_polskie/shared/widgets/setting_row.dart';

/// Screen 2 — the app language picker (004-profile-screen). Lists exactly the
/// three MVP languages (pl/en/ar) as single-select radios bound to the shared
/// [localeNotifierProvider]; selecting one switches the app live (no restart)
/// and the user stays on the re-rendered screen (FR-008..FR-011). No "missing
/// language" helper.
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen>
    with TickerProviderStateMixin, EntranceController<LanguageScreen> {
  String _nativeName(AppLocalizations l10n, AppLocale locale) =>
      switch (locale) {
        AppLocale.pl => l10n.languageNamePl,
        AppLocale.en => l10n.languageNameEn,
        AppLocale.ar => l10n.languageNameAr,
      };

  String _englishName(AppLocalizations l10n, AppLocale locale) =>
      switch (locale) {
        AppLocale.pl => l10n.languageEnglishPl,
        AppLocale.en => l10n.languageEnglishEn,
        AppLocale.ar => l10n.languageEnglishAr,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(localeNotifierProvider).locale;

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
                end: 0.45,
                child: BackHeader(
                  kicker: l10n.languageKicker,
                  title: l10n.languageTitle,
                ),
              ),
              const SizedBox(height: 22),
              FadeRiseIn(
                controller: entrance,
                start: 0.12,
                end: 0.6,
                child: GroupCard(
                  sectionLabel: l10n.chooseLanguage,
                  rows: [
                    for (final locale in AppLocale.pickerOrder)
                      SettingRow(
                        label: _nativeName(l10n, locale),
                        labelFontFamily: locale.isRtl ? HmpFonts.arabic : null,
                        trailingValue: _englishName(l10n, locale),
                        valueTextDirection: TextDirection.ltr,
                        trailing: SettingRowTrailing.radio,
                        selected: locale == active,
                        onTap: () => ref
                            .read(localeNotifierProvider.notifier)
                            .setLocale(locale),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
