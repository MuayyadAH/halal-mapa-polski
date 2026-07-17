import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/maps/maps_launcher.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../state/map_providers.dart';

/// A Lista row (design "List view · rows"), adapted to the lean data: gradient
/// icon tile, name, "category · comment", a trailing distance (when located) +
/// Navigate button. No open/closed status, address, or walk time. (FR-015)
class ListRow extends ConsumerWidget {
  const ListRow({required this.place, required this.onTap, super.key});

  final Place place;
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
      if (place.comment != null && place.comment!.isNotEmpty) place.comment!,
    ].join(' · ');

    return PressableScale(
      onTap: onTap,
      semanticLabel: place.name,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [place.category.color, HmpColors.cocoa800],
                ),
              ),
              child: Text(
                place.category.glyph,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 14),
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
                      fontSize: 14,
                      color: HmpColors.cocoa900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: 11.5,
                      color: HmpColors.cocoa700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (distance != null)
              Text(
                distance,
                style: const TextStyle(
                  fontFamily: HmpFonts.display,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: HmpColors.cocoa800,
                ),
              ),
            const SizedBox(width: 10),
            _NavigateButton(place: place),
          ],
        ),
      ),
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
          width: 26,
          height: 26,
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
