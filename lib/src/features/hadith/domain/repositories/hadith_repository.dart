import '../entities/hadith_entities.dart';

abstract class HadithRepository {
  Future<List<HadithBook>> getAllBooks();
  Future<List<HadithCategory>> getAllCategories();
  Future<List<Hadith>> getHadithsByBook(int bookId);
  Future<List<Hadith>> getHadithsByCategory(int categoryId);
  Future<Hadith?> getHadithById(int id);
  Future<List<Hadith>> searchHadiths(String query);
  Future<void> toggleBookmark(int hadithId);
  Future<bool> isBookmarked(int hadithId);
  Future<List<Hadith>> getBookmarkedHadiths();
}
