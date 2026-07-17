import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/map_providers.dart';

/// Horizontal place card in the Map bottom sheet (design "Mini-cards"), adapted
/// to the lean v1 data: category-tinted icon tile + name + "category · distance"
/// + optional comment, a Navigate button (→ external maps), and a Mawaqit
/// prayer-times link on mosques. Selected cards get a white fill + cocoa border
/// (003-map-screen FR-009/FR-013).
class MiniCard extends ConsumerWidget {
  const MiniCard({
    required this.place,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Place place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final meters = ref.watch(distanceMetersForProvider(place));
    final distance = meters == null
        ? null
        : formatDistance(meters, Localizations.localeOf(context).toString());

    final meta = [
      place.category.label(l10n),
      if (distance != null) distance,
    ].join(' · ');

    return PressableScale(
      onTap: onTap,
      semanticLabel: place.name,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : HmpColors.cream50,
          borderRadius: BorderRadius.circular(15),
          border: selected
              ? Border.all(color: HmpColors.cocoa800, width: 1.5)
              : null,
          boxShadow: selected ? HmpShadows.pop : HmpShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _IconTile(category: place.category),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: HmpColors.cocoa900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 10.5,
                          color: HmpColors.cocoa700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _footer(l10n)),
                _NavigateButton(place: place),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Footer-left content: a Mawaqit prayer-times link on mosques, else the
  /// optional comment, else nothing (the design's open/closed status has no
  /// data in v1).
  Widget _footer(AppLocalizations l10n) {
    if (place.category == Category.masjid &&
        place.mawaqitLink != null &&
        place.mawaqitLink!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 13, color: HmpColors.umber600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              l10n.mapPrayerTimes,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: HmpColors.umber600,
              ),
            ),
          ),
        ],
      );
    }
    final comment = place.comment;
    if (comment != null && comment.isNotEmpty) {
      return Text(
        comment,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontSize: 11,
          color: HmpColors.muted,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [category.color, HmpColors.cocoa800],
        ),
      ),
      child: Text(category.glyph, style: const TextStyle(fontSize: 16)),
    );
  }
}

class _NavigateButton extends ConsumerWidget {
  const _NavigateButton({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.mapNavigate,
      child: GestureDetector(
        onTap: () => ref.read(mapsLauncherProvider).openPlace(place),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HmpColors.cocoa800,
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Icon(Icons.send, size: 13, color: HmpColors.cream50),
        ),
      ),
    );
  }
}
