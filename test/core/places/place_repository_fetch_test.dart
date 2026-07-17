import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/places/data/place_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDio extends Mock implements Dio {}

const _csv = 'Longitude,Latitude,Name,Category,Comment,Mawaqit Link\n'
    '21.078,52.174,Centrum Kultury Islamu,Meczet,,\n';

Response<String> _resp(String body) => Response<String>(
      data: body,
      requestOptions: RequestOptions(path: '/'),
      statusCode: 200,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Options());
  });

  late _MockDio dio;
  late SharedPreferences prefs;

  setUp(() async {
    dio = _MockDio();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('successful fetch parses and caches the CSV', () async {
    when(() => dio.get<String>(any(), options: any(named: 'options')))
        .thenAnswer((_) async => _resp(_csv));
    final repo = GoogleSheetPlaceRepository(dio, prefs);

    final places = await repo.fetchPlaces();

    expect(places, hasLength(1));
    expect(prefs.getString('places_cache_csv'), _csv);
  });

  test('falls back to cache when the fetch fails', () async {
    SharedPreferences.setMockInitialValues({'places_cache_csv': _csv});
    prefs = await SharedPreferences.getInstance();
    when(() => dio.get<String>(any(), options: any(named: 'options')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '/')));
    final repo = GoogleSheetPlaceRepository(dio, prefs);

    final places = await repo.fetchPlaces();

    expect(places, hasLength(1));
    expect(places.single.name, 'Centrum Kultury Islamu');
  });

  test('rethrows when fetch fails and no cache exists', () async {
    when(() => dio.get<String>(any(), options: any(named: 'options')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '/')));
    final repo = GoogleSheetPlaceRepository(dio, prefs);

    expect(repo.fetchPlaces(), throwsA(isA<DioException>()));
  });
}
