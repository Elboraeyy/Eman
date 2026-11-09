import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/tracker_repository_provider.dart';
import 'tracker_screen.dart'; // Reuses providers like tasksListProvider, completionsForDateProvider
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/responsive/app_insets.dart';

class TaskCustomizationScreen extends ConsumerWidget {
  const TaskCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksListProvider);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'تخصيص المهام والعبادات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskBottomSheet(context, ref, theme),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: ArabicText(
          'إضافة عبادة جديدة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final customTasks = tasks.where((t) => t.type == 'custom').toList();
          final defaultTasks = tasks.where((t) => t.type == 'default').toList();

          if (tasks.isEmpty) {
            return Center(
              child: ArabicText(
                'لا توجد عبادات مضافة.',
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 120 + context.navBarInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (customTasks.isNotEmpty) ...[
                  ArabicText(
                    'العبادات والمهام المخصصة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customTasks.length,
                    itemBuilder: (context, idx) {
                      final task = customTasks[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: theme.dividerColor, width: 0.8),
                        ),
                        child: ListTile(
                          title: ArabicText(
                            task.title,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          subtitle: ArabicText(
                            task.frequency == 'daily' ? 'تكرار يومي' : 'تكرار أسبوعي',
                            style: GoogleFonts.cairo(fontSize: 12, color: theme.colorScheme.secondary),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              final repo = ref.read(trackerRepositoryProvider);
                              await repo.deleteCustomTask(task.id);
                              ref.invalidate(tasksListProvider);
                              ref.invalidate(weeklyStatsProvider);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                
                ArabicText(
                  'العبادات اليومية الأساسية (غير قابلة للحذف)',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultTasks.length,
                  itemBuilder: (context, idx) {
                    final task = defaultTasks[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: theme.dividerColor, width: 0.8),
                      ),
                      child: ListTile(
                        title: ArabicText(
                          task.title,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: theme.disabledColor),
                        ),
                        subtitle: ArabicText(
                          'عبادة أساسية للتطبيق',
                          style: GoogleFonts.cairo(fontSize: 11, color: theme.disabledColor),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: ArabicText('خطأ في تحميل العبادات: $err')),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context, WidgetRef ref, ThemeData theme) {
    final titleController = TextEditingController();
    String frequency = 'daily';

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, AppInsets.sheetBottom(context, gap: 24)),
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
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  ArabicText(
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
                      labelText: 'اسم العبادة (مثال: صلاة الضحى، ورد أذكار)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Frequency Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: ArabicText('أسبوعي', style: GoogleFonts.cairo()),
                        selected: frequency == 'weekly',
                        onSelected: (selected) {
                          if (selected) setState(() => frequency = 'weekly');
                        },
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: ArabicText('يومي', style: GoogleFonts.cairo()),
                        selected: frequency == 'daily',
                        onSelected: (selected) {
                          if (selected) setState(() => frequency = 'daily');
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isNotEmpty) {
                        final repo = ref.read(trackerRepositoryProvider);
                        await repo.addCustomTask(title, frequency);
                        ref.invalidate(tasksListProvider);
                        ref.invalidate(weeklyStatsProvider);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: ArabicText('حفظ العبادة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
