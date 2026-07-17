import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:halal_map_polskie/core/places/domain/category.dart';
import 'package:halal_map_polskie/core/places/domain/place.dart';

/// Default number of cards in the "Polecane miejsca" row.
const int kFeaturedCap = 10;

/// Deterministic "varied sample across categories" used for the auto-featured
/// row (the data has no featured flag — FR-013). Round-robins one place per
/// category in canonical order until [cap] is reached or places run out.
/// Pure + deterministic for a given input (stable order, no randomness).
List<Place> selectFeatured(List<Place> places, {int cap = kFeaturedCap}) {
  if (places.isEmpty || cap <= 0) return const [];

  // Preserve input order within each category bucket.
  final buckets = <Category, List<Place>>{};
  for (final p in places) {
    (buckets[p.category] ??= <Place>[]).add(p);
  }

  final result = <Place>[];
  final cursors = {for (final c in buckets.keys) c: 0};
  var added = true;
  while (result.length < cap && added) {
    added = false;
    for (final category in Category.values) {
      final bucket = buckets[category];
      if (bucket == null) continue;
      final i = cursors[category]!;
      if (i < bucket.length) {
        result.add(bucket[i]);
        cursors[category] = i + 1;
        added = true;
        if (result.length >= cap) break;
      }
    }
  }
  return result;
}

/// The single mutable Home state: the selected category chip (null = Wszystko).
class SelectedCategory extends Notifier<Category?> {
  @override
  Category? build() => null;

  void select(Category? category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategory, Category?>(SelectedCategory.new);

/// Categories actually present in the loaded data, in canonical order — drives
/// which chips Home shows (FR-005). Empty while loading / on error.
final availableCategoriesProvider = Provider<List<Category>>((ref) {
  final places = ref.watch(placesProvider).value ?? const <Place>[];
  final present = places.map((Place p) => p.category).toSet();
  return Category.values.where(present.contains).toList(growable: false);
});

/// The auto-featured sample, after applying the selected-category filter.
/// Null data (loading/error) yields an empty list; the screen distinguishes
/// loading vs empty via the [placesProvider] AsyncValue.
final featuredVisibleProvider = Provider<List<Place>>((ref) {
  final places = ref.watch(placesProvider).value ?? const <Place>[];
  final selected = ref.watch(selectedCategoryProvider);
  final featured = selectFeatured(places);
  if (selected == null) return featured;
  return featured
      .where((Place p) => p.category == selected)
      .toList(growable: false);
});

/// Total place count for the mini-map pill (FR-011).
final totalPlaceCountProvider = Provider<int>((ref) {
  return ref.watch(placesProvider).value?.length ?? 0;
});
