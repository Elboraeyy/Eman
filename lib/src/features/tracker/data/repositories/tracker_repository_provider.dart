import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/tracker_repository.dart';
import 'tracker_repository_impl.dart';

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TrackerRepositoryImpl(db: db);
});
