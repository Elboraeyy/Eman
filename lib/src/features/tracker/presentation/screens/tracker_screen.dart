import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/database/app_database.dart';
import 'package:zad/src/features/tracker/data/repositories/tracker_repository_provider.dart';

// Providers to load tasks, daily completions, and weekly stats
final tasksListProvider = FutureProvider<List<ReligiousTaskData>>((ref) async {
  final repo = ref.watch(trackerRepositoryProvider);
  return await repo.getAllTasks();
});

final completionsForDateProvider = FutureProvider.family<List<TaskCompletionData>, String>((ref, date) async {
  final repo = ref.watch(trackerRepositoryProvider);
  return await repo.getCompletionsForDate(date);
});

final weeklyStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(trackerRepositoryProvider);
  return await repo.getWeeklyProgressStats();
});

class TrackerScreen extends ConsumerStatefulWidget {
  final String mode; // 'stats' or 'tasks'
  const TrackerScreen({super.key, this.mode = 'stats'});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  final String _todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _toggleTask(int taskId, bool isCompleted) async {
    final repo = ref.read(trackerRepositoryProvider);
    await repo.toggleTaskCompletion(taskId, _todayStr);
    
    // Invalidate providers to trigger rebuilds
    ref.invalidate(completionsForDateProvider(_todayStr));
    ref.invalidate(weeklyStatsProvider);
  }

  Future<void> _deleteTask(int taskId) async {
    final repo = ref.read(trackerRepositoryProvider);
    await repo.deleteCustomTask(taskId);
    
    ref.invalidate(tasksListProvider);
    ref.invalidate(completionsForDateProvider(_todayStr));
    ref.invalidate(weeklyStatsProvider);
  }

  void _showAddTaskDialog(ThemeData theme) {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'إضافة عبادة جديدة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم العبادة (مثال: قراءة صفحتين من التفسير)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    final repo = ref.read(trackerRepositoryProvider);
                    await repo.addCustomTask(title, 'daily');
                    ref.invalidate(tasksListProvider);
                    ref.invalidate(weeklyStatsProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('حفظ العبادة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksListProvider);
    final completionsAsync = ref.watch(completionsForDateProvider(_todayStr));
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    final isStatsMode = widget.mode == 'stats';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStatsMode ? 'إحصائيات العبادات' : 'جدول اليوم',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: isStatsMode
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.add_task, size: 24),
                  onPressed: () => _showAddTaskDialog(theme),
                ),
              ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 110.0), // Padding to avoid overlap with bottom nav bar
        child: isStatsMode
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مؤشر الالتزام الأسبوعي',
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  weeklyStatsAsync.when(
                    data: (stats) {
                      if (stats.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'لا توجد إحصائيات كافية حالياً.',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          ),
                        );
                      }
                      return _buildWeeklyChartCard(stats, theme);
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('خطأ في تحميل الإحصائيات: $err')),
                  ),
                  const SizedBox(height: 24),
                  _buildTrackerActionCard(
                    context: context,
                    title: 'تخصيص جدول العبادات',
                    subtitle: 'إضافة أو تعديل المهام اليومية والسنن الرواتب',
                    icon: Icons.tune_outlined,
                    route: '/tracker/customization',
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildTrackerActionCard(
                    context: context,
                    title: 'سجل العبادات والتقويم',
                    subtitle: 'عرض تفاصيل الأيام السابقة ونقاط التقدم',
                    icon: Icons.calendar_month_outlined,
                    route: '/tracker/history',
                    theme: theme,
                  ),
                  const SizedBox(height: 24),
                  // Meticulously designed card showing tracker motivations
                  Card(
                    color: theme.colorScheme.primary.withValues(alpha: 0.04),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.insights, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'همّة نحو العبادة',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'متابعة أدائك الأسبوعي يساعدك على ترسيخ عاداتك الدينية والالتزام بالطاعات اليومية والسنن الرواتب.',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عباداتي اليومية',
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  tasksAsync.when(
                    data: (tasks) {
                      final completions = completionsAsync.value ?? [];
                      final completedIds = completions.where((c) => c.completed).map((c) => c.taskId).toSet();

                      if (tasks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              'لا توجد عبادات مضافة حالياً.',
                              style: GoogleFonts.cairo(color: theme.textTheme.bodyMedium?.color),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final isCompleted = completedIds.contains(task.id);

                          return Dismissible(
                            key: Key(task.id.toString()),
                            direction: task.type == 'custom' ? DismissDirection.endToStart : DismissDirection.none,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) => _deleteTask(task.id),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              color: isCompleted
                                  ? theme.colorScheme.primary.withValues(alpha: 0.04)
                                  : theme.colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: isCompleted
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor.withValues(alpha: 0.4),
                                  width: isCompleted ? 1.5 : 1,
                                ),
                              ),
                              child: CheckboxListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: Text(
                                  task.title,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    color: isCompleted
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                value: isCompleted,
                                activeColor: theme.colorScheme.primary,
                                checkColor: theme.colorScheme.onPrimary,
                                onChanged: (val) {
                                  if (val != null) {
                                    _toggleTask(task.id, val);
                                  }
                                },
                              ),
                            ),
                          ).animate(delay: (30 * index).ms).fadeIn().slideX(begin: 0.05, end: 0);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('خطأ في تحميل المهام: $err')),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWeeklyChartCard(Map<String, double> stats, ThemeData theme) {


    // Map stats to FlSpot points
    final spots = <FlSpot>[];
    final keysList = stats.keys.toList();
    for (int i = 0; i < keysList.length; i++) {
      final value = stats[keysList[i]] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value * 100)); // Convert ratio to percentage
    }

    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.only(right: 24, left: 12, top: 20, bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF7D5852), // Medium Brown Text
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < keysList.length) {
                    final date = DateTime.parse(keysList[index]);
                    final dayFormat = DateFormat('EEE', 'ar'); // Arabic short day name
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dayFormat.format(date),
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7D5852), // Medium Brown Text
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.secondary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.secondary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios
                    : Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
