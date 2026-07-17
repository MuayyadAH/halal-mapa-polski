import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import 'mini_map_painter.dart';

/// Live preview of the real map (motion-critical hero). Synthetic basemap +
/// floating category pins + a place-count pill + an "Otwórz mapę" button.
/// Ambient motion (drift / float / pulse / sheen) runs unless reduced motion is
/// on. Tapping anywhere (or the button) calls [onOpenMap]. FR-008/010/011/020.
class MiniMap extends StatefulWidget {
  const MiniMap({super.key, required this.placeCount, required this.onOpenMap});

  final int placeCount;
  final VoidCallback onOpenMap;

  static const double height = 196;

  // Decorative pins: (category, x-fraction, y-fraction). Masjid pulses.
  static const _pins = <(Category, double, double)>[
    (Category.masjid, 0.30, 0.34),
    (Category.restaurant, 0.66, 0.28),
    (Category.shop, 0.50, 0.62),
    (Category.cemetery, 0.80, 0.58),
  ];

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> with TickerProviderStateMixin {
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 16));
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final AnimationController _sheen =
      AnimationController(vsync: this, duration: const Duration(seconds: 7));

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion && !_started) {
      _started = true;
      _drift.repeat(reverse: true);
      _float.repeat(reverse: true);
      _pulse.repeat();
      _sheen.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    _float.dispose();
    _pulse.dispose();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: HmpSpacing.screenH,
      ),
      child: GestureDetector(
        onTap: widget.onOpenMap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: MiniMap.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _basemap(),
                _vignette(),
                _sheenBar(),
                ..._buildPins(),
                _overlayRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _basemap() {
    return AnimatedBuilder(
      animation: _drift,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_drift.value);
        return Transform.translate(
          offset: Offset(-9 * t, -5 * t),
          child: Transform.scale(scale: 1.14, child: child),
        );
      },
      child: const CustomPaint(painter: MiniMapPainter()),
    );
  }

  Widget _vignette() {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.1,
            colors: [Colors.transparent, Color(0x29261713)],
            stops: [0.45, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _sheenBar() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _sheen,
        builder: (context, _) {
          final w = MediaQuery.of(context).size.width;
          final t = Curves.easeInOut.transform(_sheen.value);
          final dx = (-0.7 + 3.9 * t) * w;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: Transform(
              transform: Matrix4.skewX(-0.31),
              child: Container(
                width: w * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0x47FFFFFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPins() {
    final widgets = <Widget>[];
    for (var i = 0; i < MiniMap._pins.length; i++) {
      final (category, fx, fy) = MiniMap._pins[i];
      widgets.add(
        Align(
          alignment: FractionalOffset(fx, fy),
          child: AnimatedBuilder(
            animation: _float,
            builder: (_, child) {
              final phase = (i * 0.25) % 1.0;
              final v = math.sin((_float.value + phase) * math.pi * 2);
              return Transform.translate(
                offset: Offset(0, -1.5 - 1.5 * v),
                child: child,
              );
            },
            child: _Pin(
              category: category,
              pulse: category == Category.masjid ? _pulse : null,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _overlayRow() {
    final l10n = AppLocalizations.of(context);
    return PositionedDirectional(
      start: 12,
      end: 12,
      bottom: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassPill(
            color: const Color(0xD91C201D),
            child: Text(
              l10n.miniMapCount(widget.placeCount),
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: HmpColors.cream50,
              ),
            ),
          ),
          _GlassPill(
            color: const Color(0xF2FBF8EF),
            onTap: widget.onOpenMap,
            child: Text(
              '${l10n.miniMapOpen} ›',
              style: const TextStyle(
                fontFamily: HmpFonts.ui,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: HmpColors.cocoa900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.color, required this.child, this.onTap});
  final Color color;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = ClipRRect(
      borderRadius: BorderRadius.circular(HmpRadii.button),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: color,
          child: child,
        ),
      ),
    );
    if (onTap == null) return pill;
    return Semantics(
      button: true,
      child: GestureDetector(onTap: onTap, child: pill),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.category, this.pulse});
  final Category category;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    final bubble = Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: category.color,
          border: Border.all(color: HmpColors.cream50, width: 2.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(13),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x59261713),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Center(
            child: Text(category.glyph, style: const TextStyle(fontSize: 11)),
          ),
        ),
      ),
    );

    if (pulse == null) {
      return Semantics(label: category.name, child: bubble);
    }
    return Semantics(
      label: category.name,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: pulse!,
            builder: (_, __) {
              final v = pulse!.value;
              return Opacity(
                opacity: (0.5 * (1 - v)).clamp(0.0, 0.5),
                child: Transform.scale(
                  scale: 1 + 1.2 * v,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category.color.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            },
          ),
          bubble,
        ],
      ),
    );
  }
}
