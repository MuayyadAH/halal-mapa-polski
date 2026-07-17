import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../state/map_view_notifier.dart';

/// Map ↔ Lista segmented toggle (design "View toggle"). (FR-021)
class ViewToggle extends ConsumerWidget {
  const ViewToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(mapViewProvider);
    final notifier = ref.read(mapViewProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xF2FBF8EF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: HmpShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: l10n.tabMap,
            icon: Icons.map_outlined,
            active: view == MapViewMode.map,
            onTap: () => notifier.show(MapViewMode.map),
          ),
          _Segment(
            label: l10n.mapToggleList,
            icon: Icons.view_list_outlined,
            active: view == MapViewMode.list,
            onTap: () => notifier.show(MapViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? HmpColors.cocoa800 : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? HmpColors.cream50 : HmpColors.cocoa700,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: active ? HmpColors.cream50 : HmpColors.cocoa700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
