import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/search/recent_searches_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('round-trips queries, most-recent-first order preserved', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPrefsRecentSearchesRepository(prefs);

    expect(repo.load(), isEmpty);
    await repo.save(['karim', 'meczet']);
    expect(repo.load(), ['karim', 'meczet']);

    // A second repo over the same store reads the unified history.
    final repo2 = SharedPrefsRecentSearchesRepository(prefs);
    expect(repo2.load(), ['karim', 'meczet']);
  });
}
