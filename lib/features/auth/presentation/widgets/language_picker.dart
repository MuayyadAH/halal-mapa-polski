import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/onboarding_state.dart';
import '../state/locale_notifier.dart';

/// Top-right corner language pill row (PL / EN / ع).
///
/// Per design Welcome B (constitution-frontend.md §III + spec FR-004).
/// Reads/writes the active locale via [localeNotifierProvider].
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key, this.isDark = false});

  /// Render with the dark-surface pill styling (used over the cocoa splash
  /// and dark onboarding backgrounds).
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(localeNotifierProvider).locale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(
          label: 'PL',
          locale: AppLocale.pl,
          isActive: active == AppLocale.pl,
          isDark: isDark,
        ),
        const SizedBox(width: 6),
        _Pill(
          label: 'EN',
          locale: AppLocale.en,
          isActive: active == AppLocale.en,
          isDark: isDark,
        ),
        const SizedBox(width: 6),
        _Pill(
          label: 'ع',
          locale: AppLocale.ar,
          isActive: active == AppLocale.ar,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _Pill extends ConsumerWidget {
  const _Pill({
    required this.label,
    required this.locale,
    required this.isActive,
    required this.isDark,
  });

  final String label;
  final AppLocale locale;
  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const activeBg = HmpColors.sand400;
    const activeFg = HmpColors.cocoa900;
    final inactiveBg =
        isDark ? HmpColors.sand400.withValues(alpha: 0.16) : HmpColors.cream100;
    final inactiveFg = isDark ? HmpColors.sand400 : HmpColors.cocoa800;

    return Semantics(
      label: 'Switch language to $label',
      button: true,
      selected: isActive,
      child: InkResponse(
        onTap: () =>
            ref.read(localeNotifierProvider.notifier).setLocale(locale),
        radius: 24,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: HmpSpacing.minTapTarget,
            minHeight: HmpSpacing.minTapTarget,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(HmpRadii.pill),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: HmpFonts.ui,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? activeFg : inactiveFg,
            ),
          ),
        ),
      ),
    );
  }
}
