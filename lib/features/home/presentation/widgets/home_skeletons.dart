import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'place_card.dart';

/// Sand-tone shimmer placeholders for the Featured row while data loads
/// (FR-023 — skeletons, not spinners).
class FeaturedSkeletonRow extends StatelessWidget {
  const FeaturedSkeletonRow({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116 + 12 + 22, // image + body padding + name line, approx
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: HmpSpacing.screenH,
        ),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const _Shimmer(
          child: SizedBox(width: PlaceCard.width, height: 150),
        ),
      ),
    );
  }
}

/// Pulsing sand-tone box; static under reduced motion.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations && !_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = 0.5 + (_c.value * 0.25);
        return Opacity(
          opacity: MediaQuery.of(context).disableAnimations ? 0.6 : t,
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HmpColors.sand300,
          borderRadius: BorderRadius.circular(HmpRadii.cardCompact),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Friendly empty-state message shown when a category filter yields no places
/// (FR-023).
class HomeEmptyCategory extends StatelessWidget {
  const HomeEmptyCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        HmpSpacing.screenH,
        16,
        HmpSpacing.screenH,
        16,
      ),
      child: Text(
        l10n.homeEmptyCategory,
        style: const TextStyle(
          fontFamily: HmpFonts.ui,
          fontSize: HmpType.meta,
          color: HmpColors.muted,
        ),
      ),
    );
  }
}
