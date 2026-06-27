import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/shared_preferences_provider.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/prayer_repository.dart';
import 'prayer_repository_impl.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return PrayerRepositoryImpl(dio: dio, sharedPreferences: sharedPrefs);
});
