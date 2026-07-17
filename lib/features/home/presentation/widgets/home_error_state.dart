import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Graceful empty/error state for the Featured section when the places fetch
/// fails and no cache is available (FR-016). Offers a retry.
class HomeErrorState extends StatelessWidget {
  const HomeErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        HmpSpacing.screenH,
        16,
        HmpSpacing.screenH,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeLoadError,
            style: const TextStyle(
              fontFamily: HmpFonts.ui,
              fontSize: HmpType.meta,
              color: HmpColors.cocoa700,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.homeRetry,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w700,
                fontSize: HmpType.tiny,
                color: HmpColors.umber600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
