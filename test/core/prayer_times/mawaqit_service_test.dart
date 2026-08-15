import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halal_map_polskie/core/prayer_times/mawaqit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _url = 'https://mawaqit.net/pl/test-mosque';

String _html() {
  final cal = List.generate(12, (m) {
    return {
      for (var d = 1; d <= 31; d++)
        '$d': ['04:00', '05:50', '12:45', '16:30', '20:15', '22:00'],
    };
  });
  final conf = {
    'name': 'Meczet Testowy',
    'times': ['04:00', '12:45', '16:30', '20:15', '22:00'],
    'jumua': '13:30',
    'calendar': cal,
  };
  return '<html><script>var confData = ${jsonEncode(conf)};</script></html>';
}

/// Scripted Dio adapter: serves [body] or throws a connection error when null.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  String? body;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final b = body;
    if (b == null) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      b,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/html'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<(HttpMawaqitRepository, _FakeAdapter, SharedPreferences)> _repo({
  String? body,
  DateTime? now,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final adapter = _FakeAdapter(body);
  final dio = Dio()..httpClientAdapter = adapter;
  final repo = HttpMawaqitRepository(
    dio,
    prefs,
    clock: () => now ?? DateTime(2026, 7, 17, 10),
  );
  return (repo, adapter, prefs);
}

void main() {
  test('fetches, parses and caches the conf', () async {
    final (repo, adapter, _) = await _repo(body: _html());

    final conf = await repo.confFor(_url);
    expect(conf!.mosqueName, 'Meczet Testowy');
    expect(adapter.calls, 1);

    // Second call is served from cache — no network hit.
    final again = await repo.confFor(_url);
    expect(again!.mosqueName, 'Meczet Testowy');
    expect(adapter.calls, 1);
  });

  test('offline with a cached calendar still returns times', () async {
    final (repo, adapter, prefs) = await _repo(body: _html());
    await repo.confFor(_url);

    // Same prefs, new repo, network down.
    adapter.body = null;
    final offlineRepo = HttpMawaqitRepository(
      Dio()..httpClientAdapter = adapter,
      prefs,
      clock: () => DateTime(2026, 11, 3, 9), // months later — calendar covers
    );
    final conf = await offlineRepo.confFor(_url);
    expect(conf, isNotNull);
    expect(conf!.timesFor(DateTime(2026, 11, 3)), isNotNull);
  });

  test('offline with no cache returns null (no throw)', () async {
    final result = await _repo(body: null);
    expect(await result.$1.confFor(_url), isNull);
  });
}
