class PrayerTimes {
  final String date; // YYYY-MM-DD
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    // Helper to parse "05:15 (EEST)" into a DateTime for the specific day
    DateTime parseTime(String timeStr, String dateStr) {
      final cleanTime = timeStr.split(' ')[0]; // removes timezone text like "(EEST)"
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final dateParts = dateStr.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      return DateTime(year, month, day, hour, minute);
    }

    final date = json['date'] as String;
    final timings = json['timings'] as Map<String, dynamic>;

    return PrayerTimes(
      date: date,
      fajr: parseTime(timings['Fajr'] as String, date),
      sunrise: parseTime(timings['Sunrise'] as String, date),
      dhuhr: parseTime(timings['Dhuhr'] as String, date),
      asr: parseTime(timings['Asr'] as String, date),
      maghrib: parseTime(timings['Maghrib'] as String, date),
      isha: parseTime(timings['Isha'] as String, date),
    );
  }

  Map<String, dynamic> toJson() {
    String formatTime(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return {
      'date': date,
      'timings': {
        'Fajr': formatTime(fajr),
        'Sunrise': formatTime(sunrise),
        'Dhuhr': formatTime(dhuhr),
        'Asr': formatTime(asr),
        'Maghrib': formatTime(maghrib),
        'Isha': formatTime(isha),
      }
    };
  }
}

class UserLocation {
  final double latitude;
  final double longitude;
  final String cityName;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });
}
