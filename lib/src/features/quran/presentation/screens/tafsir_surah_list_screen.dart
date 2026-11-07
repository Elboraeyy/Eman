import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/quran_entities.dart';
import '../../data/repositories/quran_repository_provider.dart';
import 'quran_index_screen.dart'; // Reuses surahsListProvider, juzListProvider
import 'package:iman/src/core/widgets/arabic_text.dart';

class TafsirSurahListScreen extends ConsumerStatefulWidget {
  const TafsirSurahListScreen({super.key});

  @override
  ConsumerState<TafsirSurahListScreen> createState() => _TafsirSurahListScreenState();
}

class _TafsirSurahListScreenState extends ConsumerState<TafsirSurahListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahsAsync = ref.watch(surahsListProvider);
    final juzAsync = ref.watch(juzListProvider);

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'تفسير القرآن الكريم',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          indicatorColor: theme.colorScheme.primary,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Surah selection
          Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن سورة للتفسير...',
                    hintStyle: GoogleFonts.cairo(fontSize: 14),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: surahsAsync.when(
                  data: (surahs) {
                    final filteredSurahs = surahs.where((s) {
                      return s.nameArabic.contains(_searchQuery) ||
                          s.nameEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          s.number.toString() == _searchQuery;
                    }).toList();

                    if (filteredSurahs.isEmpty) {
                      return Center(
                        child: ArabicText(
                          'لا توجد نتائج مطابقة للتفسير',
                          style: GoogleFonts.cairo(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredSurahs.length,
                      separatorBuilder: (context, index) => Divider(color: theme.dividerColor, height: 1),
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            ),
                            child: Center(
                              child: ArabicText(
                                surah.number.toString(),
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          title: ArabicText(
                            surah.nameArabic,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: ArabicText(
                            '${surah.numberOfAyahs} آية - ${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                            style: GoogleFonts.cairo(fontSize: 12),
                          ),
                          trailing: Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            context.push('/quran/tafsir/detail/${surah.number}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: ArabicText('خطأ في تحميل الفهرس: $err')),
                ),
              ),
            ],
          ),

          // Tab 2: Juz selection
          juzAsync.when(
            data: (juzs) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: juzs.length,
                separatorBuilder: (context, index) => Divider(color: theme.dividerColor, height: 1),
                itemBuilder: (context, index) {
                  final boundary = juzs[index];
                  final juzNum = boundary.juz;

                  return InkWell(
                    onTap: () {
                      context.push('/quran/tafsir/detail/${boundary.surahNumber}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                                  border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.15)),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.chrome_reader_mode_outlined,
                                    size: 20,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ArabicText(
                                    'الجزء $juzNum',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  FutureBuilder<Surah?>(
                                    future: ref.read(quranRepositoryProvider).getSurahByNumber(boundary.surahNumber),
                                    builder: (context, snapshot) {
                                      final surahName = snapshot.data?.nameArabic ?? '';
                                      return ArabicText(
                                        'يبدأ من سورة: $surahName',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: theme.textTheme.bodyMedium?.color,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: ArabicText('خطأ في تحميل الأجزاء: $err')),
          ),
        ],
      ),
    );
  }
}
