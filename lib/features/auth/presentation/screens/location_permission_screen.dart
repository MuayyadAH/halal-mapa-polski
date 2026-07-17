import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../../core/permissions/permissions_service.dart';
import '../../../../core/theme/tokens.dart';
import '../state/onboarding_notifier.dart';
import '../widgets/language_picker.dart';
import '../widgets/soft_bg.dart';

/// The location pre-prompt shown when the user taps "Kontynuuj" on
/// Onboard 3 and the OS-level location decision is still pending (FR-010).
class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  Future<void> _allow(BuildContext context, WidgetRef ref) async {
    // Trigger the OS prompt — outcome is silent per FR-014 (Map handles
    // denial with a wide Poland view).
    await ref.read(permissionsServiceProvider).requestLocationWhenInUse();
    if (!context.mounted) return;
    await _completeAndGoHome(context, ref);
  }

  Future<void> _notNow(BuildContext context, WidgetRef ref) async {
    await _completeAndGoHome(context, ref);
  }

  Future<void> _completeAndGoHome(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingNotifierProvider.notifier).complete();
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SoftBg(),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HmpSpacing.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top chrome: language picker (FR-004 — every onboarding screen).
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: HmpSpacing.chromeV),
                    child: Row(
                      children: [Spacer(), LanguagePicker()],
                    ),
                  ),

                  const Spacer(),

                  // Decorative icon — pin emoji on cocoa-tinted circle.
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: HmpColors.cocoa800.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 40,
                      color: HmpColors.cocoa800,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    l10n.locationPermissionTitle,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.locationPermissionSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const Spacer(flex: 2),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _allow(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: HmpColors.cocoa800,
                        foregroundColor: HmpColors.cream50,
                        padding: const EdgeInsets.symmetric(
                          vertical: HmpSpacing.buttonV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(HmpRadii.button),
                        ),
                      ),
                      child: Text(l10n.locationPermissionAllow),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _notNow(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: HmpColors.cocoa700,
                        padding: const EdgeInsets.symmetric(
                          vertical: HmpSpacing.buttonV,
                        ),
                      ),
                      child: Text(l10n.locationPermissionNotNow),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
