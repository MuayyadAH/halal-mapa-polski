import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/geometric_motif.dart';

/// Warm linear-gradient background with two soft radial blobs — sand-yellow
/// top-right, muted green bottom-left — under the app's signature khatam
/// lattice watermark. Mirrors the design's `<SoftBg/>`.
///
/// Pass `dark: true` for the cocoa-tinted dark variant used on
/// post-MVP dark surfaces (Welcome B, MasjidDetail, etc.).
class SoftBg extends StatelessWidget {
  const SoftBg({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? const [HmpColors.cocoa950, Color(0xFF28201D)]
                  : const [HmpColors.parchment, Color(0xFFE9DDC3)],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -100,
          child: _Blob(
            size: 320,
            color: dark
                ? HmpColors.catGroc.withValues(alpha: 0.18)
                : HmpColors.sand400.withValues(alpha: 0.70),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -80,
          child: _Blob(
            size: 280,
            color: dark
                ? HmpColors.catMosque.withValues(alpha: 0.18)
                : const Color(0xFFB4C89A).withValues(alpha: 0.55),
          ),
        ),
        GeometricMotif(
          color: dark
              ? HmpColors.cream50.withValues(alpha: 0.035)
              : HmpColors.cocoa900.withValues(alpha: 0.035),
          cell: 104,
        ),
      ],
    );
  }
}

/// Soft circular blob — uses a radial gradient that fades to transparent
/// at the edges so the disc reads as a diffuse glow rather than a hard
/// circle. Cheap alternative to a `BackdropFilter` blur.
class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
