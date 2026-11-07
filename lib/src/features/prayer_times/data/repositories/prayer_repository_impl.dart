import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  UserLocation? _getCachedLocation() {
    try {
      final double? lat = sharedPreferences.getDouble('cached_latitude');
      final double? lng = sharedPreferences.getDouble('cached_longitude');
      final String? cityName = sharedPreferences.getString('cached_city_name');
      if (lat != null && lng != null && cityName != null) {
        return UserLocation(
          latitude: lat,
          longitude: lng,
          cityName: cityName,
        );
      }
    } catch (e) {
      debugPrint('Failed to get cached location: $e');
    }
    return null;
  }

  Future<void> _cacheLocation(UserLocation userLoc) async {
    try {
      await sharedPreferences.setDouble('cached_latitude', userLoc.latitude);
      await sharedPreferences.setDouble('cached_longitude', userLoc.longitude);
      await sharedPreferences.setString('cached_city_name', userLoc.cityName);
    } catch (e) {
      debugPrint('Failed to cache location: $e');
    }
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getCachedLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return _getCachedLocation();
      }

      // Try to get last known position first (fast & offline cached)
      Position? position = await Geolocator.getLastKnownPosition();

      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Reverse geocode to get Arabic city name
      String cityName = 'موقعي الحالي';
      try {
        final response = await dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'json',
            'lat': position.latitude,
            'lon': position.longitude,
            'zoom': 10,
            'accept-language': 'ar',
          },
          options: Options(
            headers: {
              'User-Agent': 'ImanAppGeocodingClient',
            },
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );
        
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final address = data['address'] as Map<String, dynamic>?;
            if (address != null) {
              final String? rawCity = address['city'] ??
                  address['town'] ??
                  address['suburb'] ??
                  address['village'] ??
                  address['state'] ??
                  address['governorate'] ??
                  address['county'];
              if (rawCity != null && rawCity.isNotEmpty) {
                cityName = rawCity.replaceAll('محافظة ', '').trim();
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
        // Fallback to last cached city name if coordinates are close
        final cached = _getCachedLocation();
        if (cached != null) {
          final double distance = Geolocator.distanceBetween(position.latitude, position.longitude, cached.latitude, cached.longitude);
          if (distance < 10000) { // < 10km
            cityName = cached.cityName;
          }
        }
      }

      final userLoc = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );

      // Cache the successfully resolved location
      await _cacheLocation(userLoc);

      return userLoc;
    } catch (e) {
      debugPrint('PrayerRepositoryImpl: Location check failed: $e');
      return _getCachedLocation();
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
        debugPrint('PrayerRepositoryImpl: Error parsing cached calendar: $e');
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
      debugPrint('PrayerRepositoryImpl: Failed to fetch calendar from network: $e');
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
