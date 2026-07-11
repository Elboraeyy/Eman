import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:zad/src/core/database/app_database.dart';
import '../../data/repositories/quran_repository_provider.dart';
import '../../domain/entities/quran_entities.dart';
import '../controllers/audio_player_controller.dart';
import 'mushaf_screen.dart'; // Reuses providers like verseTafsirProvider, isVerseFavoriteProvider
import 'package:zad/src/core/widgets/arabic_text.dart';

final surahDetailsProvider = FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getAyahsBySurah(surahNumber);
});

final singleSurahProvider = FutureProvider.family<Surah?, int>((ref, surahNumber) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getSurahByNumber(surahNumber);
});

class SurahDetailScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    ref.read(audioPlayerProvider.notifier).stop();
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
          data: (surah) => ArabicText(
            surah?.nameArabic ?? 'تفاصيل السورة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, _) => const ArabicText('خطأ'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          indicatorColor: theme.colorScheme.primary,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'النص القرآني'),
            Tab(text: 'الترجمة الإنجليزية'),
            Tab(text: 'التفسير الميسر'),
          ],
        ),
      ),
      body: ayahsAsync.when(
        data: (ayahs) {
          if (ayahs.isEmpty) {
            return Center(
              child: ArabicText(
                'لا توجد آيات متوفرة حالياً.',
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAyahListView(ayahs, theme, 0),
              _buildAyahListView(ayahs, theme, 1),
              _buildAyahListView(ayahs, theme, 2),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: ArabicText('حدث خطأ في تحميل السورة: $err')),
      ),
    );
  }

  Widget _buildAyahListView(List<Ayah> ayahs, ThemeData theme, int mode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        return _buildAyahItem(ayah, theme, mode, index);
      },
    );
  }

  Widget _buildAyahItem(Ayah ayah, ThemeData theme, int mode, int index) {
    final isFavAsync = ref.watch(isVerseFavoriteProvider((surah: ayah.surahNumber, ayah: ayah.numberInSurah)));
    
    // Providers for Translation and Tafsir
    final translationAsync = mode == 1
        ? ref.watch(verseTafsirProvider((surah: ayah.surahNumber, ayah: ayah.numberInSurah, tafsirId: 'en.asad')))
        : null;
    final muyassarAsync = mode == 2
        ? ref.watch(verseTafsirProvider((surah: ayah.surahNumber, ayah: ayah.numberInSurah, tafsirId: 'ar.muyassar')))
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Top action bar (number, play, favorite)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ayah indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: ArabicText(
                      ayah.numberInSurah.toString(),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                
                // Actions (Play, Favorite, Share)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () {
                        final shareText = 'قال تعالى:\n'
                            '« ${ayah.textUthmani} »\n\n'
                            '[سورة ${ayah.surahNumber}، الآية ${ayah.numberInSurah}]\n'
                            'تمت المشاركة من تطبيق زاد المسلم';
                        SharePlus.instance.share(ShareParams(text: shareText));
                      },
                    ),
                    isFavAsync.when(
                      data: (isFav) => IconButton(
                        icon: Icon(
                          isFav ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: isFav ? theme.colorScheme.secondary : Colors.grey,
                        ),
                        onPressed: () async {
                          final repo = ref.read(quranRepositoryProvider);
                          await repo.toggleVerseFavorite(ayah.surahNumber, ayah.numberInSurah);
                          ref.invalidate(isVerseFavoriteProvider((surah: ayah.surahNumber, ayah: ayah.numberInSurah)));
                          // Invalidate favorites list to refresh
                          ref.invalidate(favoriteVersesProvider);
                        },
                      ),
                      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => const SizedBox(),
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow, color: theme.colorScheme.primary, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(audioPlayerProvider.notifier).playAyah(
                              ref.read(audioPlayerProvider).activeReciterId,
                              ayah.surahNumber,
                              ayah.numberInSurah,
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Text Content based on mode
            if (mode == 0) ...[
              // Quranic text in Arabic
              ArabicText(
                ayah.textUthmani.isNotEmpty ? ayah.textUthmani : ayah.text,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B1E1E), // Deep Brown Text
                ),
                textAlign: TextAlign.right,
              ),
            ] else if (mode == 1) ...[
              // Arabic text on top, translation below
              ArabicText(
                ayah.textUthmani.isNotEmpty ? ayah.textUthmani : ayah.text,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              translationAsync!.when(
                data: (text) => ArabicText(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.left,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => ArabicText('Error loading translation: $err'),
              ),
            ] else if (mode == 2) ...[
              // Arabic text on top, Tafsir below
              ArabicText(
                ayah.textUthmani.isNotEmpty ? ayah.textUthmani : ayah.text,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              muyassarAsync!.when(
                data: (text) => ArabicText(
                  text,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.6,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => ArabicText('حدث خطأ في تحميل التفسير: $err'),
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: (30 * index).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}

// Provider defined for favorites screen usage
final favoriteVersesProvider = FutureProvider<List<Ayah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getFavoriteVerses();
});
