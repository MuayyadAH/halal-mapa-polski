import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Parchment-glass locate-me button (design "Locate-me FAB"): recenters the
/// camera on the user dot.
class LocateMeFab extends StatelessWidget {
  const LocateMeFab({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.mapLocateMe,
      child: Material(
        color: const Color(0xF5FBF8EF),
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: HmpColors.cocoa950,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.my_location, size: 22, color: HmpColors.cocoa800),
          ),
        ),
      ),
    );
  }
}
