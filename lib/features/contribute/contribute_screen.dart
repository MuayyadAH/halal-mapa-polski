import 'package:flutter/material.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

class ContributeScreen extends StatelessWidget {
  const ContributeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabAdd)),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
