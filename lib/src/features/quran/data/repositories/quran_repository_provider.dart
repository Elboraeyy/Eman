import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/quran_repository.dart';
import '../../domain/entities/quran_entities.dart';
import 'quran_repository_impl.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final dio = ref.watch(dioProvider);
  return QuranRepositoryImpl(db: db, dio: dio);
});

final favoriteVersesProvider = FutureProvider<List<Ayah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getFavoriteVerses();
});
