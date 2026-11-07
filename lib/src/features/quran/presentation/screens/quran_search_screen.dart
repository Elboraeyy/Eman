import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/quran_entities.dart' as quran;
import '../../data/repositories/quran_repository_provider.dart';
import 'quran_index_screen.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

final quranSearchQueryProvider = StateProvider<String>((ref) => '');

final quranSurahSearchResultsProvider = FutureProvider<List<quran.Surah>>((ref) async {
  final query = ref.watch(quranSearchQueryProvider).trim();
  if (query.isEmpty) return [];
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.searchSurahs(query);
});

final quranAyahSearchResultsProvider = FutureProvider<List<quran.Ayah>>((ref) async {
  final query = ref.watch(quranSearchQueryProvider).trim();
  if (query.isEmpty) return [];
  if (RegExp(r'^\d+[:\s]+\d+$').hasMatch(query)) return [];
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.searchAyat(query);
});

final quranParsedAyahProvider = FutureProvider<quran.Ayah?>((ref) async {
  final query = ref.watch(quranSearchQueryProvider).trim();
  if (query.isEmpty) return null;

  final repo = ref.watch(quranRepositoryProvider);

  // 1. Try format "2:255" or "2 255"
  final numericRegExp = RegExp(r'^(\d+)[:\s]+(\d+)$');
  if (numericRegExp.hasMatch(query)) {
    final match = numericRegExp.firstMatch(query)!;
    final surahNum = int.tryParse(match.group(1) ?? '') ?? 0;
    final ayahNum = int.tryParse(match.group(2) ?? '') ?? 0;
    if (surahNum >= 1 && surahNum <= 114) {
      return await repo.getAyah(surahNum, ayahNum);
    }
  }

  // 2. Try format "البقرة 255" or "سورة البقرة 255"
  final textNumRegExp = RegExp(r'^([^\d]+)\s+(\d+)$');
  if (textNumRegExp.hasMatch(query)) {
    final match = textNumRegExp.firstMatch(query)!;
    var surahNamePart = (match.group(1) ?? '').trim();
    if (surahNamePart.startsWith('سورة')) {
      surahNamePart = surahNamePart.replaceFirst('سورة', '').trim();
    }
    final ayahNum = int.tryParse(match.group(2) ?? '') ?? 0;

    final surahs = await repo.getAllSurahs();
    final matchedSurahs = surahs.where((s) => 
      s.nameArabic.replaceAll(' ', '').contains(surahNamePart.replaceAll(' ', '')) ||
      s.name.replaceAll(' ', '').contains(surahNamePart.replaceAll(' ', ''))
    ).toList();

    if (matchedSurahs.isNotEmpty) {
      return await repo.getAyah(matchedSurahs.first.number, ayahNum);
    }
  }

  return null;
});

final quranParsedPageProvider = Provider<int?>((ref) {
  final query = ref.watch(quranSearchQueryProvider).trim();
  if (query.isEmpty) return null;
  final pageNum = int.tryParse(query);
  if (pageNum != null && pageNum >= 1 && pageNum <= 604) {
    return pageNum;
  }
  return null;
});

class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      ref.read(quranSearchQueryProvider.notifier).state = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(quranSearchQueryProvider);
    final surahsAsync = ref.watch(quranSurahSearchResultsProvider);
    final ayahsAsync = ref.watch(quranAyahSearchResultsProvider);
    final parsedAyahAsync = ref.watch(quranParsedAyahProvider);
    final parsedPage = ref.watch(quranParsedPageProvider);

    final showResults = query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'البحث في المصحف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة، آية، كلمة، أو رقم صفحة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(quranSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          Expanded(
            child: !showResults
                ? _buildEmptyState(theme)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (parsedPage != null) ...[
                          _buildSectionHeader(theme, 'الانتقال السريع'),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
                            ),
                            child: ListTile(
                              onTap: () => context.push('/quran/mushaf/$parsedPage'),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.menu_book, color: theme.colorScheme.primary),
                              ),
                              title: ArabicText(
                                'الانتقال إلى صفحة $parsedPage في المصحف',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_forward_ios,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],

                        parsedAyahAsync.when(
                          data: (ayah) {
                            if (ayah == null) return const SizedBox();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSectionHeader(theme, 'الآية المحددة'),
                                const SizedBox(height: 8),
                                _buildAyahResultCard(context, ayah, theme),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (error, stackTrace) => const SizedBox(),
                        ),

                        surahsAsync.when(
                          data: (surahs) {
                            if (surahs.isEmpty) return const SizedBox();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSectionHeader(theme, 'السور المطابقة'),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: surahs.length,
                                  itemBuilder: (context, idx) {
                                    final s = surahs[idx];
                                    return _buildSurahResultCard(context, s, theme);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => const SizedBox(),
                        ),

                        ayahsAsync.when(
                          data: (ayahs) {
                            if (ayahs.isEmpty) return const SizedBox();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSectionHeader(theme, 'الآيات المطابقة'),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: ayahs.length,
                                  itemBuilder: (context, idx) {
                                    final a = ayahs[idx];
                                    return _buildAyahResultCard(context, a, theme);
                                  },
                                ),
                                const SizedBox(height: 32),
                              ],
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (error, stackTrace) => const SizedBox(),
                        ),

                        _buildNoResultsPlaceholder(ref, theme, parsedPage, parsedPage != null),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: ArabicText(
        title,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSurahResultCard(BuildContext context, quran.Surah s, ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final startPagesAsync = ref.watch(startPagesProvider);
        final startPage = startPagesAsync.value?[s.number] ?? 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
          ),
          child: ListTile(
            onTap: () => context.push('/quran/mushaf/$startPage'),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              ),
              child: Center(
                child: ArabicText(
                  s.number.toString(),
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            title: ArabicText(
              'سورة ${s.nameArabic}',
              style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
            ),
            subtitle: ArabicText(
              'صفحة $startPage • ${s.numberOfAyahs} آية • ${s.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
              style: GoogleFonts.cairo(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
            ),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAyahResultCard(BuildContext context, quran.Ayah a, ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
          ),
          child: InkWell(
            onTap: () => context.push('/quran/mushaf/${a.page}'),
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
                        future: ref.read(quranRepositoryProvider).getSurahByNumber(a.surahNumber),
                        builder: (context, snapshot) {
                          final name = snapshot.data?.nameArabic ?? '';
                          return ArabicText(
                            'سورة $name - آية ${a.numberInSurah}',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.secondary,
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ArabicText(
                          'صفحة ${a.page}',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ArabicText(
                    a.textUthmani.isNotEmpty ? a.textUthmani : a.text,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B1E1E),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResultsPlaceholder(WidgetRef ref, ThemeData theme, int? parsedPage, bool hasPage) {
    final surahs = ref.watch(quranSurahSearchResultsProvider).value ?? [];
    final ayahs = ref.watch(quranAyahSearchResultsProvider).value ?? [];
    final parsedAyah = ref.watch(quranParsedAyahProvider).value;

    if (surahs.isEmpty && ayahs.isEmpty && parsedAyah == null && !hasPage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 60, color: theme.disabledColor),
            const SizedBox(height: 12),
            ArabicText(
              'لا توجد نتائج بحث مطابقة',
              style: GoogleFonts.cairo(fontSize: 15, color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          ArabicText(
            'البحث المباشر في المصحف',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ArabicText(
              'اكتب كلمة، اسم سورة، رقم صفحة (1-604)، أو مرجع للآية (مثل: 2:255 أو البقرة 255) للبحث الفوري.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
            ),
          ),
        ],
      ),
    ).animate().fade();
  }
}
