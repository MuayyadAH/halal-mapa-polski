import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:halal_map_polskie/core/prayer_times/mawaqit.dart';

/// Minimal mosque page: confData with today's times + a tiny calendar
/// (six entries per day — shuruq at index 1, as Mawaqit ships it).
String _html({bool calendar = true}) {
  final cal = List.generate(12, (m) {
    return {
      for (var d = 1; d <= 31; d++)
        '$d': ['04:1$m', '05:50', '12:4$m', '16:30', '20:15', '22:00'],
    };
  });
  final conf = {
    'name': 'Meczet Testowy',
    'times': ['04:10', '12:45', '16:30', '20:15', '22:00'],
    'jumua': '13:30',
    if (calendar) 'calendar': cal,
  };
  return '<html><script>var confData = ${jsonEncode(conf)};'
      '</script></html>';
}

void main() {
  group('extractConfData', () {
    test('extracts the balanced JSON object', () {
      final json = extractConfData(_html());
      expect(json, isNotNull);
      expect(jsonDecode(json!), isA<Map<String, Object?>>());
    });

    test('handles braces inside strings', () {
      const html = 'confData = {"name": "Masjid {x}", "times": []};';
      final json = extractConfData(html);
      expect(jsonDecode(json!), {'name': 'Masjid {x}', 'times': <String>[]});
    });

    test('returns null without the marker', () {
      expect(extractConfData('<html>nothing here</html>'), isNull);
    });
  });

  group('parseMawaqitHtml', () {
    test('parses name, today times, jumua and calendar', () {
      final conf = parseMawaqitHtml(_html(), DateTime(2026, 7, 17));
      expect(conf, isNotNull);
      expect(conf!.mosqueName, 'Meczet Testowy');
      expect(conf.todayTimes, hasLength(5));
      expect(conf.jumua, '13:30');
      // Calendar rows are normalized from 6 entries to the 5 prayers
      // (shuruq dropped).
      expect(
        conf.timesFor(DateTime(2026, 3, 12)),
        ['04:12', '12:42', '16:30', '20:15', '22:00'],
      );
    });

    test('malformed page returns null, never throws', () {
      expect(
        parseMawaqitHtml('confData = {broken', DateTime(2026, 1, 1)),
        isNull,
      );
      expect(parseMawaqitHtml('', DateTime(2026, 1, 1)), isNull);
    });

    test('without calendar, times are valid only on the fetch date', () {
      final conf =
          parseMawaqitHtml(_html(calendar: false), DateTime(2026, 7, 17));
      expect(conf!.timesFor(DateTime(2026, 7, 17)), isNotNull);
      expect(conf.timesFor(DateTime(2026, 7, 18)), isNull);
    });
  });

  group('nextPrayer', () {
    final conf = parseMawaqitHtml(_html(), DateTime(2026, 7, 17))!;

    test('mid-day → asr is next', () {
      final next = nextPrayer(conf, DateTime(2026, 7, 17, 13, 0));
      expect(next!.key, 'asr');
      expect(next.at, DateTime(2026, 7, 17, 16, 30));
    });

    test('after isha → tomorrow fajr', () {
      final next = nextPrayer(conf, DateTime(2026, 7, 17, 23, 30));
      expect(next!.key, 'fajr');
      expect(next.at.day, 18);
    });

    test('round-trips through JSON (cache format)', () {
      final restored = MawaqitConf.fromJson(
        jsonDecode(jsonEncode(conf.toJson())) as Map<String, Object?>,
      );
      expect(restored!.mosqueName, conf.mosqueName);
      expect(
        restored.timesFor(DateTime(2026, 3, 12)),
        conf.timesFor(DateTime(2026, 3, 12)),
      );
    });
  });
}
