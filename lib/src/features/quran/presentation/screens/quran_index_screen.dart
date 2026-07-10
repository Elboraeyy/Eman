import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/quran_entities.dart';
import '../../data/repositories/quran_repository_provider.dart';
import '../controllers/quran_progress_controller.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

final surahsListProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getAllSurahs();
});

final startPagesProvider = FutureProvider<Map<int, int>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getSurahStartPages();
});

final juzListProvider = FutureProvider<List<Ayah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getJuzBoundaries();
});


class QuranJuzData {
  final int id;
  final String name;
  final List<QuranJuzVerseData> verses;

  QuranJuzData({required this.id, required this.name, required this.verses});
}

class QuranJuzVerseData {
  final String text;
  final String details;
  final String badge;
  final int surahNumber;
  final int startPage;

  QuranJuzVerseData({
    required this.text,
    required this.details,
    required this.badge,
    required this.surahNumber,
    required this.startPage,
  });
}

final quranJuzsProvider = FutureProvider<List<QuranJuzData>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final surahs = await repo.getAllSurahs();
  final boundaries = await repo.getJuzBoundaries();
  final startPages = await repo.getSurahStartPages();

  if (surahs.isEmpty || boundaries.isEmpty) return [];

  final List<QuranJuzData> juzs = [];
  for (int i = 0; i < boundaries.length; i++) {
    final boundary = boundaries[i];
    final startSurahNumber = boundary.surahNumber;
    final endSurahNumber = (i < boundaries.length - 1) ? boundaries[i + 1].surahNumber : 114;

    final juzSurahs = surahs.where((s) => s.number >= startSurahNumber && s.number <= endSurahNumber).toList();
    final List<QuranJuzVerseData> verses = [];

    for (final surah in juzSurahs) {
      String? textDesc;
      if (surah.number == startSurahNumber && surah.number == endSurahNumber) {
        final endAyah = (i < boundaries.length - 1) ? boundaries[i + 1].numberInSurah - 1 : surah.numberOfAyahs;
        if (boundary.numberInSurah == 1 && endAyah == surah.numberOfAyahs) {
          textDesc = 'السورة كاملة';
        } else {
          textDesc = 'الآيات ${boundary.numberInSurah} - $endAyah';
        }
      } else if (surah.number == startSurahNumber) {
        if (boundary.numberInSurah == 1) {
          textDesc = 'السورة كاملة';
        } else {
          textDesc = 'من آية ${boundary.numberInSurah} إلى آخر السورة';
        }
      } else if (surah.number == endSurahNumber) {
        final endAyah = (i < boundaries.length - 1) ? boundaries[i + 1].numberInSurah - 1 : surah.numberOfAyahs;
        if (endAyah == surah.numberOfAyahs) {
          textDesc = 'السورة كاملة';
        } else if (endAyah > 0) {
          textDesc = 'من بداية السورة إلى آية $endAyah';
        } else {
          textDesc = null;
        }
      } else {
        textDesc = 'السورة كاملة';
      }

      if (textDesc != null) {
        int surahStartPage = startPages[surah.number] ?? 1;
        if (surah.number == startSurahNumber) {
          final firstAyah = await repo.getAyah(boundary.surahNumber, boundary.numberInSurah);
          if (firstAyah != null) {
            surahStartPage = firstAyah.page;
          }
        }
        
        verses.add(QuranJuzVerseData(
          text: textDesc,
          details: 'سورة ${surah.nameArabic}',
          badge: surah.number.toString(),
          surahNumber: surah.number,
          startPage: surahStartPage,
        ));
      }
    }

    juzs.add(QuranJuzData(
      id: boundary.juz,
      name: 'الجزء ${boundary.juz}',
      verses: verses,
    ));
  }

  return juzs;
});

