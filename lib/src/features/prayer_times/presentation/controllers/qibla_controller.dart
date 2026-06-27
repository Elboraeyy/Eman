import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../data/repositories/prayer_repository_provider.dart';

class FallbackCity {
  final String name;
  final double latitude;
  final double longitude;

  const FallbackCity(this.name, this.latitude, this.longitude);
}

const List<FallbackCity> fallbackCities = [
  FallbackCity('مكة المكرمة', 21.422487, 39.826206),
  FallbackCity('المدينة المنورة', 24.467218, 39.611183),
  FallbackCity('القدس الشريف', 31.768319, 35.213710),
  FallbackCity('الرياض', 24.713552, 46.675296),
  FallbackCity('القاهرة', 30.044420, 31.235712),
  FallbackCity('جدة', 21.543333, 39.172778),
  FallbackCity('دبي', 25.204849, 55.270783),
  FallbackCity('أبوظبي', 24.453835, 54.377344),
  FallbackCity('عمان', 31.952162, 35.910142),
  FallbackCity('بيروت', 33.893791, 35.501777),
  FallbackCity('دمشق', 33.513807, 36.276528),
  FallbackCity('بغداد', 33.315241, 44.366067),
  FallbackCity('المنامة', 26.228516, 50.586050),
  FallbackCity('الدوحة', 25.285447, 51.531040),
  FallbackCity('مسقط', 23.585890, 58.405923),
  FallbackCity('الكويت', 29.375859, 47.977405),
  FallbackCity('صنعاء', 15.369445, 44.191006),
  FallbackCity('طرابلس', 32.887209, 13.191338),
  FallbackCity('تونس', 36.806496, 10.181532),
  FallbackCity('الجزائر', 36.753769, 3.058756),
  FallbackCity('الرباط', 34.020882, -6.841650),
  FallbackCity('الخرطوم', 15.500654, 32.559899),
];

class QiblaState {
  final double heading;       // Phone heading from North (0-360)
  final double qiblaAngle;    // Kaaba direction from North (0-360)
  final double needleAngle;    // Angle to rotate the needle (Qibla - Heading)
  final bool isAligned;       // True if pointed directly towards Mecca
  final bool isLoading;
  final String? errorMessage;
  
  // New premium properties
  final double latitude;
  final double longitude;
  final String cityName;
  final double distanceToKaaba;
  final bool usingFallbackCity;
  final FallbackCity? selectedFallbackCity;

  QiblaState({
    required this.heading,
    required this.qiblaAngle,
    required this.needleAngle,
    required this.isAligned,
    required this.isLoading,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.distanceToKaaba,
    required this.usingFallbackCity,
    this.selectedFallbackCity,
    this.errorMessage,
  });

