import 'package:flutter/material.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens.dart';
import '../widgets/stagger_animations.dart';

/// Onboard 2 · Trust — explains the three-tier verification system.
class OnboardTrustScreen extends StatefulWidget {
  const OnboardTrustScreen({super.key});

  @override
  State<OnboardTrustScreen> createState() => _OnboardTrustScreenState();
}

class _OnboardTrustScreenState extends State<OnboardTrustScreen>
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
          FadeRiseIn(
            controller: entrance,
            start: 0.0,
            end: 0.32,
            child: Text(
              l10n.onboardingTrustTitle,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 12),
          FadeRiseIn(
            controller: entrance,
            start: 0.18,
            end: 0.50,
            child: Text(
              l10n.onboardingTrustSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 32),

          // Three tier rows cascade with 80ms stagger.
          FadeRiseIn(
            controller: entrance,
            start: 0.40,
            end: 0.70,
            child: _TierRow(
              label: l10n.onboardingTrustVerifiedOwner,
              background: HmpColors.verify,
              foreground: HmpColors.cream50,
              style: _TierStyle.solid,
            ),
          ),
          const SizedBox(height: 12),
          FadeRiseIn(
            controller: entrance,
            start: 0.50,
            end: 0.80,
            child: _TierRow(
              label: '✓ ${l10n.onboardingTrustCommunity}',
              background: HmpColors.verify.withValues(alpha: 0.14),
              foreground: HmpColors.verify,
              style: _TierStyle.outlined,
            ),
          ),
          const SizedBox(height: 12),
          FadeRiseIn(
            controller: entrance,
            start: 0.60,
            end: 0.90,
            child: _TierRow(
              label: '⏳ ${l10n.onboardingTrustPending}',
              background: HmpColors.pending.withValues(alpha: 0.14),
              foreground: HmpColors.pending,
              style: _TierStyle.dashed,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

enum _TierStyle { solid, outlined, dashed }

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.label,
    required this.background,
    required this.foreground,
    required this.style,
  });

  final String label;
  final Color background;
  final Color foreground;
  final _TierStyle style;

  @override
  Widget build(BuildContext context) {
    final border = switch (style) {
      _TierStyle.solid => null,
      _TierStyle.outlined => Border.all(
          color: foreground.withValues(alpha: 0.25),
          width: 1.5,
        ),
      _TierStyle.dashed => Border.all(
          color: foreground.withValues(alpha: 0.35),
          width: 1.5,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(HmpRadii.pill),
        border: border,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: HmpFonts.ui,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: foreground,
        ),
      ),
    );
  }
}
