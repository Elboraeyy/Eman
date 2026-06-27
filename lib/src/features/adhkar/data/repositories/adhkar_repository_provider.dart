import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/adhkar_repository.dart';
import 'adhkar_repository_impl.dart';

final adhkarRepositoryProvider = Provider<AdhkarRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AdhkarRepositoryImpl(db: db);
});
