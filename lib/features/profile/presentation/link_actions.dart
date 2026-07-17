import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Opens [url] via the shared [externalLinkLauncherProvider] and, on failure,
/// shows a brief localized SnackBar (004-profile-screen FR-014 / Constitution
/// §1.3). Never throws; safe to fire from any Profile control.
Future<void> openExternalLink(
  BuildContext context,
  WidgetRef ref,
  String url,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final failedMessage = AppLocalizations.of(context).linkOpenFailed;
  final ok = await ref.read(externalLinkLauncherProvider).open(Uri.parse(url));
  if (!ok && context.mounted) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(failedMessage),
        backgroundColor: HmpColors.cocoa800,
      ),
    );
  }
}
