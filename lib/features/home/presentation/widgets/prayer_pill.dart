import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/prayer_times/mawaqit.dart';
import 'package:halal_map_polskie/core/prayer_times/mawaqit_service.dart';
import 'package:halal_map_polskie/core/routing/app_router.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

/// The Home prayer pill (design "Prayer-time pill", §6.5): next prayer at the
/// nearest Mawaqit-listed mosque, with a live countdown under an hour.
/// Refreshes every 30 s; hides entirely when no mosque carries a Mawaqit link
/// or its times are unavailable (the pill is a bonus surface, not a dead-end).
/// Tapping opens that mosque's detail page.
class PrayerPill extends ConsumerStatefulWidget {
  const PrayerPill({super.key});

  @override
  ConsumerState<PrayerPill> createState() => _PrayerPillState();
}

class _PrayerPillState extends ConsumerState<PrayerPill> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosque = ref.watch(nearestMawaqitMosqueProvider);
    final link = mosque?.mawaqitLink;
    if (mosque == null || link == null || link.isEmpty) {
      return const SizedBox.shrink();
    }

    final conf = ref.watch(mawaqitConfProvider(link)).value;
    if (conf == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final next = nextPrayer(conf, now);
    if (next == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final label = _prayerLabel(l10n, next.key);
    final hm = '${next.at.hour.toString().padLeft(2, '0')}:'
        '${next.at.minute.toString().padLeft(2, '0')}';
    final minutesLeft = ((next.at.difference(now).inSeconds) + 59) ~/ 60;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        HmpSpacing.screenH,
        14,
        HmpSpacing.screenH,
        0,
      ),
      child: PressableScale(
        semanticLabel: '$label $hm · ${mosque.name}',
        onTap: () => context.push(placeDetailLocation(mosque.id)),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 12, 10),
          decoration: BoxDecoration(
            color: HmpColors.cocoa800,
            borderRadius: BorderRadius.circular(HmpRadii.pill),
            boxShadow: HmpShadows.card,
          ),
          child: Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Text(
                '$label · $hm',
                style: const TextStyle(
                  fontFamily: HmpFonts.display,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: HmpColors.cream50,
                ),
              ),
              if (minutesLeft < 60) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: HmpColors.sand400,
                    borderRadius: BorderRadius.circular(HmpRadii.pill),
                  ),
                  child: Text(
                    l10n.prayerInMinutes(minutesLeft),
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                      color: HmpColors.cocoa900,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Flexible(
                child: Text(
                  mosque.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontFamily: HmpFonts.ui,
                    fontSize: 11.5,
                    color: HmpColors.sand300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _prayerLabel(AppLocalizations l10n, String key) => switch (key) {
        'fajr' => l10n.prayerFajr,
        'dhuhr' => l10n.prayerDhuhr,
        'asr' => l10n.prayerAsr,
        'maghrib' => l10n.prayerMaghrib,
        _ => l10n.prayerIsha,
      };
}
