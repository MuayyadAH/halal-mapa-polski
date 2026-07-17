import 'package:flutter/material.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens.dart';
import '../widgets/stagger_animations.dart';

/// Onboard 1 · Find — discovery framing.
class OnboardFindScreen extends StatefulWidget {
  const OnboardFindScreen({super.key});

  @override
  State<OnboardFindScreen> createState() => _OnboardFindScreenState();
}

class _OnboardFindScreenState extends State<OnboardFindScreen>
    with TickerProviderStateMixin, OnboardEntranceController {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HmpSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),

          // Hero — scales in with the first wave.
          ScaleFadeIn(
            controller: entrance,
            start: 0.0,
            end: 0.43,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [HmpColors.cream100, HmpColors.sand200],
                  ),
                  borderRadius: BorderRadius.circular(HmpRadii.card),
                ),
                child: Stack(
                  children: [
                    _AnimatedPin(
                      controller: entrance,
                      start: 0.50,
                      end: 0.75,
                      top: 40,
                      left: 50,
                      color: HmpColors.catRest,
                    ),
                    _AnimatedPin(
                      controller: entrance,
                      start: 0.57,
                      end: 0.82,
                      top: 90,
                      right: 60,
                      color: HmpColors.catMosque,
                    ),
                    _AnimatedPin(
                      controller: entrance,
                      start: 0.64,
                      end: 0.89,
                      bottom: 80,
                      left: 80,
                      color: HmpColors.catGroc,
                    ),
                    _AnimatedPin(
                      controller: entrance,
                      start: 0.71,
                      end: 0.96,
                      bottom: 50,
                      right: 50,
                      color: HmpColors.catShop,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Headline cascades up after the hero.
          FadeRiseIn(
            controller: entrance,
            start: 0.45,
            end: 0.75,
            child: Text(
              l10n.onboardingFindTitle,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 12),

          FadeRiseIn(
            controller: entrance,
            start: 0.60,
            end: 0.92,
            child: Text(
              l10n.onboardingFindSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _AnimatedPin extends StatelessWidget {
  const _AnimatedPin({
    required this.controller,
    required this.start,
    required this.end,
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Color color;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final drop = Tween<double>(begin: -24, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        // Slight overshoot — feels like a pin dropping.
        curve: Interval(start, end, curve: Curves.elasticOut),
      ),
    );
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: Offset(0, drop.value),
            child: _PinDot(color: color),
          ),
        ),
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: HmpColors.cream50, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: HmpColors.cocoa950.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}
