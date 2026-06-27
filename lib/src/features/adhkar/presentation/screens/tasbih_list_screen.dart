import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/adhkar_repository_provider.dart';
import '../../domain/entities/adhkar_entities.dart';

final tasbihListProvider = FutureProvider<List<Tasbih>>((ref) async {
  final repo = ref.watch(adhkarRepositoryProvider);
  return await repo.getAllTasbihs();
});

final tasbihLifetimeCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(adhkarRepositoryProvider);
  return await repo.getHistoryTotalTasbihCount();
});

class TasbihListScreen extends ConsumerWidget {
  const TasbihListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasbihsAsync = ref.watch(tasbihListProvider);
    final totalLifetimeAsync = ref.watch(tasbihLifetimeCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المسبحة الإلكترونية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTasbihDialog(context, ref),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Section
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          tasbihsAsync.when(
                            data: (list) => Text(
                              list.length.toString(),
                              style: GoogleFonts.robotoMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            error: (_, __) => const Text('0'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'عدد الأذكار',
                            style: GoogleFonts.cairo(fontSize: 12, color: theme.disabledColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          totalLifetimeAsync.when(
                            data: (count) => Text(
                              count.toString(),
                              style: GoogleFonts.robotoMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            error: (_, __) => const Text('0'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'إجمالي التسبيحات',
                            style: GoogleFonts.cairo(fontSize: 12, color: theme.disabledColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fade(),
            
            const SizedBox(height: 24),

            tasbihsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أذكار مضافة للتسبيح.',
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                  );
                }

                // Split into Basic/Default and Custom (default is id <= 5 based on initializer)
                final defaults = list.where((t) => t.id <= 5).toList();
                final customs = list.where((t) => t.id > 5).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (defaults.isNotEmpty) ...[
                      Text(
                        'التسابيح الأساسية',
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
                        itemCount: defaults.length,
                        itemBuilder: (context, idx) {
                          final t = defaults[idx];
                          return _buildTasbihTile(context, ref, t, theme, idx);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (customs.isNotEmpty) ...[
                      Text(
                        'أذكاري المخصصة',
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
                        itemCount: customs.length,
                        itemBuilder: (context, idx) {
                          final t = customs[idx];
                          return _buildTasbihTile(context, ref, t, theme, idx);
                        },
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ في تحميل الأذكار: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbihTile(BuildContext context, WidgetRef ref, Tasbih t, ThemeData theme, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => context.push('/adhkar/tasbih/counting/${t.id}'),
        title: Text(
          t.phrase,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'الهدف: ${t.target} - المكتمل اليوم: ${t.count}',
            style: GoogleFonts.cairo(fontSize: 12, color: theme.colorScheme.secondary, fontWeight: FontWeight.w600),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
            if (t.id > 5) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final repo = ref.read(adhkarRepositoryProvider);
                  await repo.deleteTasbih(t.id);
                  ref.invalidate(tasbihListProvider);
                },
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: (30 * index).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }

  void _showAddTasbihDialog(BuildContext context, WidgetRef ref) {
    final phraseController = TextEditingController();
    final targetController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إضافة تسبيحة مخصصة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phraseController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'العبارة (مثال: أستغفر الله)',
                labelStyle: GoogleFonts.cairo(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'العدد المستهدف',
                labelStyle: GoogleFonts.cairo(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () async {
              final phrase = phraseController.text.trim();
              final target = int.tryParse(targetController.text) ?? 33;
              if (phrase.isNotEmpty) {
                final repo = ref.read(adhkarRepositoryProvider);
                await repo.createCustomTasbih(phrase, target);
                ref.invalidate(tasbihListProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
