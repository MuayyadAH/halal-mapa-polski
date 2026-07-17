import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/cluster.dart';
import 'package:halal_map_polskie/core/map/projection.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';
import 'package:halal_map_polskie/core/places/presentation/category_style.dart';
import 'package:halal_map_polskie/l10n/generated/app_localizations.dart';

import '../state/map_selection_notifier.dart';
import 'cluster_bubble.dart';
import 'map_pin.dart';
import 'user_dot.dart';

/// The marker overlay: teardrop pins, cluster bubbles and the user-location
/// dot, each placed over the basemap by projecting its lat/lng to a screen
/// point for the live [camera] ([latLngToScreen]).
///
/// It rebuilds **only this layer**, scoped to the [camera] listenable, on each
/// camera frame — the cached native map surface is never touched — so the pins
/// track the basemap during pan/zoom. Uses plain `Stack`/`Positioned` layout
/// (idiomatic Flutter); `MapView` owns the camera + engine state.
class MapMarkerLayer extends ConsumerWidget {
  const MapMarkerLayer({
    required this.camera,
    required this.items,
    required this.user,
    required this.onPinTap,
    required this.onClusterTap,
    super.key,
  });

  static const double _pinSize = 36;
  static const double _userDotSize = 44;

  final ValueListenable<CameraSnapshot> camera;
  final List<MapItem> items;
  final LatLng? user;
  final void Function(Place place)? onPinTap;
  final void Function(PlaceCluster cluster) onClusterTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedId = ref.watch(selectedPlaceIdProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return ValueListenableBuilder<CameraSnapshot>(
          valueListenable: camera,
          builder: (context, cam, _) {
            return Stack(
              children: [
                for (var i = 0; i < items.length; i++)
                  _marker(cam, size, items[i], l10n, selectedId, i),
                if (user != null) _userDot(cam, size, user!),
              ],
            );
          },
        );
      },
    );
  }

  Widget _marker(
    CameraSnapshot cam,
    Size size,
    MapItem item,
    AppLocalizations l10n,
    String? selectedId,
    int index,
  ) {
    switch (item) {
      case SinglePlace(:final place):
        final o = latLngToScreen(cam, place.lat, place.lng, size);
        return Positioned(
          // Stable key so the pin's drop/pulse animation state survives the
          // marker layer's per-frame rebuilds.
          key: ValueKey('pin-${place.id}'),
          left: o.dx - _pinSize / 2,
          top: o.dy - _pinSize, // anchor the teardrop tip at the point
          child: Semantics(
            button: true,
            label: '${place.name}, ${place.category.label(l10n)}',
            child: GestureDetector(
              onTap: () => onPinTap?.call(place),
              child: MapPin(
                category: place.category,
                size: _pinSize,
                selected: place.id == selectedId,
                dropDelay: Duration(milliseconds: index * 60),
              ),
            ),
          ),
        );
      case PlaceCluster():
        final o = latLngToScreen(cam, item.lat, item.lng, size);
        final d = ClusterBubble(count: item.count).diameter;
        return Positioned(
          key: ValueKey('cluster-$index'),
          left: o.dx - d / 2,
          top: o.dy - d / 2,
          child: GestureDetector(
            onTap: () => onClusterTap(item),
            child: ClusterBubble(count: item.count),
          ),
        );
    }
  }

  Widget _userDot(CameraSnapshot cam, Size size, LatLng user) {
    final o = latLngToScreen(cam, user.lat, user.lng, size);
    return Positioned(
      left: o.dx - _userDotSize / 2,
      top: o.dy - _userDotSize / 2,
      child: const IgnorePointer(child: UserDot()),
    );
  }
}
