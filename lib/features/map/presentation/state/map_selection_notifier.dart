import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The currently-selected place id (003-map-screen FR-008): drives the pin's
/// selected treatment and the highlighted/scrolled-to mini-card. Single
/// selection; null = nothing selected.
class SelectedPlaceId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;

  void toggle(String id) => state = state == id ? null : id;
}

final selectedPlaceIdProvider =
    NotifierProvider<SelectedPlaceId, String?>(SelectedPlaceId.new);
