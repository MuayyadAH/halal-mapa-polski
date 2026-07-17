import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

import 'pressable_scale.dart';

/// Trailing affordance for a [SettingRow].
enum SettingRowTrailing {
  /// Directional chevron (navigates to a sub-screen).
  chevron,

  /// 45° external-link arrow (opens an external destination).
  external,

  /// Single-select radio (selected = green check / unselected = hollow ring).
  radio,

  /// No trailing affordance.
  none,
}

/// A settings list row used across the Profile screens (004-profile-screen
/// FR-017): a 36dp rounded icon tile, a label, an optional sub-line, an
/// optional trailing value, and a trailing affordance. Styled from tokens only.
/// External rows announce that they open an external destination (a11y FR-020).
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    this.icon,
    required this.label,
    this.sub,
    this.trailingValue,
    this.trailing = SettingRowTrailing.chevron,
    this.accent = false,
    this.selected = false,
    this.onTap,
    this.valueTextDirection,
    this.labelFontFamily,
  });

  /// Leading icon. When null, no icon tile is drawn (e.g. language rows).
  final IconData? icon;
  final String label;

  /// Overrides the label font family (e.g. Amiri for an Arabic native name).
  final String? labelFontFamily;
  final String? sub;
  final String? trailingValue;
  final SettingRowTrailing trailing;

  /// Accent variant — umber glyph on an umber-tinted tile (e.g. Suggest a place).
  final bool accent;

  /// Radio selection state (only meaningful when [trailing] is `radio`).
  final bool selected;

  final VoidCallback? onTap;

  /// Forces the trailing value's text direction (e.g. LTR for a native
  /// language name shown inside an RTL screen). Defaults to ambient.
  final TextDirection? valueTextDirection;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final tileColor = accent
        ? HmpColors.umber600.withValues(alpha: 0.12)
        : const Color(0x0D261713);
    final glyphColor = accent ? HmpColors.umber600 : HmpColors.cocoa800;

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      button: onTap != null,
      selected: trailing == SettingRowTrailing.radio ? selected : null,
      // Announce that an external row opens outside the app.
      label: trailing == SettingRowTrailing.external ? '$label, ' : null,
      hint: trailing == SettingRowTrailing.external
          ? _externalHint(context)
          : null,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: HmpSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          color: Colors.transparent,
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: glyphColor),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: labelFontFamily ?? HmpFonts.ui,
                        fontSize: labelFontFamily == HmpFonts.arabic ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: HmpColors.cocoa900,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 11.5,
                          color: HmpColors.cocoa700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingValue != null) ...[
                const SizedBox(width: 10),
                Text(
                  trailingValue!,
                  textDirection: valueTextDirection,
                  style: const TextStyle(
                    fontFamily: HmpFonts.ui,
                    fontSize: 12,
                    color: HmpColors.cocoa700,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              _Trailing(
                trailing: trailing,
                selected: selected,
                isRtl: isRtl,
                reduceMotion: reduceMotion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _externalHint(BuildContext context) {
    // Locale-agnostic, screen-reader-friendly hint; kept short.
    return Directionality.of(context) == TextDirection.rtl
        ? 'يفتح رابطًا خارجيًا'
        : 'Opens an external link';
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.trailing,
    required this.selected,
    required this.isRtl,
    required this.reduceMotion,
  });

  final SettingRowTrailing trailing;
  final bool selected;
  final bool isRtl;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    switch (trailing) {
      case SettingRowTrailing.chevron:
        return Icon(
          isRtl ? Icons.chevron_left : Icons.chevron_right,
          size: 20,
          color: HmpColors.cocoa700,
        );
      case SettingRowTrailing.external:
        // 45° "open external" arrow, umber — points up-and-outward (↗ LTR / ↖ RTL).
        return Icon(
          isRtl ? Icons.north_west : Icons.north_east,
          size: 18,
          color: HmpColors.umber600,
        );
      case SettingRowTrailing.radio:
        return _Radio(selected: selected, reduceMotion: reduceMotion);
      case SettingRowTrailing.none:
        return const SizedBox.shrink();
    }
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.reduceMotion});

  final bool selected;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? HmpColors.verify : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: const Color(0x2E261713), width: 1.5),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
