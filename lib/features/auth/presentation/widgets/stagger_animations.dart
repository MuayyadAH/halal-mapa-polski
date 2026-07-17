import 'package:flutter/material.dart';

/// Wraps [child] in a fade + vertical rise animation driven by [controller].
/// The [start]..[end] interval (0..1 of the controller) controls when this
/// element appears in the cascade.
class FadeRiseIn extends StatelessWidget {
  const FadeRiseIn({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.riseFrom = 16,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;
  final double riseFrom;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final rise = Tween<double>(begin: riseFrom, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) => Opacity(
        opacity: fade.value,
        child: Transform.translate(
          offset: Offset(0, rise.value),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Wraps [child] in a scale + fade animation. Useful for hero cards that
/// settle into place.
class ScaleFadeIn extends StatelessWidget {
  const ScaleFadeIn({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.scaleFrom = 0.94,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final scale = Tween<double>(begin: scaleFrom, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) => Opacity(
        opacity: fade.value,
        child: Transform.scale(scale: scale.value, child: child),
      ),
      child: child,
    );
  }
}

/// Mixin providing a single [AnimationController] that auto-starts after
/// the first frame, respecting [MediaQuery.disableAnimations] (Reduce
/// Motion accessibility setting per FR-020).
mixin OnboardEntranceController<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController entrance;

  Duration get entranceDuration => const Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    entrance = AnimationController(vsync: this, duration: entranceDuration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        entrance.value = 1.0;
      } else {
        entrance.forward();
      }
    });
  }

  @override
  void dispose() {
    entrance.dispose();
    super.dispose();
  }
}
