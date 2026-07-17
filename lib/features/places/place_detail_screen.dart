import 'package:flutter/material.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${l10n.comingSoon} · #$placeId')),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
