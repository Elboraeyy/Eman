import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/tracker_repository.dart';

class TrackerRepositoryImpl implements TrackerRepository {
  final AppDatabase db;

  TrackerRepositoryImpl({required this.db});

  @override
  Future<List<ReligiousTaskData>> getAllTasks() async {
    await ensureDefaultTasks();
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
      await db.into(db.taskCompletions).insert(
        TaskCompletionsCompanion.insert(
          taskId: taskId,
          date: date,
          completed: const Value(true),
        ),
      );
    } else {
      await (db.update(db.taskCompletions)..where((t) => t.id.equals(match.id)))
          .write(TaskCompletionsCompanion(
        completed: Value(!match.completed),
      ));
    }
  }

  @override
  Future<void> setTaskCompletion(int taskId, String date, bool completed) async {
    final match = await (db.select(db.taskCompletions)
          ..where((t) => t.taskId.equals(taskId) & t.date.equals(date))
          ..limit(1))
        .getSingleOrNull();

    if (match == null) {
      if (completed) {
        await db.into(db.taskCompletions).insert(
          TaskCompletionsCompanion.insert(
            taskId: taskId,
            date: date,
            completed: const Value(true),
          ),
        );
      }
    } else {
      await (db.update(db.taskCompletions)..where((t) => t.id.equals(match.id)))
          .write(TaskCompletionsCompanion(
        completed: Value(completed),
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
  Future<void> ensureDefaultTasks() async {
    final tasks = await db.select(db.religiousTasks).get();
    if (tasks.isEmpty) {
      final defaultList = [
        'الصلوات الخمس في أوقاتها',
        'صلاة الضحى',
        'السنن الرواتب (12 ركعة)',
        'قيام الليل والوتر',
        'قراءة الورد القرآني اليومي',
        'أذكار الصباح والمساء',
        'تسبيح واستغفار اليوم (100 مرة)',
        'الصدقة اليومية',
      ];
      for (final title in defaultList) {
        await db.into(db.religiousTasks).insert(
          ReligiousTasksCompanion.insert(
            title: title,
            type: const Value('default'),
            frequency: const Value('daily'),
          ),
        );
      }
    }
  }

  @override
  Future<void> recordQuranPagesRead(int count, {String? date}) async {
    final targetDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final existing = await (db.select(db.userStats)..where((s) => s.date.equals(targetDate))).getSingleOrNull();

    if (existing == null) {
      await db.into(db.userStats).insert(
        UserStatsCompanion.insert(
          date: targetDate,
          quranPagesRead: Value(count),
        ),
      );
    } else {
      await (db.update(db.userStats)..where((s) => s.id.equals(existing.id))).write(
        UserStatsCompanion(
          quranPagesRead: Value(existing.quranPagesRead + count),
        ),
      );
    }

    final allTasks = await db.select(db.religiousTasks).get();
    for (final task in allTasks) {
      if (task.title.contains('قرآن') || task.title.contains('الورد')) {
        await setTaskCompletion(task.id, targetDate, true);
      }
    }
  }

  @override
  Future<void> recordTasbihCount(int count, {String? date}) async {
    final targetDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final existing = await (db.select(db.userStats)..where((s) => s.date.equals(targetDate))).getSingleOrNull();

    final newCount = (existing?.tasbihCount ?? 0) + count;
    if (existing == null) {
      await db.into(db.userStats).insert(
        UserStatsCompanion.insert(
          date: targetDate,
          tasbihCount: Value(count),
        ),
      );
    } else {
      await (db.update(db.userStats)..where((s) => s.id.equals(existing.id))).write(
        UserStatsCompanion(
          tasbihCount: Value(newCount),
        ),
      );
    }

    if (newCount >= 100) {
      final allTasks = await db.select(db.religiousTasks).get();
      for (final task in allTasks) {
        if (task.title.contains('تسبيح') || task.title.contains('استغفار')) {
          await setTaskCompletion(task.id, targetDate, true);
        }
      }
    }
  }

  @override
  Future<void> recordAdhkarCompleted({String? date}) async {
    final targetDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final existing = await (db.select(db.userStats)..where((s) => s.date.equals(targetDate))).getSingleOrNull();

    if (existing == null) {
      await db.into(db.userStats).insert(
        UserStatsCompanion.insert(
          date: targetDate,
          adhkarCompleted: const Value(1),
        ),
      );
    } else {
      await (db.update(db.userStats)..where((s) => s.id.equals(existing.id))).write(
        UserStatsCompanion(
          adhkarCompleted: Value(existing.adhkarCompleted + 1),
        ),
      );
    }

    final allTasks = await db.select(db.religiousTasks).get();
    for (final task in allTasks) {
      if (task.title.contains('أذكار')) {
        await setTaskCompletion(task.id, targetDate, true);
      }
    }
  }

  @override
  Future<UserStatData?> getUserStatsForDate(String date) async {
    return await (db.select(db.userStats)..where((s) => s.date.equals(date))).getSingleOrNull();
  }

  @override
  Future<Map<String, UserStatData>> getStatsForLastDays(int days) async {
    final now = DateTime.now();
    final dateStrings = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      return DateFormat('yyyy-MM-dd').format(d);
    });

    final statsList = await (db.select(db.userStats)..where((s) => s.date.isIn(dateStrings))).get();
    final map = <String, UserStatData>{};
    for (final item in statsList) {
      map[item.date] = item;
    }
    return map;
  }

  @override
  Future<Map<String, double>> getWeeklyProgressStats() async {
    final totalTasks = await getAllTasks();
    if (totalTasks.isEmpty) return {};

    final stats = <String, double>{};
    final now = DateTime.now();

    final dateStrings = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(date);
    });

    try {
      final completions = await (db.select(db.taskCompletions)
            ..where((t) => t.date.isIn(dateStrings)))
          .get();

      for (final dateStr in dateStrings) {
        final dayCompletions = completions.where((c) => c.date == dateStr);
        final completedCount = dayCompletions.where((c) => c.completed).length;
        final ratio = totalTasks.isEmpty ? 0.0 : (completedCount / totalTasks.length).clamp(0.0, 1.0);
        stats[dateStr] = ratio;
      }
    } catch (e) {
      for (final dateStr in dateStrings) {
        stats[dateStr] = 0.0;
      }
    }

    return stats;
  }

  @override
  Future<int> getCurrentStreak() async {
    final now = DateTime.now();
    int streak = 0;

    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final todayCompletions = await (db.select(db.taskCompletions)
          ..where((t) => t.date.equals(todayStr) & t.completed.equals(true)))
        .get();

    var checkDate = now;
    if (todayCompletions.isNotEmpty) {
      streak = 1;
      checkDate = now.subtract(const Duration(days: 1));
    } else {
      checkDate = now.subtract(const Duration(days: 1));
    }

    for (var i = 0; i < 365; i++) {
      final dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      final count = await (db.select(db.taskCompletions)
            ..where((t) => t.date.equals(dateStr) & t.completed.equals(true)))
          .get();

      if (count.isNotEmpty) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Future<int> getBestStreak() async {
    final allCompletions = await (db.select(db.taskCompletions)
          ..where((c) => c.completed.equals(true)))
        .get();

    if (allCompletions.isEmpty) return 0;

    final dates = allCompletions.map((c) => c.date).toSet().toList()..sort();
    if (dates.isEmpty) return 0;

    int maxStreak = 1;
    int currentRun = 1;

    for (var i = 1; i < dates.length; i++) {
      final prev = DateTime.tryParse(dates[i - 1]);
      final curr = DateTime.tryParse(dates[i]);
      if (prev != null && curr != null) {
        final diff = curr.difference(prev).inDays;
        if (diff == 1) {
          currentRun++;
          if (currentRun > maxStreak) {
            maxStreak = currentRun;
          }
        } else if (diff > 1) {
          currentRun = 1;
        }
      }
    }

    return maxStreak;
  }

  @override
  Future<Map<String, dynamic>> getOverallStatsSummary() async {
    final allStats = await db.select(db.userStats).get();
    int totalQuran = 0;
    int totalTasbih = 0;
    int totalAdhkar = 0;

    for (final s in allStats) {
      totalQuran += s.quranPagesRead;
      totalTasbih += s.tasbihCount;
      totalAdhkar += s.adhkarCompleted;
    }

    final allCompletions = await (db.select(db.taskCompletions)..where((c) => c.completed.equals(true))).get();
    final totalCompletedTasks = allCompletions.length;

    final currentStreak = await getCurrentStreak();
    final bestStreak = await getBestStreak();

    final weekly = await getWeeklyProgressStats();
    double weeklyAvg = 0.0;
    if (weekly.isNotEmpty) {
      weeklyAvg = weekly.values.reduce((a, b) => a + b) / weekly.length;
    }

    return {
      'totalQuranPages': totalQuran,
      'totalTasbih': totalTasbih,
      'totalAdhkar': totalAdhkar,
      'totalCompletedTasks': totalCompletedTasks,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak > currentStreak ? bestStreak : currentStreak,
      'weeklyAverageRate': (weeklyAvg * 100).round(),
    };
  }
}
