import 'package:flutter/material.dart';

/// Fade + vertical-rise entrance for a single block, driven by a shared
/// [controller] over the [start]..[end] interval (0..1). Promoted to
/// `lib/shared/` so any feature can use it without coupling to another feature.
/// Reduced-motion is handled by the owner of the controller (set its value to
/// 1.0 instead of forwarding) — see [EntranceController].
class FadeRiseIn extends StatelessWidget {
  const FadeRiseIn({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.riseFrom = 10,
  });

  final Animation<double> controller;
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
        opacity: fade.value.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, rise.value), child: child),
      ),
      child: child,
    );
  }
}

/// Provides one entrance [AnimationController] that auto-starts after the first
/// frame, honoring `MediaQuery.disableAnimations` (reduced motion): when set,
/// it jumps to the final state instead of animating.
mixin EntranceController<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController entrance;

  Duration get entranceDuration => const Duration(milliseconds: 700);

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
