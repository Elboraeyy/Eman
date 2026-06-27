import '../entities/quran_entities.dart';

abstract class QuranRepository {
  Future<List<Surah>> getAllSurahs();
  Future<Surah?> getSurahByNumber(int number);
  Future<List<Ayah>> getAyahsBySurah(int surahNumber);
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber);
  Future<List<Surah>> searchSurahs(String query);
  Future<List<Ayah>> searchAyat(String query);
  Future<List<Ayah>> getAyatByPage(int page);
  Future<List<Ayah>> getAyatByJuz(int juz);
  Future<List<Ayah>> getJuzBoundaries();
  Future<QcfPage> getQcfPage(int pageNumber);
  Future<Map<int, int>> getSurahStartPages();
  Stream<List<Surah>> getSurahsStream();

  // Reading Progress
  Future<void> saveReadingProgress(int page);
  Future<int> getLastReadPage();

  // Verse Favorites
  Future<void> toggleVerseFavorite(int surahNumber, int ayahNumber);
  Future<bool> isVerseFavorite(int surahNumber, int ayahNumber);
  Future<List<Ayah>> getFavoriteVerses();
}

