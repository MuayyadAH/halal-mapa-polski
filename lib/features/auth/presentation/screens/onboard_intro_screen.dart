import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/tokens.dart';
import '../state/onboarding_notifier.dart';
import '../widgets/language_picker.dart';
import '../widgets/onboard_page_indicator.dart';
import '../widgets/soft_bg.dart';
import 'onboard_community_screen.dart';
import 'onboard_find_screen.dart';
import 'onboard_trust_screen.dart';

/// The three-page intro shell. Hosts the [PageView] containing Onboard 1/2/3
/// plus shared chrome: language picker (top-right, always), skip link
/// (top-left, on pages 0 and 1), page indicator (bottom-center), and the
/// primary CTA(s) (Dalej for pages 0/1, Kontynuuj + Przeglądaj jako gość
/// for page 2).
class OnboardIntroScreen extends ConsumerStatefulWidget {
  const OnboardIntroScreen({super.key});

  @override
  ConsumerState<OnboardIntroScreen> createState() => _OnboardIntroScreenState();
}

class _OnboardIntroScreenState extends ConsumerState<OnboardIntroScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();

    final initialPage = ref.read(onboardingNotifierProvider).currentIntroPage;
    _controller = PageController(initialPage: initialPage);

    // Mark the flow as in-progress *after* the build completes — mutating a
    // provider during initState is forbidden in Riverpod 3.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(onboardingNotifierProvider.notifier).enterFlow();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSkip() {
    _controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onNext() {
    final current = ref.read(onboardingNotifierProvider).currentIntroPage;
    _controller.animateToPage(
      current + 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _onContinue() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    // FR-010 — skip pre-prompt if user has previously decided.
    //
    // iOS caveat: on first launch iOS returns `denied`, not `notDetermined`
    // like Android. The check below treats `permanentlyDenied` as decided,
    // which is correct on Android but may need refinement on iOS once an
    // iOS builder exists. Verify on a physical iPhone before App Store
    // submission.
    if (status.isGranted || status.isLimited || status.isPermanentlyDenied) {
      await ref.read(onboardingNotifierProvider.notifier).complete();
      if (!mounted) return;
      context.go('/home');
    } else {
      context.go('/onboarding/location');
    }
  }

  Future<void> _onBrowseAsGuest() async {
    await ref.read(onboardingNotifierProvider.notifier).complete();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentPage = ref.watch(onboardingNotifierProvider).currentIntroPage;
    final canSkip = currentPage < 2;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SoftBg(),
          SafeArea(
            child: Column(
              children: [
                // Top chrome: skip link + language picker
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HmpSpacing.screenH,
                    vertical: HmpSpacing.chromeV,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (canSkip)
                        TextButton(
                          onPressed: _onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: HmpColors.umber600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          child: Text(l10n.onboardingSkip),
                        )
                      else
                        const SizedBox(width: 60),
                      const Spacer(),
                      const LanguagePicker(),
                    ],
                  ),
                ),

                // The three pages
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (page) => ref
                        .read(onboardingNotifierProvider.notifier)
                        .setCurrentPage(page),
                    children: const [
                      OnboardFindScreen(),
                      OnboardTrustScreen(),
                      OnboardCommunityScreen(),
                    ],
                  ),
                ),

                // Bottom chrome: indicator + CTA(s)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    HmpSpacing.screenH,
                    HmpSpacing.chromeV,
                    HmpSpacing.screenH,
                    24,
                  ),
                  child: Column(
                    children: [
                      OnboardPageIndicator(currentPage: currentPage),
                      const SizedBox(height: 20),
                      if (currentPage < 2)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _onNext,
                            style: FilledButton.styleFrom(
                              backgroundColor: HmpColors.cocoa800,
                              foregroundColor: HmpColors.cream50,
                              padding: const EdgeInsets.symmetric(
                                vertical: HmpSpacing.buttonV,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(HmpRadii.button),
                              ),
                            ),
                            child: Text(l10n.onboardingNext),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _onContinue,
                            style: FilledButton.styleFrom(
                              backgroundColor: HmpColors.cocoa800,
                              foregroundColor: HmpColors.cream50,
                              padding: const EdgeInsets.symmetric(
                                vertical: HmpSpacing.buttonV,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(HmpRadii.button),
                              ),
                            ),
                            child: Text(l10n.onboardingContinue),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: _onBrowseAsGuest,
                          style: TextButton.styleFrom(
                            foregroundColor: HmpColors.cocoa800,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            l10n.onboardingBrowseAsGuest,
                            style: const TextStyle(
                              fontFamily: HmpFonts.ui,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
