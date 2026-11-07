import '../../../../core/database/app_database.dart';

abstract class TrackerRepository {
  Future<List<ReligiousTaskData>> getAllTasks();
  Future<List<TaskCompletionData>> getCompletionsForDate(String date);
  Future<void> toggleTaskCompletion(int taskId, String date);
  Future<void> setTaskCompletion(int taskId, String date, bool completed);
  Future<void> addCustomTask(String title, String frequency);
  Future<void> deleteCustomTask(int taskId);
  Future<Map<String, double>> getWeeklyProgressStats();

  // Connected stats & automatic recording
  Future<void> recordQuranPagesRead(int count, {String? date});
  Future<void> recordTasbihCount(int count, {String? date});
  Future<void> recordAdhkarCompleted({String? date});
  Future<UserStatData?> getUserStatsForDate(String date);
  Future<Map<String, UserStatData>> getStatsForLastDays(int days);
  Future<Map<String, dynamic>> getOverallStatsSummary();
  Future<int> getCurrentStreak();
  Future<int> getBestStreak();
  Future<void> ensureDefaultTasks();
}
