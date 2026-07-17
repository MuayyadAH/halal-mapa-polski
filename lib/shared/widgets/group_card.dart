import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

/// A grouped settings card (004-profile-screen FR-017): a translucent parchment
/// card with a hairline border and soft cocoa-tinted shadow, holding stacked
/// rows separated by 1px hairline dividers (none after the last). An optional
/// uppercase umber section label sits above the card.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.rows, this.sectionLabel});

  /// Rows to stack (typically [SettingRow]s).
  final List<Widget> rows;

  /// Optional uppercase section label rendered above the card.
  final String? sectionLabel;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0x0D261713),
            indent: 14,
            endIndent: 14,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sectionLabel != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 8),
              child: Text(
                sectionLabel!.toUpperCase(),
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: HmpColors.umber600,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: HmpColors.parchment.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
              border: Border.all(color: const Color(0x0D261713)),
              boxShadow: HmpShadows.card,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}
