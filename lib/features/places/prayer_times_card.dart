import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/core/prayer_times/mawaqit.dart';
import 'package:halal_map_polskie/core/prayer_times/mawaqit_service.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// Mosque prayer-times card on the place detail: today's five times from the
/// mosque's own Mawaqit page, next prayer highlighted, optional Jumu'ah row,
/// and a source link. Falls back to a quiet unavailable row (with the external
/// link still tappable) when the page can't be fetched and no cache exists —
/// no silent failure (constitution §1.3).
class PrayerTimesCard extends ConsumerWidget {
  const PrayerTimesCard({super.key, required this.mawaqitUrl});

  final String mawaqitUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conf = ref.watch(mawaqitConfProvider(mawaqitUrl));
    return conf.when(
      loading: () => const _CardShell(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: HmpColors.catMosque,
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => _Unavailable(mawaqitUrl: mawaqitUrl),
      data: (data) {
        final now = DateTime.now();
        final times = data?.timesFor(now);
        if (data == null || times == null) {
          return _Unavailable(mawaqitUrl: mawaqitUrl);
        }
        return _TimesGrid(
          conf: data,
          times: times,
          now: now,
          mawaqitUrl: mawaqitUrl,
        );
      },
    );
  }
}

class _TimesGrid extends ConsumerWidget {
  const _TimesGrid({
    required this.conf,
    required this.times,
    required this.now,
    required this.mawaqitUrl,
  });

  final MawaqitConf conf;
  final List<String> times;
  final DateTime now;
  final String mawaqitUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final next = nextPrayer(conf, now);
    final labels = [
      l10n.prayerFajr,
      l10n.prayerDhuhr,
      l10n.prayerAsr,
      l10n.prayerMaghrib,
      l10n.prayerIsha,
    ];

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.mapPrayerTimes,
                  style: const TextStyle(
                    fontFamily: HmpFonts.ui,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: HmpColors.cocoa900,
                  ),
                ),
              ),
              _MawaqitLink(mawaqitUrl: mawaqitUrl),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < kPrayerKeys.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _TimeCell(
                    label: labels[i],
                    time: times[i],
                    highlighted: next != null &&
                        next.key == kPrayerKeys[i] &&
                        _sameDate(next.at, now),
                  ),
                ),
              ],
            ],
          ),
          if (conf.jumua != null && conf.jumua!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 15,
                  color: HmpColors.catMosque,
                ),
                const SizedBox(width: 6),
                Text(
                  "${l10n.prayerJumua} · ${conf.jumua}",
                  style: const TextStyle(
                    fontFamily: HmpFonts.ui,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: HmpColors.cocoa700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.label,
    required this.time,
    required this.highlighted,
  });

  final String label;
  final String time;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? HmpColors.catMosque : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: HmpFonts.ui,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: highlighted
                  ? HmpColors.cream50.withValues(alpha: 0.8)
                  : HmpColors.umber600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: TextStyle(
              fontFamily: HmpFonts.display,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: highlighted ? HmpColors.cream50 : HmpColors.cocoa900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.mawaqitUrl});

  final String mawaqitUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CardShell(
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            size: 18,
            color: HmpColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.prayerTimesUnavailable,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 13,
                color: HmpColors.muted,
              ),
            ),
          ),
          _MawaqitLink(mawaqitUrl: mawaqitUrl),
        ],
      ),
    );
  }
}

class _MawaqitLink extends ConsumerWidget {
  const _MawaqitLink({required this.mawaqitUrl});

  final String mawaqitUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = mawaqitUrl;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: 'Mawaqit',
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.tryParse(url);
          final ok = uri != null &&
              await ref.read(externalLinkLauncherProvider).open(uri);
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.linkOpenFailed)),
            );
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'Mawaqit ↗',
            style: TextStyle(
              fontFamily: HmpFonts.mono,
              fontSize: 11,
              color: HmpColors.umber600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HmpColors.catMosque.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
        border: Border.all(color: HmpColors.catMosque.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}
