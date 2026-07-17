import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recent_searches_repository.dart';

/// Max number of recent queries kept.
const int kRecentLimit = 8;

/// Recent search queries (most-recent first), persisted locally and **shared**
/// across Home and the Map (003-map-screen FR-018) — one unified history.
class RecentSearches extends Notifier<List<String>> {
  late final RecentSearchesRepository _repo;

  @override
  List<String> build() {
    _repo = ref.watch(recentSearchesRepositoryProvider);
    return _repo.load();
  }

  /// Records [query] at the top (de-duplicated, capped). No-op for blanks.
  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final next = <String>[
      q,
      ...state.where((e) => e.toLowerCase() != q.toLowerCase()),
    ].take(kRecentLimit).toList(growable: false);
    state = next;
    _repo.save(next);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearches, List<String>>(RecentSearches.new);
