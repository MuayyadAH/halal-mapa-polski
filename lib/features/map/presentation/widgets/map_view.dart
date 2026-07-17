import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/location/location_service.dart';
import 'package:halal_map_polskie/core/map/cluster.dart';
import 'package:halal_map_polskie/core/map/map_engine.dart';
import 'package:halal_map_polskie/core/map/projection.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

import '../state/map_providers.dart';
import 'map_marker_layer.dart';

/// The interactive map surface: the [MapEngine] basemap with a [MapMarkerLayer]
/// composited on top.
///
/// This widget owns the camera + engine state. The native surface is built once
/// (it does not depend on the camera) and cached; the live camera is held in a
/// [ValueNotifier] that the marker layer listens to, so each camera frame only
/// re-places the markers — it never rebuilds `MapView` or reconfigures the
/// native view (003-map-screen R3). Re-clustering is deferred until movement
/// settles so pins keep a stable identity mid-gesture.
class MapView extends ConsumerStatefulWidget {
  const MapView({
    required this.initialLat,
    required this.initialLng,
    required this.initialZoom,
    required this.styleJson,
    this.onPinTap,
    this.onMapTap,
    super.key,
  });

  final double initialLat;
  final double initialLng;
  final double initialZoom;
  final String styleJson;
  final void Function(Place place)? onPinTap;
  final VoidCallback? onMapTap;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  late final ValueNotifier<CameraSnapshot> _camera;
  bool _centeredOnUser = false;
  Timer? _reclusterTimer;
  Widget? _mapSurface;

  @override
  void initState() {
    super.initState();
    _camera = ValueNotifier(
      CameraSnapshot(
        centerLat: widget.initialLat,
        centerLng: widget.initialLng,
        zoom: widget.initialZoom,
      ),
    );
  }

  @override
  void dispose() {
    _reclusterTimer?.cancel();
    _camera.dispose();
    super.dispose();
  }

  void _onCameraChanged(CameraSnapshot camera) {
    // Repaint-only reposition (drives the marker layer's listenable).
    _camera.value = camera;
    // Defer re-clustering until movement settles so pins don't pop between
    // clustered/unclustered mid-gesture.
    _reclusterTimer?.cancel();
    _reclusterTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) ref.read(mapZoomProvider.notifier).set(camera.zoom);
    });
  }

  void _onClusterTap(PlaceCluster cluster) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    ref.read(mapEngineProvider).flyTo(
          lat: cluster.lat,
          lng: cluster.lng,
          zoom: _camera.value.zoom + 2,
          animate: !reduceMotion,
        );
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(mapEngineProvider);
    final items = ref.watch(clusterLayerProvider);
    final user = ref.watch(userLatLngProvider);

    if (user != null && !_centeredOnUser) {
      _centeredOnUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        engine.recenterOn(
          lat: user.lat,
          lng: user.lng,
          zoom: _camera.value.zoom,
        );
      });
    }

    _mapSurface ??= engine.buildMap(
      initialCamera: CameraTarget(
        lat: widget.initialLat,
        lng: widget.initialLng,
        zoom: widget.initialZoom,
      ),
      styleJson: widget.styleJson,
      onCameraChanged: _onCameraChanged,
      onTapMap: (_, __) => widget.onMapTap?.call(),
    );

    return Stack(
      children: [
        Positioned.fill(child: RepaintBoundary(child: _mapSurface!)),
        Positioned.fill(
          child: RepaintBoundary(
            child: MapMarkerLayer(
              camera: _camera,
              items: items,
              user: user,
              onPinTap: widget.onPinTap,
              onClusterTap: _onClusterTap,
            ),
          ),
        ),
      ],
    );
  }
}