class QuranIndexScreen extends ConsumerStatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  ConsumerState<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends ConsumerState<QuranIndexScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  int? _expandedJuzId = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_selectedIndex != _tabController.index) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahsAsync = ref.watch(surahsListProvider);
    final startPagesAsync = ref.watch(startPagesProvider);
    final juzsAsync = ref.watch(quranJuzsProvider);
    final lastReadPage = ref.watch(lastReadPageNotifierProvider);
    final customBookmarks = ref.watch(customBookmarksNotifierProvider);

    final favoritesCount = customBookmarks.length;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        title: ArabicText(
          'القرآن الكريم',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث في المصحف',
            onPressed: () => context.push('/quran/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              labelPadding: EdgeInsets.zero,
              tabs: [
                _buildTabItem(theme, 'السور', '114', _selectedIndex == 0),
                _buildTabItem(theme, 'الأجزاء', '30', _selectedIndex == 1),
                _buildTabItem(theme, 'العلامات', '$favoritesCount', _selectedIndex == 2),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                surahsAsync.when(
                  data: (surahs) {
                    final startPages = startPagesAsync.value ?? {};
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        final startPage = startPages[surah.number] ?? 1;
                        return _buildSurahCard(context, surah, startPage, theme);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: ArabicText('خطأ في تحميل الفهرس: $err')),
                ),

                juzsAsync.when(
                  data: (juzs) {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: juzs.length,
                      itemBuilder: (context, index) {
                        final juz = juzs[index];
                        return QuranJuzAccordion(
                          juz: juz,
                          isExpanded: _expandedJuzId == juz.id,
                          onExpansionChanged: (isExpanded) {
                            setState(() {
                              _expandedJuzId = isExpanded ? juz.id : null;
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: ArabicText('خطأ في تحميل الأجزاء: $err')),
                ),

                customBookmarks.isEmpty
                    ? _buildEmptyBookmarksState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        itemCount: customBookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = customBookmarks[index];
                          return _buildBookmarkCard(context, bookmark, theme);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: lastReadPage <= 1
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 95.0),
              child: SizedBox(
                height: 40.0,
                child: FloatingActionButton.extended(
                  onPressed: () => context.push('/quran/mushaf/$lastReadPage'),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: const StadiumBorder(),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: ArabicText(
                    'واصل القراءة (صفحة $lastReadPage)',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTabItem(ThemeData theme, String label, String count, bool isSelected) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ArabicText(
              count,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ArabicText(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Surah surah, int startPage, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: () => context.push('/quran/mushaf/$startPage'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    ArabicText(
                      surah.number.toString(),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      'سورة ${surah.nameArabic}',
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ArabicText(
                          surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.fiber_manual_record,
                          size: 4,
                          color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        ArabicText(
                          '${surah.numberOfAyahs} آية',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ArabicText(
                    surah.nameEnglish,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  ArabicText(
                    'صفحة $startPage',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(BuildContext context, CustomBookmark bookmark, ThemeData theme) {
    final bookmarkColor = Color(bookmark.colorValue);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: () => context.push('/quran/mushaf/${bookmark.page}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: bookmarkColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      bookmark.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ArabicText(
                      'صفحة ${bookmark.page}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBookmarksState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.bookmark_border,
              size: 36,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          ArabicText(
            'لا توجد علامات حتى الآن',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ArabicText(
              'أضف علامة أثناء القراءة لتسهيل العودة إليها لاحقاً',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade();
  }
}

class QuranJuzAccordion extends StatelessWidget {
  final QuranJuzData juz;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const QuranJuzAccordion({
    super.key,
    required this.juz,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              onExpansionChanged(!isExpanded);
            },
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Center(
                child: ArabicText(
                  juz.id.toString(),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            title: ArabicText(
              juz.name,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: theme.colorScheme.primary,
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Column(
              children: juz.verses.map((verse) {
                return ListTile(
                  onTap: () => context.push('/quran/mushaf/${verse.startPage}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: ArabicText(
                    verse.details,
                    style: GoogleFonts.amiri(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  subtitle: ArabicText(
                    verse.text,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                    ),
                    child: ArabicText(
                      'صفحة ${verse.startPage}',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
