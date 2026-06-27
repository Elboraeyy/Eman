import '../../../../core/database/app_database.dart';

abstract class TrackerRepository {
  Future<List<ReligiousTaskData>> getAllTasks();
  Future<List<TaskCompletionData>> getCompletionsForDate(String date);
  Future<void> toggleTaskCompletion(int taskId, String date);
  Future<void> addCustomTask(String title, String frequency);
  Future<void> deleteCustomTask(int taskId);
  Future<Map<String, double>> getWeeklyProgressStats();
}
