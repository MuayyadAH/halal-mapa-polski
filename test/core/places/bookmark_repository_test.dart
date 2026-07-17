import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/places/data/bookmark_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load returns empty when nothing stored', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPrefsBookmarkRepository(prefs);
    expect(repo.load(), isEmpty);
  });

  test('save then load round-trips the set', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPrefsBookmarkRepository(prefs);

    await repo.save({'a', 'b'});

    final repo2 = SharedPrefsBookmarkRepository(prefs);
    expect(repo2.load(), {'a', 'b'});
  });

  test('save overwrites the previous set', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPrefsBookmarkRepository(prefs);

    await repo.save({'a', 'b'});
    await repo.save({'c'});

    expect(repo.load(), {'c'});
  });
}
