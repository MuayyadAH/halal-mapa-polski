import 'package:flutter/material.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens.dart';
import '../widgets/stagger_animations.dart';

/// Onboard 3 · Community — invites contribution.
class OnboardCommunityScreen extends StatefulWidget {
  const OnboardCommunityScreen({super.key});

  @override
  State<OnboardCommunityScreen> createState() => _OnboardCommunityScreenState();
}

class _OnboardCommunityScreenState extends State<OnboardCommunityScreen>
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

          // Activity stat card scales in.
          ScaleFadeIn(
            controller: entrance,
            start: 0.0,
            end: 0.45,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [HmpColors.cocoa800, HmpColors.umber600],
                ),
                borderRadius: BorderRadius.circular(HmpRadii.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '147',
                    style: TextStyle(
                      fontFamily: HmpFonts.display,
                      fontSize: HmpType.statDisplay,
                      fontWeight: FontWeight.w500,
                      color: HmpColors.cream50,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.onboardingCommunityStatLabel,
                    style: const TextStyle(
                      fontFamily: HmpFonts.ui,
                      fontSize: 14,
                      color: HmpColors.sand300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          FadeRiseIn(
            controller: entrance,
            start: 0.45,
            end: 0.75,
            child: Text(
              l10n.onboardingCommunityTitle,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 12),
          FadeRiseIn(
            controller: entrance,
            start: 0.60,
            end: 0.92,
            child: Text(
              l10n.onboardingCommunitySubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
