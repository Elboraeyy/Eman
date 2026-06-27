import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:zad/src/features/quran/domain/entities/quran_entities.dart' as quran;
import 'package:zad/src/features/quran/data/repositories/quran_repository_provider.dart';
import 'package:zad/src/features/hadith/domain/entities/hadith_entities.dart' as hadith;
import 'package:zad/src/features/hadith/data/repositories/hadith_repository_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final favoriteVersesAsync = ref.watch(favoriteVersesProvider);
    final bookmarkedHadithsAsync = ref.watch(bookmarkedHadithsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المفضلة والمحفوظات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          indicatorColor: theme.colorScheme.primary,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'الآيات الكريمة'),
            Tab(text: 'الأحاديث الشريفة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Favorite Ayat
          favoriteVersesAsync.when(
            data: (verses) {
              if (verses.isEmpty) {
                return _buildEmptyState(
                  theme,
                  'لا توجد آيات محفوظة بعد',
                  'قم بحفظ الآيات أثناء قراءة القرآن لتظهر لك هنا.',
                  Icons.bookmark_border,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  return _buildVerseItem(verse, theme, index);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('حدث خطأ: $err')),
          ),

          // Tab 2: Bookmarked Hadiths
          bookmarkedHadithsAsync.when(
            data: (hadiths) {
              if (hadiths.isEmpty) {
                return _buildEmptyState(
                  theme,
                  'لا توجد أحاديث محفوظة بعد',
                  'قم بحفظ الأحاديث النبوية لتسهيل مراجعتها والرجوع إليها.',
                  Icons.bookmark_border,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: hadiths.length,
                itemBuilder: (context, index) {
                  final had = hadiths[index];
                  return _buildHadithItem(had, theme, index);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('حدث خطأ: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }

  Widget _buildVerseItem(quran.Ayah verse, ThemeData theme, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: InkWell(
        onTap: () => context.push('/quran/mushaf/${verse.page}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<quran.Surah?>(
                    future: ref.read(quranRepositoryProvider).getSurahByNumber(verse.surahNumber),
                    builder: (context, snapshot) {
                      final name = snapshot.data?.nameArabic ?? '';
                      return Text(
                        'سورة $name - آية ${verse.numberInSurah}',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark, color: theme.colorScheme.secondary, size: 20),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final repo = ref.read(quranRepositoryProvider);
                      await repo.toggleVerseFavorite(verse.surahNumber, verse.numberInSurah);
                      ref.invalidate(favoriteVersesProvider);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                verse.textUthmani.isNotEmpty ? verse.textUthmani : verse.text,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  height: 1.6,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B1E1E), // Deep Brown Text
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (30 * index).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildHadithItem(hadith.Hadith had, ThemeData theme, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: InkWell(
        onTap: () => context.push('/hadith/detail/${had.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'حديث ${had.id}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark, color: theme.colorScheme.secondary, size: 20),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final repo = ref.read(hadithRepositoryProvider);
                      await repo.toggleBookmark(had.id);
                      ref.invalidate(bookmarkedHadithsProvider);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                had.narrator,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                had.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (30 * index).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}
