import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

/// Screen header used across the Profile screens (004-profile-screen FR-017):
/// an optional 38dp parchment-glass back-chevron tile, an optional uppercase
/// umber kicker, and a Lora title. The chevron is `Directionality`-aware
/// (mirrors in RTL) and pops the current route via [Navigator.maybePop].
///
/// Screen 1 (tab root) uses `showBack: false` (title only); Screens 2 & 3 show
/// the chevron + a kicker. Lives in `lib/shared/widgets/` so the future full
/// Settings screen can reuse it.
class BackHeader extends StatelessWidget {
  const BackHeader({
    super.key,
    required this.title,
    this.kicker,
    this.showBack = true,
  });

  final String title;
  final String? kicker;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        HmpSpacing.screenH,
        0,
        HmpSpacing.screenH,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack) ...[
            _BackTile(onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kicker != null)
                  Text(
                    kicker!.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: HmpType.kickerSpread * 12,
                      color: HmpColors.umber600,
                    ),
                  ),
                if (kicker != null) const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: HmpFonts.display,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: HmpColors.cocoa900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackTile extends StatelessWidget {
  const _BackTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HmpRadii.iconSm),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HmpColors.parchment.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(HmpRadii.iconSm),
            border: Border.all(color: const Color(0x0D261713)),
          ),
          // Chevron points back: left in LTR, right in RTL.
          child: Icon(
            isRtl ? Icons.chevron_right : Icons.chevron_left,
            size: 22,
            color: HmpColors.cocoa800,
          ),
        ),
      ),
    );
  }
}
