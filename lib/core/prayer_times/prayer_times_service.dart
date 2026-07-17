import 'package:flutter_riverpod/flutter_riverpod.dart';

final prayerTimesServiceProvider =
    Provider<PrayerTimesService>((_) => const PrayerTimesService());

/// Stub. Real Adhan calculation lands when the masjid feature is implemented.
class PrayerTimesService {
  const PrayerTimesService();

  DailyPrayerTimes? todayFor({
    required String city,
    required Madhab madhab,
  }) {
    return null;
  }
}

/// Inlined here at scaffold stage; moves to a shared domain enum
/// when the masjid feature lands.
enum Madhab { sunni, shia, other }

class DailyPrayerTimes {
  const DailyPrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
}
