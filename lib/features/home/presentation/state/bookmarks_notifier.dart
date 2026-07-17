import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';

/// Holds the guest bookmark set in memory and writes through to local storage.
/// Optimistic: the UI flips immediately; the async persist reconciles in the
/// background (FR-014).
class BookmarksNotifier extends Notifier<Set<String>> {
  late final BookmarkRepository _repo;

  @override
  Set<String> build() {
    _repo = ref.watch(bookmarkRepositoryProvider);
    return _repo.load();
  }

  bool isBookmarked(String placeId) => state.contains(placeId);

  void toggle(String placeId) {
    final next = Set<String>.from(state);
    if (!next.add(placeId)) next.remove(placeId);
    state = next;
    // Fire-and-forget; storage failure leaves the optimistic state in place.
    _repo.save(next);
  }
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);
