import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Resting search bar. Tapping it opens the search-active overlay (Screen A).
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: Semantics(
        button: true,
        label: l10n.homeSearchHint,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            constraints:
                const BoxConstraints(minHeight: HmpSpacing.minTapTarget),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(HmpRadii.search),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29261713),
                  offset: Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: HmpColors.cocoa800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.homeSearchHint,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: HmpType.cardTitle,
                      color: HmpColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
