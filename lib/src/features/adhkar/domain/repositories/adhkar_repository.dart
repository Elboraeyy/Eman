import '../entities/adhkar_entities.dart';

abstract class AdhkarRepository {
  // Adhkar daily items
  Future<List<AdhkarCategory>> getAllCategories();
  Future<List<AdhkarItem>> getAdhkarByCategory(int categoryId);
  Future<List<AdhkarItem>> getAllAdhkarItems();
  Future<int> getAdhkarProgress(int itemId, String date);
  Future<void> incrementAdhkarProgress(int itemId, String date, int maxCount);
  Future<void> resetAdhkarProgress(int categoryId, String date);
  Future<void> resetAllProgress(String date);
  Future<double> getCategoryCompletionProgress(int categoryId, String date);

  // Tasbih electronic counter
  Future<List<Tasbih>> getAllTasbihs();
  Future<Tasbih?> getTasbihById(int id);
  Future<void> incrementTasbih(int id);
  Future<void> resetTasbih(int id);
  Future<void> createCustomTasbih(String phrase, int target);
  Future<void> deleteTasbih(int id);
  Future<int> getHistoryTotalTasbihCount();
}
