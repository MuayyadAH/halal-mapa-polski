import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/env/env.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/pressable_scale.dart';

import '../link_actions.dart';

/// The "accounts are coming soon" banner at the top of the Profile landing
/// (004-profile-screen FR-002): a cocoa→umber gradient card with a glowing
/// clock ring, a floating "● Wkrótce" badge, a Lora headline with an italic
/// sand accent word, a subline, and a primary "Notify me" button that opens
/// the external form. Ambient glow + badge-float honor reduced motion (FR-018).
class ComingSoonBanner extends ConsumerStatefulWidget {
  const ComingSoonBanner({super.key});

  @override
  ConsumerState<ComingSoonBanner> createState() => _ComingSoonBannerState();
}

class _ComingSoonBannerState extends ConsumerState<ComingSoonBanner>
    with TickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Honor reduced motion: leave controllers at rest (no ambient loops).
    if (!MediaQuery.of(context).disableAnimations) {
      _glow.repeat(reverse: true);
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [HmpColors.cocoa800, HmpColors.umber600],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: HmpShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ClockRing(glow: _glow),
              const SizedBox(height: 16),
              _Badge(float: _float, label: l10n.comingSoonBadge),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: l10n.comingSoonHeadlineBefore),
                    TextSpan(
                      text: l10n.comingSoonHeadlineAccent,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: HmpColors.sand400,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontFamily: HmpFonts.display,
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  color: HmpColors.cream50,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.comingSoonSub,
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 12.5,
                  height: 1.4,
                  color: HmpColors.sand300,
                ),
              ),
              const SizedBox(height: 18),
              _NotifyButton(
                label: l10n.notifyButton,
                onTap: () => openExternalLink(context, ref, Env.suggestFormUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClockRing extends StatelessWidget {
  const _ClockRing({required this.glow});

  final Animation<double> glow;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (_, child) {
        final t = glow.value; // 0..1
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HmpColors.sand400.withValues(alpha: 0.12),
            border: Border.all(
              color: HmpColors.sand400.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: HmpColors.sand400.withValues(alpha: 0.5 * t),
                blurRadius: 24 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: const Icon(Icons.schedule, size: 26, color: HmpColors.sand400),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.float, required this.label});

  final Animation<double> float;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: float,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -1.5 * float.value),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: HmpColors.sand400.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(HmpRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 7, color: HmpColors.sand400),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: HmpColors.sand400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyButton extends StatelessWidget {
  const _NotifyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: HmpSpacing.buttonV),
        decoration: BoxDecoration(
          color: HmpColors.sand400,
          borderRadius: BorderRadius.circular(HmpRadii.button),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: HmpFonts.ui,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HmpColors.cocoa900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.north_east, size: 16, color: HmpColors.cocoa900),
          ],
        ),
      ),
    );
  }
}
