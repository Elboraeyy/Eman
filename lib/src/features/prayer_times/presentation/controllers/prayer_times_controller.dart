import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zad/src/core/database/shared_preferences_provider.dart';
import '../../domain/entities/prayer_entities.dart';
import '../../data/repositories/prayer_repository_provider.dart';

final locationProvider = FutureProvider<UserLocation?>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  return await repo.getCurrentLocation();
});

final todayPrayerTimesProvider = FutureProvider<PrayerTimes?>((ref) async {
  final locationAsync = ref.watch(locationProvider);
  final location = locationAsync.value;
  final repo = ref.watch(prayerRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final method = prefs.getInt('prayer_calculation_method') ?? 5;
  
  final now = DateTime.now();
  
  if (location == null) {
    // Fallback to Mecca (coordinates: 21.422487, 39.826206)
    return await repo.getPrayerTimesForDate(
      latitude: 21.422487,
      longitude: 39.826206,
      date: now,
      method: method,
    );
  }
  
  return await repo.getPrayerTimesForDate(
    latitude: location.latitude,
    longitude: location.longitude,
    date: now,
    method: method,
  );
});

