import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

/// Shared section header: serif h2 title with an optional right-side count.
/// Handoff §4.9.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: HmpFonts.display,
                fontWeight: FontWeight.w500,
                fontSize: HmpType.homeH2,
                color: HmpColors.cocoa900,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w700,
                fontSize: HmpType.tiny,
                color: HmpColors.umber600,
              ),
            ),
        ],
      ),
    );
  }
}
