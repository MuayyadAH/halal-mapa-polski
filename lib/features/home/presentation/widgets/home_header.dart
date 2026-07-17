import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Guest, nationwide header: H1 "Miejsca *halal* w Polsce" (the accent word is
/// italic umber) + subtitle. No avatar / greeting / login (FR-003).
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const titleBase = TextStyle(
      fontFamily: HmpFonts.display,
      fontWeight: FontWeight.w500,
      fontSize: HmpType.homeH1,
      height: 1.12,
      color: HmpColors.cocoa900,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        HmpSpacing.screenH,
        0,
        HmpSpacing.screenH,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n.homeH1Before),
                TextSpan(
                  text: l10n.homeH1Accent,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: HmpColors.umber600,
                  ),
                ),
                TextSpan(text: l10n.homeH1After),
              ],
            ),
            style: titleBase,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.homeSubtitle,
            style: const TextStyle(
              fontFamily: HmpFonts.ui,
              fontWeight: FontWeight.w400,
              fontSize: HmpType.tiny,
              color: HmpColors.cocoa700,
            ),
          ),
        ],
      ),
    );
  }
}
