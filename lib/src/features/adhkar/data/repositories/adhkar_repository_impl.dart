import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/adhkar_entities.dart';
import '../../domain/repositories/adhkar_repository.dart';

class AdhkarRepositoryImpl implements AdhkarRepository {
  final AppDatabase db;

  AdhkarRepositoryImpl({required this.db});

  // Mapper helpers
  AdhkarCategory _mapCategoryToDomain(AdhkarCategoryData c) {
    return AdhkarCategory(
      id: c.id,
      title: c.title,
      description: c.description,
    );
  }

  AdhkarItem _mapItemToDomain(AdhkarItemData i) {
    return AdhkarItem(
      id: i.id,
      categoryId: i.categoryId,
      text: i.textContent,
      targetCount: i.targetCount,
      reference: i.reference,
    );
  }

  Tasbih _mapTasbihToDomain(TasbihData t) {
    return Tasbih(
      id: t.id,
      phrase: t.phrase,
      count: t.count,
      target: t.target,
      updatedAt: t.updatedAt,
    );
  }

  // --- Adhkar Section ---

  @override
  Future<List<AdhkarCategory>> getAllCategories() async {
    final categories = await db.select(db.adhkarCategories).get();
    return categories.map(_mapCategoryToDomain).toList();
  }

  @override
  Future<List<AdhkarItem>> getAdhkarByCategory(int categoryId) async {
    final items = await (db.select(db.adhkarItems)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return items.map(_mapItemToDomain).toList();
  }

  @override
  Future<List<AdhkarItem>> getAllAdhkarItems() async {
    final items = await db.select(db.adhkarItems).get();
    return items.map(_mapItemToDomain).toList();
  }

  @override
  Future<int> getAdhkarProgress(int itemId, String date) async {
    final match = await (db.select(db.adhkarProgresses)
          ..where((t) => t.itemId.equals(itemId) & t.date.equals(date))
          ..limit(1))
        .getSingleOrNull();
    return match?.count ?? 0;
  }

  @override
  Future<void> incrementAdhkarProgress(int itemId, String date, int maxCount) async {
    final match = await (db.select(db.adhkarProgresses)
          ..where((t) => t.itemId.equals(itemId) & t.date.equals(date))
          ..limit(1))
        .getSingleOrNull();

    int newCount = 1;
    if (match != null) {
      newCount = match.count + 1;
      await (db.update(db.adhkarProgresses)..where((t) => t.id.equals(match.id)))
          .write(AdhkarProgressesCompanion(
            count: Value(newCount),
          ));
    } else {
      await db.into(db.adhkarProgresses).insert(
        AdhkarProgressesCompanion.insert(
          itemId: itemId,
          count: const Value(1),
          date: date,
        ),
      );
    }

    // Trigger daily stat update: if we just reached the target, increment daily adhkar stats
    if (newCount == maxCount) {
      await _incrementDailyAdhkarStat(date);
    }
  }

  @override
  Future<void> resetAdhkarProgress(int categoryId, String date) async {
    final items = await getAdhkarByCategory(categoryId);
    if (items.isEmpty) return;

    final itemIds = items.map((i) => i.id).toList();
    await (db.delete(db.adhkarProgresses)
          ..where((t) => t.itemId.isIn(itemIds) & t.date.equals(date)))
        .go();
  }

  @override
  Future<void> resetAllProgress(String date) async {
    await (db.delete(db.adhkarProgresses)..where((t) => t.date.equals(date))).go();
  }

  @override
  Future<double> getCategoryCompletionProgress(int categoryId, String date) async {
    final items = await getAdhkarByCategory(categoryId);
    if (items.isEmpty) return 0.0;

    int totalTarget = 0;
    int totalCompleted = 0;

    for (final item in items) {
      totalTarget += item.targetCount;
      final progress = await getAdhkarProgress(item.id, date);
      totalCompleted += progress.clamp(0, item.targetCount);
    }

    return totalTarget > 0 ? totalCompleted / totalTarget : 0.0;
  }

  // --- Tasbih Section ---

  @override
  Future<List<Tasbih>> getAllTasbihs() async {
    var tasbihs = await db.select(db.tasbihs).get();
    
    // Inject default tasbihs if completely empty
    if (tasbihs.isEmpty) {
      final defaultPhrases = [
        {'phrase': 'سُبْحَانَ اللَّهِ', 'target': 33},
        {'phrase': 'الْحَمْدُ لِلَّهِ', 'target': 33},
        {'phrase': 'اللَّهُ أَكْبَرُ', 'target': 34},
        {'phrase': 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ', 'target': 33},
        {'phrase': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ', 'target': 100},
      ];

      await db.batch((batch) {
        batch.insertAll(
          db.tasbihs,
          defaultPhrases.map((item) {
            return TasbihsCompanion.insert(
              phrase: item['phrase'] as String,
              target: Value(item['target'] as int),
            );
          }).toList(),
        );
      });
      
      tasbihs = await db.select(db.tasbihs).get();
    }
    
    return tasbihs.map(_mapTasbihToDomain).toList();
  }

  @override
  Future<Tasbih?> getTasbihById(int id) async {
    final result = await (db.select(db.tasbihs)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return result != null ? _mapTasbihToDomain(result) : null;
  }

  @override
  Future<void> incrementTasbih(int id) async {
    final match = await getTasbihById(id);
    if (match == null) return;

    final newCount = match.count + 1;
    await (db.update(db.tasbihs)..where((t) => t.id.equals(id)))
        .write(TasbihsCompanion(
          count: Value(newCount),
          updatedAt: Value(DateTime.now()),
        ));

    // Update daily stats counter
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    await _incrementDailyTasbihStat(todayStr);
  }

  @override
  Future<void> resetTasbih(int id) async {
    await (db.update(db.tasbihs)..where((t) => t.id.equals(id)))
        .write(const TasbihsCompanion(
          count: Value(0),
        ));
  }

  @override
  Future<void> createCustomTasbih(String phrase, int target) async {
    await db.into(db.tasbihs).insert(
      TasbihsCompanion.insert(
        phrase: phrase,
        target: Value(target),
      ),
    );
  }

  @override
  Future<void> deleteTasbih(int id) async {
    await (db.delete(db.tasbihs)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<int> getHistoryTotalTasbihCount() async {
    // Sums historical stats
    final results = await db.select(db.userStats).get();
    return results.fold<int>(0, (sum, item) => sum + item.tasbihCount);
  }

  // --- Statistics Helpers ---

  Future<void> _incrementDailyAdhkarStat(String date) async {
    final match = await (db.select(db.userStats)
          ..where((t) => t.date.equals(date))
          ..limit(1))
        .getSingleOrNull();

    if (match != null) {
      await (db.update(db.userStats)..where((t) => t.id.equals(match.id)))
          .write(UserStatsCompanion(
            adhkarCompleted: Value(match.adhkarCompleted + 1),
          ));
    } else {
      await db.into(db.userStats).insert(
        UserStatsCompanion.insert(
          date: date,
          adhkarCompleted: const Value(1),
        ),
      );
    }
  }

  Future<void> _incrementDailyTasbihStat(String date) async {
    final match = await (db.select(db.userStats)
          ..where((t) => t.date.equals(date))
          ..limit(1))
        .getSingleOrNull();

    if (match != null) {
      await (db.update(db.userStats)..where((t) => t.id.equals(match.id)))
          .write(UserStatsCompanion(
            tasbihCount: Value(match.tasbihCount + 1),
          ));
    } else {
      await db.into(db.userStats).insert(
        UserStatsCompanion.insert(
          date: date,
          tasbihCount: const Value(1),
        ),
      );
    }
  }
}
