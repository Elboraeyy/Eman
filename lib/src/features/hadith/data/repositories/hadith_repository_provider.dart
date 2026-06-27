import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/hadith_repository.dart';
import '../../domain/entities/hadith_entities.dart';
import 'hadith_repository_impl.dart';

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HadithRepositoryImpl(db: db);
});

final bookmarkedHadithsProvider = FutureProvider<List<Hadith>>((ref) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getBookmarkedHadiths();
});

final isHadithBookmarkedProvider = FutureProvider.family<bool, int>((ref, hadithId) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.isBookmarked(hadithId);
});

final hadithBooksProvider = FutureProvider<List<HadithBook>>((ref) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getAllBooks();
});

final hadithCategoriesProvider = FutureProvider<List<HadithCategory>>((ref) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getAllCategories();
});

