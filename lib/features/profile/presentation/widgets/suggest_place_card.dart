import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

/// About-screen "Suggest a place" call-to-action card (004-profile-screen
/// FR-013): a tappable umber-tinted card with a pin-plus tile, title + sub, and
/// an external-link arrow. Opens the external form via [onTap].
class SuggestPlaceCard extends StatelessWidget {
  const SuggestPlaceCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: Semantics(
        button: true,
        label: l10n.rowSuggestPlace,
        hint: isRtl ? 'يفتح رابطًا خارجيًا' : 'Opens an external link',
        child: PressableScale(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HmpColors.umber600.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
              border: Border.all(
                color: HmpColors.umber600.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HmpColors.umber600.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(HmpRadii.iconSm),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_outlined,
                    size: 22,
                    color: HmpColors.umber600,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.rowSuggestPlace,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: HmpColors.cocoa900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.rowSuggestPlaceSub,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 11.5,
                          color: HmpColors.cocoa700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isRtl ? Icons.north_west : Icons.north_east,
                  size: 18,
                  color: HmpColors.umber600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
