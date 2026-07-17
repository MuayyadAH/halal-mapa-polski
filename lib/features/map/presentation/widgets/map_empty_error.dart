import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Non-blocking empty/error overlay for the Map when the places fetch fails
/// and no cache exists (spec FR-023). Reuses the Home load-error copy.
class MapEmptyError extends StatelessWidget {
  const MapEmptyError({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 40,
              color: HmpColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 15,
                color: HmpColors.cocoa800,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: HmpColors.cocoa800,
                foregroundColor: HmpColors.cream50,
              ),
              child: Text(l10n.homeRetry),
            ),
          ],
        ),
      ),
    );
  }
}
