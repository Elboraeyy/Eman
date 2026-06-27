import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/quran_repository_provider.dart';
import '../../domain/entities/quran_entities.dart';
import 'mushaf_screen.dart'; // Reuses verseTafsirProvider
import 'surah_detail_screen.dart'; // Reuses singleSurahProvider, surahDetailsProvider

class TafsirDetailScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  const TafsirDetailScreen({super.key, required this.surahNumber});

  @override
  ConsumerState<TafsirDetailScreen> createState() => _TafsirDetailScreenState();
}

class _TafsirDetailScreenState extends ConsumerState<TafsirDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _muyassarId = 'ar.muyassar';
  final String _jalalaynId = 'ar.jalalayn';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahAsync = ref.watch(singleSurahProvider(widget.surahNumber));
    final ayahsAsync = ref.watch(surahDetailsProvider(widget.surahNumber));

    return Scaffold(
      appBar: AppBar(
        title: surahAsync.when(
          data: (surah) => Text(
            'تفسير سورة ${surah?.nameArabic ?? ""}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, _) => const Text('التفسير'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final surahName = surahAsync.value?.nameArabic ?? '';
              SharePlus.instance.share(
                ShareParams(text: 'اقرأ تفسير سورة $surahName عبر تطبيق زاد مسلم.'),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          indicatorColor: theme.colorScheme.primary,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'التفسير الميسر'),
            Tab(text: 'تفسير الجلالين'),
          ],
        ),
      ),
      body: ayahsAsync.when(
        data: (ayahs) {
          if (ayahs.isEmpty) {
            return Center(
              child: Text(
                'لا توجد بيانات متوفرة حالياً.',
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTafsirList(ayahs, theme, _muyassarId),
              _buildTafsirList(ayahs, theme, _jalalaynId),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('حدث خطأ أثناء تحميل التفسير: $err')),
      ),
    );
  }

  Widget _buildTafsirList(List<Ayah> ayahs, ThemeData theme, String tafsirId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        final tafsirAsync = ref.watch(verseTafsirProvider((
          surah: ayah.surahNumber,
          ayah: ayah.numberInSurah,
          tafsirId: tafsirId
        )));

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.dividerColor, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayah Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'الآية ${ayah.numberInSurah}',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final textToCopy = 'قال تعالى: {${ayah.textUthmani}}\nالتفسير:\n${tafsirAsync.value ?? ""}';
                        Clipboard.setData(ClipboardData(text: textToCopy));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم نسخ نص الآية والتفسير',
                              style: GoogleFonts.cairo(),
                              textAlign: TextAlign.center,
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Arabic text of the verse
                Text(
                  ayah.textUthmani.isNotEmpty ? ayah.textUthmani : ayah.text,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    height: 1.8,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Tafsir Text
                tafsirAsync.when(
                  data: (text) => Text(
                    text,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      height: 1.6,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'حدث خطأ في تحميل التفسير: $err',
                    style: GoogleFonts.cairo(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: (30 * index).ms).fadeIn().slideY(begin: 0.05, end: 0);
      },
    );
  }
}
