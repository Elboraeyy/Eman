import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/tracker_repository.dart';

class TrackerRepositoryImpl implements TrackerRepository {
  final AppDatabase db;

  TrackerRepositoryImpl({required this.db});

  @override
  Future<List<ReligiousTaskData>> getAllTasks() async {
    return await db.select(db.religiousTasks).get();
  }

  @override
  Future<List<TaskCompletionData>> getCompletionsForDate(String date) async {
    return await (db.select(db.taskCompletions)..where((t) => t.date.equals(date))).get();
  }

  @override
  Future<void> toggleTaskCompletion(int taskId, String date) async {
    final match = await (db.select(db.taskCompletions)
          ..where((t) => t.taskId.equals(taskId) & t.date.equals(date))
          ..limit(1))
        .getSingleOrNull();

    if (match == null) {
      // Create new record as completed
      await db.into(db.taskCompletions).insert(
        TaskCompletionsCompanion.insert(
          taskId: taskId,
          date: date,
          completed: const Value(true),
        ),
      );
    } else {
      // Toggle the completed boolean
      await (db.update(db.taskCompletions)..where((t) => t.id.equals(match.id)))
          .write(TaskCompletionsCompanion(
        completed: Value(!match.completed),
      ));
    }
  }

  @override
  Future<void> addCustomTask(String title, String frequency) async {
    await db.into(db.religiousTasks).insert(
      ReligiousTasksCompanion.insert(
        title: title,
        type: const Value('custom'),
        frequency: Value(frequency),
      ),
    );
  }

  @override
  Future<void> deleteCustomTask(int taskId) async {
    await (db.delete(db.religiousTasks)..where((t) => t.id.equals(taskId))).go();
  }

  @override
  Future<Map<String, double>> getWeeklyProgressStats() async {
    final totalTasks = await getAllTasks();
    if (totalTasks.isEmpty) return {};

    final stats = <String, double>{};
    final now = DateTime.now();

    // Generate list of date strings for the last 7 days
    final dateStrings = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(date);
    });

    try {
      // Fetch all completions for these 7 days in a single query
      final completions = await (db.select(db.taskCompletions)
            ..where((t) => t.date.isIn(dateStrings)))
          .get();

      // Group completions by date
      for (final dateStr in dateStrings) {
        final dayCompletions = completions.where((c) => c.date == dateStr);
        final completedCount = dayCompletions.where((c) => c.completed).length;
        
        final ratio = completedCount / totalTasks.length;
        stats[dateStr] = ratio;
      }
    } catch (e) {
      // Return empty or default ratios on error
      for (final dateStr in dateStrings) {
        stats[dateStr] = 0.0;
      }
    }

    return stats;
  }
}

