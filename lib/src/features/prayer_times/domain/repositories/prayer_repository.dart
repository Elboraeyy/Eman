import '../entities/prayer_entities.dart';

abstract class PrayerRepository {
  Future<PrayerTimes?> getPrayerTimesForDate({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 5,
  });

  Future<List<PrayerTimes>> getPrayerTimesForMonth({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
    int method = 5,
  });

  Future<UserLocation?> getCurrentLocation();
}
