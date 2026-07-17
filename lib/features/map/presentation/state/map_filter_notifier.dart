import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

/// The single shared category filter (003-map-screen FR-011/FR-012). Empty set
/// = "Wszystko" (all). Chips are quick single-select shortcuts; the filter
/// sheet multi-selects the same set.
class ActiveCategories extends Notifier<Set<Category>> {
  @override
  Set<Category> build() => const {};

  /// Chip quick-select → just this category.
  void selectOnly(Category category) => state = {category};

  /// "Wszystko" → clear (all categories visible).
  void clear() => state = const {};

  /// Filter-sheet multi-select toggle.
  void toggle(Category category) {
    final next = {...state};
    if (!next.add(category)) next.remove(category);
    state = next;
  }
}

final activeCategoriesProvider =
    NotifierProvider<ActiveCategories, Set<Category>>(ActiveCategories.new);

/// Categories present in the loaded data, in canonical order — drives which
/// chips/filter rows are shown (FR-011). Empty while loading / on error.
final availableCategoriesProvider = Provider<List<Category>>((ref) {
  final places = ref.watch(placesProvider).value ?? const <Place>[];
  final present = places.map((Place p) => p.category).toSet();
  return Category.values.where(present.contains).toList(growable: false);
});
