import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/onboarding_state.dart';
import '../state/onboarding_notifier.dart';
import '../widgets/soft_bg.dart';

/// First screen on every cold launch.
///
/// Animation choreography (per `Animated Onboarding.html` source):
/// - 0–850 ms : pin teardrop strokes in (path-draw effect)
/// - 280–880 ms : pin fill fades + scales in
/// - 520–1020 ms : crescent scales in inside the pin
/// - 900–1400 ms : "Halal Map / Polskie" wordmark fades up
/// - 1500–2000 ms : "Ładowanie" loader fades up + spins
///
/// For returning users we run the same timeline but scaled to ~1s.
/// When OS-level Reduce Motion is enabled, the animation is skipped and
/// the route advances on the first post-frame callback (FR-020).
class AnimatedSplashScreen extends ConsumerStatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  ConsumerState<AnimatedSplashScreen> createState() =>
      _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends ConsumerState<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _spinner;

  late final Animation<double> _strokeProgress;
  late final Animation<double> _fillFade;
  late final Animation<double> _crescentScale;
  late final Animation<double> _wordmarkFade;
  late final Animation<double> _wordmarkRise;
  late final Animation<double> _loaderFade;

  bool _hasRouted = false;

  @override
  void initState() {
    super.initState();

    final completed = ref.read(onboardingNotifierProvider).status ==
        OnboardingStatus.completed;
    // First-time users get the full 2200ms timeline; returning users
    // get a truncated 1000ms version. Same choreography, different scale.
    final duration = completed
        ? const Duration(milliseconds: 1000)
        : const Duration(milliseconds: 2200);

    _controller = AnimationController(vsync: this, duration: duration);
    _spinner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Timeline normalised to 0..1 of the controller duration.
    // First-time mapping (2200ms total) — same fractions used for returning.
    _strokeProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.39, curve: Curves.easeOutCubic),
    );
    _fillFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.13, 0.40, curve: Curves.easeOut),
    );
    _crescentScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.46, curve: Curves.easeOutBack),
    );
    _wordmarkFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.41, 0.64, curve: Curves.easeOut),
    );
    _wordmarkRise = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.41, 0.64, curve: Curves.easeOutCubic),
      ),
    );
    _loaderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.68, 0.91, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);
  }

  Future<void> _onFirstFrame(Duration _) async {
    if (!mounted) return;
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) {
      _controller.value = 1.0;
      _routeNext();
      return;
    }
    await _controller.forward();
    _routeNext();
  }

  void _routeNext() {
    if (_hasRouted || !mounted) return;
    _hasRouted = true;
    final completed = ref.read(onboardingNotifierProvider).status ==
        OnboardingStatus.completed;
    context.go(completed ? '/home' : '/onboarding/intro');
  }

  @override
  void dispose() {
    _controller.dispose();
    _spinner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft warm gradient + blobs — fills behind the status bar too.
          const SoftBg(),
          SafeArea(
            child: Stack(
              children: [
                // Centered brand mark + wordmark stack.
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return SizedBox(
                            width: 132,
                            height: 132,
                            child: CustomPaint(
                              painter: _BrandMarkPainter(
                                strokeProgress: _strokeProgress.value,
                                fillOpacity: _fillFade.value,
                                crescentScale: _crescentScale.value,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => Opacity(
                          opacity: _wordmarkFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _wordmarkRise.value),
                            child: const _Wordmark(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Loader at the bottom — fades in last.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 64,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Opacity(
                      opacity: _loaderFade.value,
                      child: _Loader(
                        label: l10n.splashLoading,
                        spinner: _spinner,
                      ),
                    ),
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

/// The animated pin teardrop + crescent. Strokes in over time, the fill
/// fades in, and the crescent scales in last.
class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter({
    required this.strokeProgress,
    required this.fillOpacity,
    required this.crescentScale,
  });

  /// 0..1, controls how much of the pin outline has been drawn.
  final double strokeProgress;

  /// 0..1, opacity of the cocoa gradient fill.
  final double fillOpacity;

  /// 0..1, scale of the crescent (sand + cocoa) inside the pin.
  final double crescentScale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 4);

    // Pin teardrop path matches design SVG:
    //   M -50 -50 A 50 50 0 1 1 -50 50 Z
    final pin = Path()
      ..moveTo(-50, -50)
      ..arcToPoint(
        const Offset(-50, 50),
        radius: const Radius.circular(50),
        largeArc: true,
      )
      ..close();

    // Cocoa gradient fill (fade in).
    if (fillOpacity > 0) {
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HmpColors.cocoa800, HmpColors.cocoa950],
        ).createShader(const Rect.fromLTWH(-50, -50, 100, 100))
        ..color = HmpColors.cocoa800.withValues(alpha: fillOpacity);
      canvas.saveLayer(const Rect.fromLTWH(-60, -60, 120, 120), Paint());
      canvas.drawPath(pin, fillPaint);
      canvas.drawColor(
        Colors.white.withValues(alpha: 1 - fillOpacity),
        BlendMode.dstOut,
      );
      canvas.restore();
    }

    // Sand stroke that draws around the perimeter as strokeProgress advances.
    if (strokeProgress > 0) {
      final strokePaint = Paint()
        ..color = HmpColors.sand400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final metrics = pin.computeMetrics().toList();
      final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
      final targetLength = totalLength * strokeProgress;

      final partial = Path();
      var consumed = 0.0;
      for (final m in metrics) {
        if (consumed >= targetLength) break;
        final take = math.min(m.length, targetLength - consumed);
        partial.addPath(m.extractPath(0, take), Offset.zero);
        consumed += take;
      }
      canvas.drawPath(partial, strokePaint);
    }

    // Crescent: two overlapping circles, sand background + cocoa offset.
    // The parent canvas is rotated -45°; rotate +45° back so the crescent
    // reads upright.
    if (crescentScale > 0) {
      canvas.save();
      canvas.rotate(math.pi / 4);
      canvas.scale(crescentScale);

      final sandPaint = Paint()..color = HmpColors.sand400;
      final cocoaPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HmpColors.cocoa800, HmpColors.cocoa950],
        ).createShader(const Rect.fromLTWH(-22, -22, 44, 44));

      canvas.drawCircle(Offset.zero, 22, sandPaint);
      canvas.drawCircle(const Offset(6, 0), 22, cocoaPaint);

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) =>
      old.strokeProgress != strokeProgress ||
      old.fillOpacity != fillOpacity ||
      old.crescentScale != crescentScale;
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Halal Map\n',
            style: TextStyle(
              fontFamily: HmpFonts.display,
              fontFamilyFallback: [HmpFonts.arabic],
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: HmpColors.cocoa900,
              letterSpacing: -0.3,
              height: 1.05,
            ),
          ),
          TextSpan(
            text: 'Polskie',
            style: TextStyle(
              fontFamily: HmpFonts.display,
              fontFamilyFallback: [HmpFonts.arabic],
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: HmpColors.umber600,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader({required this.label, required this.spinner});

  final String label;
  final AnimationController spinner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: spinner,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: _ArcLoaderPainter(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: HmpFonts.mono,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: HmpColors.umber600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A 3/4 arc circle in the umber colour — matches the design's loader glyph.
class _ArcLoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HmpColors.umber600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      0,
      math.pi * 1.5, // 270 degrees — leaves a 90° gap for the spin to read
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcLoaderPainter old) => false;
}
