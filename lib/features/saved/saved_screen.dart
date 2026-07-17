import 'package:flutter/material.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSaved)),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
