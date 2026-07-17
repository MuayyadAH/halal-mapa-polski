import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';

/// Circular cluster marker (design "Cluster"): cocoa fill, cream border, cream
/// count. Diameter scales gently with the member count.
class ClusterBubble extends StatelessWidget {
  const ClusterBubble({required this.count, super.key});

  final int count;

  double get diameter => 38 + count * 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HmpColors.cocoa800,
        shape: BoxShape.circle,
        border: Border.all(color: HmpColors.cream50, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80261713),
            blurRadius: 22,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: HmpColors.cream50,
        ),
      ),
    );
  }
}
