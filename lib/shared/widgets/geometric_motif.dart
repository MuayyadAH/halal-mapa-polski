import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The app's signature ornament: a quiet lattice of eight-pointed stars
/// (khatam) drawn as thin line-work. Used as a watermark on heroes, empty
/// states, and onboarding backgrounds — always low-opacity, never decorative
/// kitsch. Deterministic (no randomness) so goldens stay stable.
class GeometricMotif extends StatelessWidget {
  const GeometricMotif({
    super.key,
    required this.color,
    this.cell = 88,
    this.strokeWidth = 1,
  });

  /// Line color — pass the final color *including* opacity
  /// (e.g. `HmpColors.cream50.withValues(alpha: .08)`).
  final Color color;

  /// Size of one star tile in logical px.
  final double cell;

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _KhatamLatticePainter(
          color: color,
          cell: cell,
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _KhatamLatticePainter extends CustomPainter {
  const _KhatamLatticePainter({
    required this.color,
    required this.cell,
    required this.strokeWidth,
  });

  final Color color;
  final double cell;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    final cols = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;
    final r = cell * 0.34;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        // Offset every second row by half a cell for a woven rhythm.
        final dx = col * cell + (row.isOdd ? cell / 2 : 0);
        final dy = row * cell;
        _drawStar(canvas, Offset(dx, dy), r, paint);
      }
    }
  }

  /// Two overlapping squares (one rotated 45°) form the khatam star.
  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    for (final phase in const [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = phase + i * math.pi / 2;
        final p = c + Offset(math.cos(a), math.sin(a)) * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_KhatamLatticePainter old) =>
      old.color != color || old.cell != cell || old.strokeWidth != strokeWidth;
}

/// Editorial section divider: hairline — small khatam star — hairline.
/// The star inherits [color]; lines fade toward the edges.
class MotifDivider extends StatelessWidget {
  const MotifDivider({super.key, this.color = const Color(0x33261713)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _fadingLine(reverse: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CustomPaint(painter: _SingleStarPainter(color: color)),
          ),
        ),
        Expanded(child: _fadingLine(reverse: false)),
      ],
    );
  }

  Widget _fadingLine({required bool reverse}) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reverse
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          end: reverse
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _SingleStarPainter extends CustomPainter {
  const _SingleStarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 1;
    for (final phase in const [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = phase + i * math.pi / 2;
        final p = c + Offset(math.cos(a), math.sin(a)) * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SingleStarPainter old) => old.color != color;
}
