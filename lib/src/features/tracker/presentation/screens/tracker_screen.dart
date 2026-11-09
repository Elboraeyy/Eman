import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../../../../core/database/app_database.dart';
import 'package:iman/src/features/tracker/data/repositories/tracker_repository_provider.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/responsive/app_insets.dart';

// Providers for Tasks & Stats
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

final overallStatsSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(trackerRepositoryProvider);
  return await repo.getOverallStatsSummary();
});

class TrackerScreen extends ConsumerStatefulWidget {
  final String mode; // 'stats' or 'tasks'
  const TrackerScreen({super.key, this.mode = 'stats'});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  late DateTime _selectedDate;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String get _selectedDateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _toggleTask(int taskId, bool currentlyCompleted) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(trackerRepositoryProvider);
    await repo.setTaskCompletion(taskId, _selectedDateStr, !currentlyCompleted);

    ref.invalidate(completionsForDateProvider(_selectedDateStr));
    ref.invalidate(weeklyStatsProvider);
    ref.invalidate(overallStatsSummaryProvider);
  }

  void _showAddTaskSheet(ThemeData theme) {
    final titleController = TextEditingController();
    String frequency = 'daily';

    final presetSuggestions = [
      'صيام التطوع (الاثنين / الخميس)',
      'قراءة سورة الكهف',
      'صلة الرحم وبر الوالدين',
      'استغفار 100 مرة باليوم',
      'ركعتي سنة الوضوء أو التوبة',
      'جلسة تدبر لآيات القرآن',
      'إفطار صائم أو صدقة جارية',
    ];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
              ),
              padding: EdgeInsets.fromLTRB(24, 16, 24, AppInsets.sheetBottom(context, gap: 24)),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  ArabicText(
                    'إضافة طاعة أو عبادة جديدة',
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
                    decoration: InputDecoration(
                      hintText: 'اسم العبادة أو الطاعة...',
                      hintStyle: GoogleFonts.cairo(fontSize: 14),
                      prefixIcon: const Icon(Icons.star_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ArabicText(
                    'اقتراحات سريعة لطاعات مباركة:',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetSuggestions.map((suggestion) {
                      return ActionChip(
                        label: ArabicText(suggestion, style: GoogleFonts.cairo(fontSize: 12)),
                        onPressed: () {
                          setModalState(() {
                            titleController.text = suggestion;
                          });
                        },
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: ArabicText('يومياً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                          selected: frequency == 'daily',
                          onSelected: (val) {
                            if (val) setModalState(() => frequency = 'daily');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: ArabicText('أسبوعياً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                          selected: frequency == 'weekly',
                          onSelected: (val) {
                            if (val) setModalState(() => frequency = 'weekly');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final text = titleController.text.trim();
                      if (text.isEmpty) return;
                      final repo = ref.read(trackerRepositoryProvider);
                      await repo.addCustomTask(text, frequency);

                      ref.invalidate(tasksListProvider);
                      ref.invalidate(weeklyStatsProvider);
                      ref.invalidate(overallStatsSummaryProvider);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: ArabicText(
                      'حفظ الطاعة والبدء بمتابعتها',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _TaskMeta _resolveTaskMeta(String title) {
    if (title.contains('الصلوات الخمس')) {
      return _TaskMeta(
        icon: Icons.mosque_rounded,
        color: const Color(0xFF10B981),
        subtitle: 'الفجر، الظهر، العصر، المغرب، والعشاء في أوقاتها',
        category: 'prayers',
      );
    } else if (title.contains('الضحى')) {
      return _TaskMeta(
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFF59E0B),
        subtitle: 'صلاة الأوابين من ركعتين إلى ثمان ركعات',
        category: 'prayers',
        actionLabel: 'دليل السنن',
        actionRoute: '/sunan',
      );
    } else if (title.contains('السنن الرواتب')) {
      return _TaskMeta(
        icon: Icons.volunteer_activism_rounded,
        color: const Color(0xFF3B82F6),
        subtitle: '12 ركعة تبني لك بيتاً في الجنة',
        category: 'prayers',
        actionLabel: 'دليل السنن',
        actionRoute: '/sunan',
      );
    } else if (title.contains('قيام الليل') || title.contains('الوتر')) {
      return _TaskMeta(
        icon: Icons.nights_stay_rounded,
        color: const Color(0xFF8B5CF6),
        subtitle: 'شرف المؤمن وخلوته برب العالمين في الثلث الأخير',
        category: 'prayers',
      );
    } else if (title.contains('قرآن') || title.contains('الورد')) {
      return _TaskMeta(
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF0D9488),
        subtitle: 'وردك اليومي غذاء الروح ونور الصدور',
        category: 'quran',
        actionLabel: 'فتح المصحف',
        actionRoute: '/quran',
      );
    } else if (title.contains('أذكار')) {
      return _TaskMeta(
        icon: Icons.wb_twilight_rounded,
        color: const Color(0xFFEC4899),
        subtitle: 'حصنك الحصين وذكر يطمئن به قلبك',
        category: 'adhkar',
        actionLabel: 'قراءة الأذكار',
        actionRoute: '/adhkar',
      );
    } else if (title.contains('تسبيح') || title.contains('استغفار')) {
      return _TaskMeta(
        icon: Icons.fingerprint_rounded,
        color: const Color(0xFF06B6D4),
        subtitle: 'سبحان الله وبحمده، أستغفر الله وأتوب إليه',
        category: 'adhkar',
        actionLabel: 'المسبحة',
        actionRoute: '/tasbih',
      );
    } else if (title.contains('صدقة')) {
      return _TaskMeta(
        icon: Icons.favorite_rounded,
        color: const Color(0xFFEF4444),
        subtitle: 'الصدقة تطفئ غضب الرب وتقي مصارع السوء',
        category: 'habits',
      );
    }
    return _TaskMeta(
      icon: Icons.check_circle_outline_rounded,
      color: const Color(0xFF6366F1),
      subtitle: 'طاعة مخصصة لتثبيت العادات الصالحة',
      category: 'habits',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStatsMode = widget.mode == 'stats';

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          isStatsMode ? 'الإحصائيات ولوحة الإنجاز' : 'متابعة العبادات والمهام',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        actions: [
          if (!isStatsMode)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'إضافة طاعة جديدة',
              onPressed: () => _showAddTaskSheet(theme),
            ),
          IconButton(
            icon: Icon(isStatsMode ? Icons.fact_check_outlined : Icons.insights_outlined),
            tooltip: isStatsMode ? 'الانتقال للمهام' : 'الانتقال للإحصائيات',
            onPressed: () {
              if (isStatsMode) {
                context.go('/tracker/tasks');
              } else {
                context.go('/tracker/stats');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_suggest_outlined),
            tooltip: 'تخصيص المهام',
            onPressed: () => context.push('/tracker/customization'),
          ),
        ],
      ),
      body: isStatsMode ? _buildStatsDashboard(theme) : _buildTasksManager(theme),
    );
  }

  // ==========================================
  // 1. TASKS MANAGER SCREEN
  // ==========================================
  Widget _buildTasksManager(ThemeData theme) {
    final tasksAsync = ref.watch(tasksListProvider);
    final completionsAsync = ref.watch(completionsForDateProvider(_selectedDateStr));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tasksListProvider);
        ref.invalidate(completionsForDateProvider(_selectedDateStr));
        ref.invalidate(weeklyStatsProvider);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, context.navBarInset + 152),
        children: [
          // A. Horizontal Date Strip
          _buildDateSelectorStrip(theme),
          const SizedBox(height: 16),

          // B. Daily Progress Overview Card
          tasksAsync.when(
            data: (tasks) {
              final completions = completionsAsync.value ?? [];
              final completedCount = completions.where((c) => c.completed).length;
              final totalCount = tasks.length;
              final ratio = totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

              return _buildDailyProgressCard(theme, completedCount, totalCount, ratio);
            },
            loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // C. Filter Chips
          _buildFilterChips(theme),
          const SizedBox(height: 14),

          // D. Tasks List
          tasksAsync.when(
            data: (tasks) {
              final completions = completionsAsync.value ?? [];
              final completedTaskIds = completions.where((c) => c.completed).map((c) => c.taskId).toSet();

              // Filter tasks by category
              final filteredTasks = tasks.where((t) {
                if (_selectedCategory == 'all') return true;
                final meta = _resolveTaskMeta(t.title);
                return meta.category == _selectedCategory;
              }).toList();

              if (filteredTasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.checklist_rounded, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 12),
                        ArabicText(
                          'لا توجد عبادات في هذا القسم حالياً',
                          style: GoogleFonts.cairo(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...filteredTasks.map((task) {
                    final isDone = completedTaskIds.contains(task.id);
                    final meta = _resolveTaskMeta(task.title);

                    return _buildTaskCard(theme, task, isDone, meta);
                  }),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showAddTaskSheet(theme),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: ArabicText(
                      'إضافة طاعة أو عبادة جديدة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )),
            error: (err, _) => Center(
              child: ArabicText('تعذر تحميل المهام: $err', style: GoogleFonts.cairo(color: theme.colorScheme.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorStrip(ThemeData theme) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: 14,
        itemBuilder: (context, index) {
          final day = now.subtract(Duration(days: 6 - index));
          final dayStr = DateFormat('yyyy-MM-dd').format(day);
          final isSelected = dayStr == _selectedDateStr;
          final isToday = dayStr == todayStr;

          final arabicDayName = DateFormat('E', 'ar').format(day);
          final dayNum = day.day.toString();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDate = day);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isToday ? theme.colorScheme.primary.withValues(alpha: 0.12) : theme.cardColor),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isToday ? theme.colorScheme.primary.withValues(alpha: 0.3) : theme.dividerColor.withValues(alpha: 0.5)),
                    width: isSelected || isToday ? 1.5 : 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ArabicText(
                      arabicDayName,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.onPrimary : theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ArabicText(
                      dayNum,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyProgressCard(ThemeData theme, int completed, int total, double ratio) {
    String motivation;
    if (ratio == 1.0 && total > 0) {
      motivation = 'ما شاء الله! يوم مبارك مكتمل بالطاعات والبركات 🌟';
    } else if (ratio >= 0.6) {
      motivation = 'أحسنت همّتك! طاعات تقربك إلى الجنة ونعيمها ✨';
    } else if (ratio > 0.0) {
      motivation = 'بداية طيبة، استمر واملأ صحيفتك بالحسنات 🌿';
    } else {
      motivation = '«أحبُّ الأعمالِ إلى الله أدومُها وإن قلَّ» ✨';
    }

    final isToday = _selectedDateStr == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 6,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                    ArabicText(
                      '${(ratio * 100).toInt()}%',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ArabicText(
                              isToday ? 'إنجاز اليوم' : 'إنجاز يوم ${DateFormat('dd MMMM', 'ar').format(_selectedDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ArabicText(
                              '$completed من $total مكتمل',
                              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ArabicText(
                        motivation,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final filters = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'prayers', 'label': 'الصلوات والسنن'},
      {'key': 'quran', 'label': 'القرآن الكريم'},
      {'key': 'adhkar', 'label': 'الأذكار والتسبيح'},
      {'key': 'habits', 'label': 'العادات والصدقة'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedCategory == f['key'];
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: FilterChip(
              label: ArabicText(f['label']!, style: GoogleFonts.cairo(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedCategory = f['key']!);
              },
              backgroundColor: theme.cardColor,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              side: BorderSide(
                color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(ThemeData theme, ReligiousTaskData task, bool isDone, _TaskMeta meta) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDone ? meta.color.withValues(alpha: 0.4) : theme.dividerColor.withValues(alpha: 0.6),
          width: isDone ? 1.4 : 0.8,
        ),
      ),
      color: isDone ? meta.color.withValues(alpha: 0.05) : theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _toggleTask(task.id, isDone),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone ? meta.color.withValues(alpha: 0.15) : meta.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(meta.icon, color: meta.color, size: 22),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      task.title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ArabicText(
                      meta.subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Action button (if available and not yet done)
              if (meta.actionLabel != null && meta.actionRoute != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => context.push(meta.actionRoute!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ArabicText(
                              meta.actionLabel!,
                              maxLines: 1,
                              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: meta.color),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: meta.color),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Checkbox Toggle
              IconButton(
                icon: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isDone ? meta.color : theme.hintColor.withValues(alpha: 0.5),
                  size: 26,
                ),
                onPressed: () => _toggleTask(task.id, isDone),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. STATISTICS DASHBOARD SCREEN
  // ==========================================
  Widget _buildStatsDashboard(ThemeData theme) {
    final overallAsync = ref.watch(overallStatsSummaryProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(overallStatsSummaryProvider);
        ref.invalidate(weeklyStatsProvider);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, context.navBarInset + 152),
        children: [
          // A. Streak Banner
          overallAsync.when(
            data: (summary) {
              final streak = (summary['currentStreak'] as int?) ?? 0;
              final bestStreak = (summary['bestStreak'] as int?) ?? 0;
              return _buildStreakCard(theme, streak, bestStreak);
            },
            loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),

          // B. 4-Grid Key Metrics
          overallAsync.when(
            data: (summary) => _buildKeyMetricsGrid(theme, summary),
            loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // C. Weekly Commitment Chart
          ArabicText(
            'مؤشر الالتزام بالطاعات (آخر 7 أيام)',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          weeklyStatsAsync.when(
            data: (stats) => _buildWeeklyBarChartCard(theme, stats),
            loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
            error: (err, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ArabicText('تعذر تحميل الرسم البياني: $err'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // D. Milestones & Badges
          ArabicText(
            'أوسمة الفخر والإنجاز الإيماني',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          overallAsync.when(
            data: (summary) => _buildBadgesSection(theme, summary),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // E. Navigation Actions
          _buildActionNavigationTile(
            theme: theme,
            title: 'سجل العبادات والتقويم التاريخي',
            subtitle: 'استعراض إنجازات الأيام السابقة ونقاط التقدم',
            icon: Icons.calendar_month_rounded,
            onTap: () => context.push('/tracker/history'),
          ),
          const SizedBox(height: 10),
          _buildActionNavigationTile(
            theme: theme,
            title: 'تخصيص جدول العبادات والسنن',
            subtitle: 'إضافة أو حذف الطاعات المخصصة والرواتب',
            icon: Icons.tune_rounded,
            onTap: () => context.push('/tracker/customization'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ThemeData theme, int streak, int bestStreak) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B),
            const Color(0xFFD97706),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ArabicText(
                        '$streak يوم متتالي',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (bestStreak > 0)
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ArabicText(
                            'أفضل سلسلة: $bestStreak',
                            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ArabicText(
                  streak > 0
                      ? 'ثباتك على الطاعة نور في دربك، استمر ولا تقطع السلسلة!'
                      : 'ابدأ سلسلتك اليوم، فالمداومة على القليل خير عظيم.',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid(ThemeData theme, Map<String, dynamic> summary) {
    final quranPages = (summary['totalQuranPages'] as int?) ?? 0;
    final tasbih = (summary['totalTasbih'] as int?) ?? 0;
    final adhkar = (summary['totalAdhkar'] as int?) ?? 0;
    final totalCompleted = (summary['totalCompletedTasks'] as int?) ?? 0;

    return LayoutBuilder(builder: (context, constraints) {
      // أعمدة متجاوبة: موبايل 2، تابلت/عريض 3-4
      final columns = AppInsets.columnsFor(
        constraints.maxWidth,
        targetTile: 170,
        min: 2,
        max: 4,
      );
      return GridView.count(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        children: [
        _buildMetricItem(
          theme: theme,
          title: 'صفحات القرآن',
          value: '$quranPages',
          unit: 'صفحة مقروءة',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF0D9488),
        ),
        _buildMetricItem(
          theme: theme,
          title: 'عداد التسبيح',
          value: '$tasbih',
          unit: 'تسبيحة واستغفار',
          icon: Icons.fingerprint_rounded,
          color: const Color(0xFF3B82F6),
        ),
        _buildMetricItem(
          theme: theme,
          title: 'ختمات الأذكار',
          value: '$adhkar',
          unit: 'جلسة ذكر تامة',
          icon: Icons.wb_twilight_rounded,
          color: const Color(0xFFEC4899),
        ),
        _buildMetricItem(
          theme: theme,
          title: 'إجمالي الطاعات',
          value: '$totalCompleted',
          unit: 'طاعة مسجلة',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
        ),
        ],
      );
    });
  }

  Widget _buildMetricItem({
    required ThemeData theme,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: ArabicText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ArabicText(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          ArabicText(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(fontSize: 10, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChartCard(ThemeData theme, Map<String, double> stats) {
    if (stats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ArabicText('لا توجد بيانات أسبوعية كافية حالياً.', style: GoogleFonts.cairo()),
          ),
        ),
      );
    }

    final entries = stats.entries.toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: 1.0,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final ratio = rod.toY;
                        final percent = (ratio * 100).round();
                        return BarTooltipItem(
                          '$percent% إنجاز',
                          GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                          final dateStr = entries[index].key;
                          final date = DateTime.tryParse(dateStr);
                          final dayName = date != null ? DateFormat('E', 'ar').format(date) : '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ArabicText(
                              dayName,
                              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(entries.length, (i) {
                    final ratio = entries[i].value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: ratio > 0 ? ratio : 0.04,
                          color: ratio >= 0.8
                              ? const Color(0xFF10B981)
                              : (ratio >= 0.4 ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.3)),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(ThemeData theme, Map<String, dynamic> summary) {
    final quranPages = (summary['totalQuranPages'] as int?) ?? 0;
    final tasbih = (summary['totalTasbih'] as int?) ?? 0;
    final streak = (summary['currentStreak'] as int?) ?? 0;
    final totalTasks = (summary['totalCompletedTasks'] as int?) ?? 0;

    final badges = [
      _BadgeItem(
        title: 'رفيق القرآن',
        desc: 'قراءة 10 صفحات من المصحف',
        isUnlocked: quranPages >= 10,
        progress: (quranPages / 10).clamp(0.0, 1.0),
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF0D9488),
      ),
      _BadgeItem(
        title: 'اللسان الذاكر',
        desc: '100 تسبيحة بالمسبحة',
        isUnlocked: tasbih >= 100,
        progress: (tasbih / 100).clamp(0.0, 1.0),
        icon: Icons.fingerprint_rounded,
        color: const Color(0xFF3B82F6),
      ),
      _BadgeItem(
        title: 'صاحب الهمّة',
        desc: 'سلسلة التزام 3 أيام متتالية',
        isUnlocked: streak >= 3,
        progress: (streak / 3).clamp(0.0, 1.0),
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _BadgeItem(
        title: 'المثابر الذهبي',
        desc: 'إتمام 25 طاعة إيمانية',
        isUnlocked: totalTasks >= 25,
        progress: (totalTasks / 25).clamp(0.0, 1.0),
        icon: Icons.military_tech_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      // أعمدة متجاوبة: موبايل 2، تابلت/عريض 3-4
      final columns = AppInsets.columnsFor(
        constraints.maxWidth,
        targetTile: 150,
        min: 2,
        max: 4,
      );
      return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: badges.map((badge) {
        return Container(
          decoration: BoxDecoration(
            color: badge.isUnlocked ? badge.color.withValues(alpha: 0.08) : theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: badge.isUnlocked ? badge.color.withValues(alpha: 0.5) : theme.dividerColor.withValues(alpha: 0.5),
              width: badge.isUnlocked ? 1.5 : 0.8,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: badge.isUnlocked ? badge.color.withValues(alpha: 0.2) : theme.dividerColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badge.icon,
                      color: badge.isUnlocked ? badge.color : theme.hintColor.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                  if (badge.isUnlocked)
                    Icon(Icons.verified_rounded, color: badge.color, size: 18)
                  else
                    ArabicText(
                      '${(badge.progress * 100).toInt()}%',
                      style: GoogleFonts.cairo(fontSize: 10, color: theme.hintColor),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArabicText(
                    badge.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked ? badge.color : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  ArabicText(
                    badge.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
      );
    });
  }

  Widget _buildActionNavigationTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: ArabicText(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: ArabicText(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: theme.hintColor)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

class _TaskMeta {
  final IconData icon;
  final Color color;
  final String subtitle;
  final String category;
  final String? actionLabel;
  final String? actionRoute;

  _TaskMeta({
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.category,
    this.actionLabel,
    this.actionRoute,
  });
}

class _BadgeItem {
  final String title;
  final String desc;
  final bool isUnlocked;
  final double progress;
  final IconData icon;
  final Color color;

  _BadgeItem({
    required this.title,
    required this.desc,
    required this.isUnlocked,
    required this.progress,
    required this.icon,
    required this.color,
  });
}
