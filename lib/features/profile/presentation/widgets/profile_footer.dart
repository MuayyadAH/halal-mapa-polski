import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Centered two-line footer used on the Profile landing and the About screen
/// (004-profile-screen FR-007 / FR-013): an app + version line and a second
/// line (mission or copyright).
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key, required this.secondLine});

  /// The second line — mission (Screen 1) or copyright (Screen 3).
  final String secondLine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const style = TextStyle(
      fontFamily: HmpFonts.ui,
      fontSize: 11,
      height: 1.5,
      color: HmpColors.cocoa700,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: Column(
        children: [
          Text(
            '${l10n.appTitle} · v ${AppInfo.version}',
            textAlign: TextAlign.center,
            style: style,
          ),
          Text(secondLine, textAlign: TextAlign.center, style: style),
        ],
      ),
    );
  }
}