  QiblaState copyWith({
    double? heading,
    double? qiblaAngle,
    double? needleAngle,
    bool? isAligned,
    bool? isLoading,
    double? latitude,
    double? longitude,
    String? cityName,
    double? distanceToKaaba,
    bool? usingFallbackCity,
    FallbackCity? selectedFallbackCity,
    String? errorMessage,
  }) {
    return QiblaState(
      heading: heading ?? this.heading,
      qiblaAngle: qiblaAngle ?? this.qiblaAngle,
      needleAngle: needleAngle ?? this.needleAngle,
      isAligned: isAligned ?? this.isAligned,
      isLoading: isLoading ?? this.isLoading,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      distanceToKaaba: distanceToKaaba ?? this.distanceToKaaba,
      usingFallbackCity: usingFallbackCity ?? this.usingFallbackCity,
      selectedFallbackCity: selectedFallbackCity ?? this.selectedFallbackCity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QiblaNotifier extends Notifier<QiblaState> {
  StreamSubscription? _compassSubscription;
  double _smoothedHeading = 0.0;
  bool _hasHapticTriggered = false;

  @override
  QiblaState build() {
    ref.onDispose(() {
      _compassSubscription?.cancel();
    });
    _startTracking();
    return QiblaState(
      heading: 0.0,
      qiblaAngle: 0.0,
      needleAngle: 0.0,
      isAligned: false,
      isLoading: true,
      latitude: 0.0,
      longitude: 0.0,
      cityName: 'جاري التحديد...',
      distanceToKaaba: 0.0,
      usingFallbackCity: false,
    );
  }

  Future<void> _startTracking() async {
    try {
      final repo = ref.read(prayerRepositoryProvider);
      final location = await repo.getCurrentLocation();
      
      if (location == null) {
        // If GPS fails, switch to manual fallback city (default to Mecca)
        final defaultCity = fallbackCities[0]; // Mecca
        _switchToManualCity(defaultCity, errorMessage: null); // Don't show blocking error, just fallback gracefully
        _startCompassListening(defaultCity.latitude, defaultCity.longitude);
        return;
      }

      final qiblaAngle = _calculateQibla(location.latitude, location.longitude);
      final distance = _calculateDistanceToKaaba(location.latitude, location.longitude);
      
      state = state.copyWith(
        qiblaAngle: qiblaAngle,
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: location.cityName,
        distanceToKaaba: distance,
        usingFallbackCity: false,
        isLoading: false,
        errorMessage: null,
      );

      _startCompassListening(location.latitude, location.longitude);
    } catch (e) {
      // Graceful fallback on exception
      final defaultCity = fallbackCities[0]; // Mecca
      _switchToManualCity(defaultCity, errorMessage: 'حدث خطأ أثناء تشغيل البوصلة. تم تفعيل التحديد اليدوي.');
      _startCompassListening(defaultCity.latitude, defaultCity.longitude);
    }
  }

  void _switchToManualCity(FallbackCity city, {String? errorMessage}) {
    final qiblaAngle = _calculateQibla(city.latitude, city.longitude);
    final distance = _calculateDistanceToKaaba(city.latitude, city.longitude);

    state = state.copyWith(
      qiblaAngle: qiblaAngle,
      latitude: city.latitude,
      longitude: city.longitude,
      cityName: city.name,
      distanceToKaaba: distance,
      usingFallbackCity: true,
      selectedFallbackCity: city,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  void selectManualCity(FallbackCity city) {
    _switchToManualCity(city);
    // Restart compass listening with the new coordinates
    _startCompassListening(city.latitude, city.longitude);
  }

  Future<void> enableGps() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    _compassSubscription?.cancel();
    _smoothedHeading = 0.0;
    _hasHapticTriggered = false;
    await _startTracking();
  }

  void _startCompassListening(double lat, double lon) {
    _compassSubscription?.cancel();
    
    final qiblaAngle = _calculateQibla(lat, lon);
    const double alpha = 0.15; // Low-pass filter coefficient (lower = smoother)

    _compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) return;

      // Convert heading to 0-360 range
      final heading360 = (heading + 360) % 360;

      if (_smoothedHeading == 0.0) {
        _smoothedHeading = heading360; // Initialize
      } else {
        // Resolve 0-360 wraparound jump
        double delta = heading360 - _smoothedHeading;
        if (delta < -180) delta += 360;
        if (delta > 180) delta -= 360;
        
        _smoothedHeading += alpha * delta;
        _smoothedHeading = (_smoothedHeading + 360) % 360;
      }

      // Needle rotation angle is the difference between Qibla angle and phone heading
      double needleAngle = (qiblaAngle - _smoothedHeading + 360) % 360;
      
      // IsAligned if pointing to Kaaba within 4 degrees
      final isAligned = needleAngle <= 4 || needleAngle >= 356;

      // Trigger haptic feedback when entering aligned state
      if (isAligned && !_hasHapticTriggered) {
        HapticFeedback.lightImpact();
        _hasHapticTriggered = true;
      } else if (!isAligned) {
        _hasHapticTriggered = false; // Reset trigger when going out of alignment
      }

      state = state.copyWith(
        heading: _smoothedHeading,
        needleAngle: needleAngle,
        isAligned: isAligned,
      );
    });
  }

  double _calculateQibla(double lat, double lon) {
    // Kaaba Coordinates
    const double kaabaLat = 21.422487 * math.pi / 180.0;
    const double kaabaLon = 39.826206 * math.pi / 180.0;

    final double uLat = lat * math.pi / 180.0;
    final double uLon = lon * math.pi / 180.0;

    final double y = math.sin(kaabaLon - uLon);
    final double x = math.cos(uLat) * math.tan(kaabaLat) - math.sin(uLat) * math.cos(kaabaLon - uLon);

    final double qiblaRad = math.atan2(y, x);
    final double qiblaDeg = qiblaRad * 180.0 / math.pi;

    return (qiblaDeg + 360.0) % 360.0;
  }

  double _calculateDistanceToKaaba(double lat, double lon) {
    const double R = 6371.0; // Earth's radius in km
    const double kaabaLat = 21.422487 * math.pi / 180.0;
    const double kaabaLon = 39.826206 * math.pi / 180.0;

    final double uLat = lat * math.pi / 180.0;
    final double uLon = lon * math.pi / 180.0;

    final double dLat = kaabaLat - uLat;
    final double dLon = kaabaLon - uLon;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(uLat) * math.cos(kaabaLat) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }
}

final qiblaProvider = NotifierProvider<QiblaNotifier, QiblaState>(QiblaNotifier.new);
