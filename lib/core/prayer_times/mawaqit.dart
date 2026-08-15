import 'dart:convert';

/// Pure Mawaqit data model + parsing. A mosque's Mawaqit page embeds a
/// `confData` JSON object with today's five prayer times and (usually) a full
/// yearly calendar. This file is UI- and IO-free; fetching/caching lives in
/// `mawaqit_service.dart`.
///
/// Prayer keys follow canonical transliteration (constitution §5.4):
/// fajr, dhuhr, asr, maghrib, isha.
class MawaqitConf {
  const MawaqitConf({
    required this.fetchedOn,
    this.mosqueName,
    this.todayTimes,
    this.calendar,
    this.jumua,
  });

  /// Local date the page was fetched (calendar-day resolution).
  final DateTime fetchedOn;

  final String? mosqueName;

  /// Today's five times ("HH:mm"), valid only for [fetchedOn]'s date.
  final List<String>? todayTimes;

  /// Yearly calendar: 12 maps (Jan..Dec), day-of-month key ("1".."31") →
  /// five "HH:mm" times. Null when the page ships no calendar.
  final List<Map<String, List<String>>>? calendar;

  /// Jumu'ah time ("HH:mm"), when published.
  final String? jumua;

  /// Five "HH:mm" times for [date], or null when not covered (no calendar and
  /// [date] is not the fetch date).
  List<String>? timesFor(DateTime date) {
    final cal = calendar;
    if (cal != null && cal.length == 12) {
      final month = cal[date.month - 1];
      final t = month['${date.day}'];
      if (t != null && t.length == 5) return t;
    }
    final today = todayTimes;
    if (today != null && _sameDate(date, fetchedOn)) return today;
    return null;
  }

  Map<String, Object?> toJson() => {
        'fetchedOn': fetchedOn.toIso8601String(),
        'mosqueName': mosqueName,
        'todayTimes': todayTimes,
        'calendar': calendar,
        'jumua': jumua,
      };

  static MawaqitConf? fromJson(Map<String, Object?> json) {
    final fetchedOn = DateTime.tryParse(json['fetchedOn'] as String? ?? '');
    if (fetchedOn == null) return null;
    return MawaqitConf(
      fetchedOn: fetchedOn,
      mosqueName: json['mosqueName'] as String?,
      todayTimes: _stringList(json['todayTimes']),
      calendar: _calendarFromJson(json['calendar']),
      jumua: json['jumua'] as String?,
    );
  }
}

/// Ordered prayer keys matching the five-entry time lists.
const kPrayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

/// The next upcoming prayer relative to [now], searching today then tomorrow.
/// Null when the conf covers neither day.
({String key, DateTime at})? nextPrayer(MawaqitConf conf, DateTime now) {
  for (final dayOffset in const [0, 1]) {
    final date = DateTime(now.year, now.month, now.day + dayOffset);
    final times = conf.timesFor(date);
    if (times == null) continue;
    for (var i = 0; i < kPrayerKeys.length; i++) {
      final at = parseHm(times[i], date);
      if (at != null && at.isAfter(now)) {
        return (key: kPrayerKeys[i], at: at);
      }
    }
  }
  return null;
}

/// "HH:mm" → DateTime on [date]'s calendar day; null on malformed input.
DateTime? parseHm(String hm, DateTime date) {
  final parts = hm.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h > 23 || m > 59) return null;
  return DateTime(date.year, date.month, date.day, h, m);
}

/// Extracts and parses the embedded `confData` object from a Mawaqit mosque
/// page. Returns null when the marker is missing or the JSON is malformed —
/// never throws (the page layout is not under our control).
MawaqitConf? parseMawaqitHtml(String html, DateTime fetchedOn) {
  final json = extractConfData(html);
  if (json == null) return null;

  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, Object?>) return null;

  final times = _stringList(decoded['times']);
  return MawaqitConf(
    fetchedOn: DateTime(fetchedOn.year, fetchedOn.month, fetchedOn.day),
    mosqueName: decoded['name'] as String?,
    todayTimes: (times != null && times.length == 5) ? times : null,
    calendar: _calendarFromJson(decoded['calendar']),
    jumua: decoded['jumua'] as String?,
  );
}

/// Balanced-brace extraction of the `confData = {...}` object (regex can't
/// handle the nested braces).
String? extractConfData(String html) {
  final marker = html.indexOf('confData');
  if (marker < 0) return null;
  final start = html.indexOf('{', marker);
  if (start < 0) return null;

  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = start; i < html.length; i++) {
    final ch = html[i];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (ch == r'\') {
      escaped = true;
      continue;
    }
    if (ch == '"') {
      inString = !inString;
      continue;
    }
    if (inString) continue;
    if (ch == '{') depth++;
    if (ch == '}') {
      depth--;
      if (depth == 0) return html.substring(start, i + 1);
    }
  }
  return null;
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<String>? _stringList(Object? value) {
  if (value is! List) return null;
  final out = <String>[];
  for (final v in value) {
    if (v is! String) return null;
    out.add(v);
  }
  return out;
}

/// Mawaqit calendars carry six entries per day (shuruq at index 1); normalize
/// to the five canonical prayers. Malformed months/days are dropped.
List<Map<String, List<String>>>? _calendarFromJson(Object? value) {
  if (value is! List || value.length != 12) return null;
  final months = <Map<String, List<String>>>[];
  for (final month in value) {
    if (month is! Map) return null;
    final days = <String, List<String>>{};
    for (final entry in month.entries) {
      final t = _stringList(entry.value);
      if (t == null) continue;
      if (t.length == 6) {
        days['${entry.key}'] = [t[0], t[2], t[3], t[4], t[5]];
      } else if (t.length == 5) {
        days['${entry.key}'] = t;
      }
    }
    months.add(days);
  }
  return months;
}
