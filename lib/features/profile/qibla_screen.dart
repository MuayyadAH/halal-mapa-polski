import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/distance.dart';
import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/qibla/qibla.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/back_header.dart';
import 'package:halal_map_polskie/shared/widgets/geometric_motif.dart';

/// Qibla compass (Profile → Preferences): a live dial that keeps north under
/// the device heading with the Kaaba needle at the qibla bearing. Falls back
/// to a static from-north dial when the device has no compass sensor.
/// Location uses the shared approximate fix (Warsaw fallback — the bearing
/// changes only ~2° across Poland).
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userLatLngProvider);
    final lat = user?.lat ?? kWarsawLat;
    final lng = user?.lng ?? kWarsawLng;
    final bearing = qiblaBearing(lat, lng);
    final headingAsync = ref.watch(headingProvider);
    final heading = headingAsync.value;
    final hasCompass = heading != null;

    final km = (distanceMeters(lat, lng, kKaabaLat, kKaabaLng) / 1000).round();
    final aligned = hasCompass && _angleDelta(bearing, heading) < 5;

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HmpColors.homeBgGradientStart,
              HmpColors.homeBgGradientEnd,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GeometricMotif(
              color: HmpColors.cocoa900.withValues(alpha: 0.035),
              cell: 104,
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  BackHeader(
                    title: l10n.qiblaTitle,
                    kicker: l10n.groupPreferences,
                  ),
                  const Spacer(),
                  _CompassDial(
                    bearing: bearing,
                    heading: heading,
                    aligned: aligned,
                  ),
                  const SizedBox(height: 28),
                  if (aligned)
                    Text(
                      l10n.qiblaAligned,
                      style: const TextStyle(
                        fontFamily: HmpFonts.display,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: HmpColors.verify,
                      ),
                    )
                  else
                    Text(
                      l10n.qiblaDegrees(bearing.round()),
                      style: const TextStyle(
                        fontFamily: HmpFonts.display,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: HmpColors.cocoa900,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.qiblaDistance(km),
                    style: const TextStyle(
                      fontFamily: HmpFonts.mono,
                      fontSize: 12.5,
                      color: HmpColors.muted,
                    ),
                  ),
                  if (!hasCompass) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        l10n.qiblaNoCompass,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontSize: 12.5,
                          color: HmpColors.muted,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _angleDelta(double a, double b) {
    final d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.bearing,
    required this.heading,
    required this.aligned,
  });

  final double bearing;
  final double? heading;

  /// Within 5° of the qibla — the ring turns verify-green.
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    // With a live heading the dial counter-rotates so N tracks true north;
    // without one it stays fixed (needle shows the from-north bearing).
    final dialTurn = -(heading ?? 0) * math.pi / 180;
    final needleTurn = (bearing - (heading ?? 0)) * math.pi / 180;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HmpColors.cream50,
              border: Border.all(
                color: aligned ? HmpColors.verify : const Color(0x1F261713),
                width: aligned ? 3 : 1.5,
              ),
              boxShadow: HmpShadows.card,
            ),
          ),
          AnimatedRotation(
            turns: dialTurn / (2 * math.pi),
            duration: const Duration(milliseconds: 200),
            child: CustomPaint(
              size: const Size(236, 236),
              painter: _DialPainter(),
            ),
          ),
          AnimatedRotation(
            turns: needleTurn / (2 * math.pi),
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: 236,
              height: 236,
              // The needle occupies only the top half so the line runs from
              // the dial centre out to the Kaaba at its tip — never past it.
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  const Text('🕋', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Container(
                    width: 3,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          aligned ? HmpColors.verify : HmpColors.catMosque,
                          HmpColors.cocoa900.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: HmpColors.cocoa800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tick ring + cardinal N marker, drawn in cocoa line-work to match the
/// khatam motif language.
class _DialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final tick = Paint()
      ..strokeWidth = 1.5
      ..color = const Color(0x33261713);
    final major = Paint()
      ..strokeWidth = 2
      ..color = const Color(0x66261713);

    for (var deg = 0; deg < 360; deg += 15) {
      final isMajor = deg % 90 == 0;
      final a = (deg - 90) * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      final outer = c + dir * r;
      final inner = c + dir * (r - (isMajor ? 14 : 8));
      canvas.drawLine(inner, outer, isMajor ? major : tick);
    }

    // N marker.
    final n = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          fontFamily: HmpFonts.ui,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: HmpColors.closed,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    n.paint(canvas, Offset(c.dx - n.width / 2, 18));
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) => false;
}
