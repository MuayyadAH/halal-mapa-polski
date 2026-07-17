import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/map_view_notifier.dart';
import '../state/sort.dart';

/// Lista sort control (design "Sort control"): a pill showing the current sort
/// that opens a menu. "Najbliższe" is offered only when a location is
/// available; "Otwarte teraz" is intentionally absent (no hours). (FR-020)
class SortPill extends ConsumerWidget {
  const SortPill({super.key});

  String _label(SortMode mode, AppLocalizations l10n) => switch (mode) {
        SortMode.nearest => l10n.mapSortNearest,
        SortMode.alphabetical => l10n.mapSortAlphabetical,
        SortMode.category => l10n.mapSortByCategory,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(sortModeProvider);
    final hasLocation = ref.watch(userLatLngProvider) != null;

    return PressableScale(
      onTap: () => _openMenu(context, ref, hasLocation),
      semanticLabel: _label(mode, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xF2FBF8EF),
          borderRadius: BorderRadius.circular(HmpRadii.pill),
          boxShadow: HmpShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 15, color: HmpColors.cocoa800),
            const SizedBox(width: 6),
            Text(
              _label(mode, l10n),
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: HmpColors.cocoa800,
              ),
            ),
            const Icon(Icons.expand_more, size: 16, color: HmpColors.cocoa800),
          ],
        ),
      ),
    );
  }

  void _openMenu(BuildContext context, WidgetRef ref, bool hasLocation) {
    final l10n = AppLocalizations.of(context);
    final modes = [
      if (hasLocation) SortMode.nearest,
      SortMode.alphabetical,
      SortMode.category,
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HmpColors.cream50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in modes)
              ListTile(
                title: Text(_label(m, l10n)),
                trailing: ref.read(sortModeProvider) == m
                    ? const Icon(Icons.check, color: HmpColors.cocoa800)
                    : null,
                onTap: () {
                  ref.read(sortModeProvider.notifier).set(m);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
