import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/prayer_entities.dart';
import '../../domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  PrayerRepositoryImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<UserLocation?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // Default city name to coords as reverse-geocoding requires a paid service or extra package.
      // We will write a readable string like "موقعي الحالي" (My Current Location).
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'موقعي الحالي',
      );
    } catch (e) {
      print('PrayerRepositoryImpl: Location check failed: $e');
      return null;
    }
  }

  @override
  Future<List<PrayerTimes>> getPrayerTimesForMonth({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
    int method = 5,
  }) async {
    final latRounded = latitude.toStringAsFixed(2);
    final lngRounded = longitude.toStringAsFixed(2);
    final cacheKey = 'prayer_calendar_${latRounded}_${lngRounded}_${year}_${month}_$method';

    // 1. Check offline cache in SharedPreferences
    final cachedData = sharedPreferences.getString(cacheKey);
    if (cachedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((item) => PrayerTimes.fromJson(item)).toList();
      } catch (e) {
        print('PrayerRepositoryImpl: Error parsing cached calendar: $e');
      }
    }

    // 2. Fetch from Aladhan API if not cached
    try {
      final response = await dio.get(
        'https://api.aladhan.com/v1/calendar',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'month': month,
          'year': year,
          'method': method,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'];
        
        final prayerTimesList = dataList.map((dayData) {
          final timings = dayData['timings'] as Map<String, dynamic>;
          final dateInfo = dayData['date']['gregorian'];
          final apiDate = dateInfo['date'] as String; // "DD-MM-YYYY"
          
          // Convert "DD-MM-YYYY" to "YYYY-MM-DD"
          final parts = apiDate.split('-');
          final formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';

          return PrayerTimes.fromJson({
            'date': formattedDate,
            'timings': timings,
          });
        }).toList();

        // Save to cache
        final jsonList = prayerTimesList.map((p) => p.toJson()).toList();
        await sharedPreferences.setString(cacheKey, jsonEncode(jsonList));

        return prayerTimesList;
      }
    } catch (e) {
      print('PrayerRepositoryImpl: Failed to fetch calendar from network: $e');
    }

    return [];
  }

  @override
  Future<PrayerTimes?> getPrayerTimesForDate({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 5,
  }) async {
    final monthList = await getPrayerTimesForMonth(
      latitude: latitude,
      longitude: longitude,
      month: date.month,
      year: date.year,
      method: method,
    );

    if (monthList.isEmpty) return null;

    final targetDateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final match = monthList.where((pt) => pt.date == targetDateStr);
    
    return match.isNotEmpty ? match.first : null;
  }
}
