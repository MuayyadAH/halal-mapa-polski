import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/links/external_link_launcher.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

/// About-screen identity card (004-profile-screen FR-013): a white card with a
/// gradient map-pin tile (ambient glow), the app name, a version line, and the
/// mission paragraph. Glow honors reduced motion (FR-018).
class AppMarkCard extends StatefulWidget {
  const AppMarkCard({super.key});

  @override
  State<AppMarkCard> createState() => _AppMarkCardState();
}

class _AppMarkCardState extends State<AppMarkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!MediaQuery.of(context).disableAnimations) _glow.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: HmpColors.cream50,
          borderRadius: BorderRadius.circular(HmpRadii.card),
          border: Border.all(color: const Color(0x0D261713)),
          boxShadow: HmpShadows.card,
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (_, child) => Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [HmpColors.catMosque, HmpColors.cocoa800],
                  ),
                  borderRadius: BorderRadius.circular(HmpRadii.card),
                  boxShadow: [
                    BoxShadow(
                      color: HmpColors.catMosque
                          .withValues(alpha: 0.5 * _glow.value),
                      blurRadius: 24 * _glow.value,
                    ),
                  ],
                ),
                child: child,
              ),
              child: const Icon(Icons.place, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.appTitle,
              style: const TextStyle(
                fontFamily: HmpFonts.display,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: HmpColors.cocoa900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.versionLine(AppInfo.version),
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 12,
                color: HmpColors.umber600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.appMission,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontSize: 13.5,
                height: 1.45,
                color: HmpColors.cocoa700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
