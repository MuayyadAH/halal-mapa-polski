import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';

/// Custom teardrop map marker (design "Pin" + ANIMATIONS.md §1–2):
/// - drops in on first appearance (460ms easeOutBack, staggered by [dropDelay]);
/// - when [selected], scales to 1.18× (250ms) with a coloured glow and an
///   infinite pulse ring behind it.
/// All motion is disabled under reduced motion (final states rendered).
///
/// Stateful so its animations survive the marker layer's per-frame rebuilds —
/// requires a stable key per pin (provided by `MapMarkerLayer`).
class MapPin extends StatefulWidget {
  const MapPin({
    required this.category,
    this.size = 36,
    this.selected = false,
    this.dropDelay = Duration.zero,
    super.key,
  });

  final Category category;
  final double size;
  final bool selected;
  final Duration dropDelay;

  @override
  State<MapPin> createState() => _MapPinState();
}

class _MapPinState extends State<MapPin> with TickerProviderStateMixin {
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _started = false;
  Timer? _dropTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!_started) {
      _started = true;
      if (reduceMotion) {
        _drop.value = 1;
      } else {
        _dropTimer = Timer(widget.dropDelay, () {
          if (mounted) _drop.forward(from: 0);
        });
      }
    }
    _syncPulse(reduceMotion);
  }

  @override
  void didUpdateWidget(MapPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _syncPulse(MediaQuery.of(context).disableAnimations);
    }
  }

  void _syncPulse(bool reduceMotion) {
    if (widget.selected && !reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _dropTimer?.cancel();
    _drop.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaled = AnimatedScale(
      scale: widget.selected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: _teardrop(),
    );

    final pin = widget.selected
        ? Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [_pulseRing(), scaled],
          )
        : scaled;

    return AnimatedBuilder(
      animation: _drop,
      builder: (context, child) {
        final v = _drop.value;
        final scale = 0.6 + 0.4 * Curves.easeOutBack.transform(v);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * -14),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: pin,
    );
  }

  Widget _pulseRing() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = _pulse.value;
        return Opacity(
          opacity: (0.55 * (1 - t)).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 1 + 0.8 * t,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.category.color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _teardrop() {
    return Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.category.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: HmpColors.cream50, width: 2.5),
          boxShadow: [
            const BoxShadow(
              color: Color(0x59261713),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
            if (widget.selected)
              BoxShadow(
                color: widget.category.color.withValues(alpha: 0.4),
                blurRadius: 18,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Center(
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Text(
              widget.category.glyph,
              style: TextStyle(fontSize: widget.size * 0.44),
            ),
          ),
        ),
      ),
    );
  }
}
