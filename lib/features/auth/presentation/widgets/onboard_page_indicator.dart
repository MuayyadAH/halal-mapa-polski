import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// Three-dot horizontal indicator used by [OnboardIntroScreen] to show
/// the user's position within the Onboard 1 → 2 → 3 sequence (FR-015).
class OnboardPageIndicator extends StatelessWidget {
  const OnboardPageIndicator({
    super.key,
    required this.currentPage,
    this.total = 3,
  });

  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? HmpColors.cocoa800
                  : HmpColors.cocoa800.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(HmpRadii.pill),
            ),
          ),
        );
      }),
    );
  }
}
