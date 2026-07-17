import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

/// Paints the synthetic street-map basemap (no real tiles, no country outline):
/// a tan block pattern over a warm base, a green park blob, a teal river band,
/// and a few cream roads. Drawn in a 360×220 logical space scaled to the
/// canvas. Handoff §4.4 / README "the mini-map".
class MiniMapPainter extends CustomPainter {
  const MiniMapPainter();

  static const _vbW = 360.0;
  static const _vbH = 220.0;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _vbW;
    final sy = size.height / _vbH;
    canvas.save();
    canvas.scale(sx, sy);

    // Base fill.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _vbW, _vbH),
      Paint()..color = HmpMap.base,
    );

    // City-block pattern: tan rounded rects on a slight rotation.
    final block = Paint()..color = HmpMap.block.withValues(alpha: 0.48);
    canvas.save();
    canvas.translate(_vbW / 2, _vbH / 2);
    canvas.rotate(-8 * math.pi / 180);
    canvas.translate(-_vbW / 2, -_vbH / 2);
    const step = 34.0;
    for (double y = -20; y < _vbH + 20; y += step) {
      for (double x = -20; x < _vbW + 20; x += step) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 22, 22),
            const Radius.circular(4),
          ),
          block,
        );
      }
    }
    canvas.restore();

    // Park blob (top-left).
    final park = Paint()..color = HmpMap.park.withValues(alpha: 0.55);
    canvas.drawPath(
      Path()
        ..moveTo(20, 30)
        ..cubicTo(70, 10, 120, 30, 110, 70)
        ..cubicTo(100, 110, 40, 110, 25, 80)
        ..close(),
      park,
    );

    // River band across the lower third.
    final river = Paint()..color = HmpMap.river.withValues(alpha: 0.7);
    canvas.drawPath(
      Path()
        ..moveTo(-10, 150)
        ..cubicTo(90, 130, 180, 185, 280, 160)
        ..cubicTo(330, 150, 360, 170, 370, 165)
        ..lineTo(370, 200)
        ..cubicTo(300, 205, 120, 195, -10, 205)
        ..close(),
      river,
    );

    // Roads.
    final road = Paint()
      ..color = HmpMap.road
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void roadLine(List<Offset> pts, double w, double alpha) {
      road
        ..strokeWidth = w
        ..color = HmpMap.road.withValues(alpha: alpha);
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p, road);
    }

    roadLine(
      const [Offset(-10, 60), Offset(140, 70), Offset(360, 50)],
      11,
      0.9,
    );
    roadLine(
      const [Offset(40, -10), Offset(70, 120), Offset(120, 230)],
      8,
      0.8,
    );
    roadLine(
      const [Offset(360, 110), Offset(220, 120), Offset(60, 200)],
      9,
      0.7,
    );
    roadLine(const [Offset(-10, 120), Offset(360, 130)], 6, 0.55);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiniMapPainter oldDelegate) => false;
}
