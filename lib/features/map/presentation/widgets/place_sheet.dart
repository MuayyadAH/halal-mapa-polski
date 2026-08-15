import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/routing/app_router.dart';
import 'package:halal_map_polskie/core/theme/tokens.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';
import 'package:halal_map_polskie/shared/widgets/fade_rise_in.dart';

import '../state/map_providers.dart';
import '../state/map_selection_notifier.dart';
import 'mini_card.dart';

/// The Map bottom place sheet (design "Bottom place sheet"): a grab handle, a
/// header with the visible-place count + an optional "Pokaż listę" link, and a
/// horizontally-scrolling row of [MiniCard]s. Selecting a pin scrolls the
/// matching card into view; tapping a card selects its pin + flies the camera
/// (003-map-screen FR-007/FR-008).
class PlaceSheet extends ConsumerStatefulWidget {
  const PlaceSheet({this.onShowList, super.key});

  /// Switches to the Lista view (wired in US6); the link is hidden when null.
  final VoidCallback? onShowList;

  @override
  ConsumerState<PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends ConsumerState<PlaceSheet>
    with TickerProviderStateMixin {
  static const double _cardWidth = 210;
  static const double _cardGap = 10;

  /// Zoom level when a card is selected — zoom in to it, but never zoom out if
  /// the user is already closer.
  static const double _selectedZoom = 16;

  final _controller = ScrollController();
  late final AnimationController _entrance;
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToSelected(List<Place> places, String? id) {
    if (id == null || !_controller.hasClients) return;
    final i = places.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final target = (i * (_cardWidth + _cardGap))
        .clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _selectCard(Place place) {
    // Second tap on the already-selected card drills into the detail page.
    if (ref.read(selectedPlaceIdProvider) == place.id) {
      context.push(placeDetailLocation(place.id));
      return;
    }
    ref.read(selectedPlaceIdProvider.notifier).select(place.id);
    final engine = ref.read(mapEngineProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final zoom = engine.zoom < _selectedZoom ? _selectedZoom : engine.zoom;
    engine.flyTo(
      lat: place.lat,
      lng: place.lng,
      zoom: zoom,
      animate: !reduceMotion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final places = ref.watch(visiblePlacesProvider);
    final selectedId = ref.watch(selectedPlaceIdProvider);

    ref.listen<String?>(selectedPlaceIdProvider, (_, id) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToSelected(places, id));
    });

    if (places.isEmpty) return const SizedBox.shrink();

    // Slide + fade the sheet up the first time it appears (ANIMATIONS.md §3).
    if (!_entered) {
      _entered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (MediaQuery.of(context).disableAnimations) {
          _entrance.value = 1;
        } else {
          _entrance.forward();
        }
      });
    }

    return FadeRiseIn(
      controller: _entrance,
      start: 0,
      end: 1,
      riseFrom: 30,
      child: Container(
        decoration: BoxDecoration(
          color: HmpColors.cream50,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D261713),
              blurRadius: 36,
              offset: Offset(0, -10),
              spreadRadius: -10,
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x29261713),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.mapPlacesCount(places.length),
                      style: const TextStyle(
                        fontFamily: HmpFonts.display,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: HmpColors.cocoa900,
                      ),
                    ),
                  ),
                  if (widget.onShowList != null)
                    GestureDetector(
                      onTap: widget.onShowList,
                      child: Text(
                        l10n.mapShowList,
                        style: const TextStyle(
                          fontFamily: HmpFonts.ui,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: HmpColors.umber600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: places.length,
                separatorBuilder: (_, __) => const SizedBox(width: _cardGap),
                itemBuilder: (context, i) {
                  final place = places[i];
                  return Align(
                    alignment: Alignment.center,
                    child: MiniCard(
                      place: place,
                      selected: place.id == selectedId,
                      onTap: () => _selectCard(place),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
