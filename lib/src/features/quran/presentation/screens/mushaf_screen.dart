import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iman/src/core/database/app_database.dart';
import 'package:iman/src/core/database/database_provider.dart';
import 'package:iman/src/core/database/shared_preferences_provider.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/network/dio_provider.dart';
import '../../../../core/utils/font_loader_helper.dart';
import '../../data/repositories/quran_repository_provider.dart';
import '../../domain/entities/quran_entities.dart';
import '../controllers/audio_player_controller.dart';
import '../controllers/quran_progress_controller.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/widgets/surah_name_frame.dart';
import 'package:iman/src/core/constants/surah_names_tashkeel.dart';
import 'package:iman/src/core/responsive/app_insets.dart';

// Providers for page fetching and dynamic font loading
final qcfPageProvider = FutureProvider.family<QcfPage, int>((
  ref,
  pageNumber,
) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getQcfPage(pageNumber);
});

final pageFontProvider = FutureProvider.family<String, int>((
  ref,
  pageNumber,
) async {
  return await FontLoaderHelper.loadPageFont(pageNumber);
});

// Provider for Arabic text of the verse with SQLite caching
final verseArabicTextProvider =
    FutureProvider.family<String, ({int surah, int ayah})>((ref, arg) async {
      final repo = ref.watch(quranRepositoryProvider);

      // 1. Get from DB
      final ayah = await repo.getAyah(arg.surah, arg.ayah);
      if (ayah != null && ayah.text.isNotEmpty) {
        return ayah.text;
      }

      // 2. If empty, fetch from API
      final dio = ref.watch(dioProvider);
      try {
        final response = await dio.get(
          'https://api.alquran.cloud/v1/ayah/${arg.surah}:${arg.ayah}/quran-simple',
        );
        if (response.statusCode == 200) {
          final text = response.data['data']['text'] as String;

          // Update DB cache
          if (ayah != null) {
            final db = ref.read(databaseProvider);
            await (db.update(db.ayahs)..where(
                  (t) =>
                      t.surahNumber.equals(arg.surah) &
                      t.numberInSurah.equals(arg.ayah),
                ))
                .write(AyahsCompanion(textContent: Value(text)));
          }
          return text;
        }
      } catch (e) {
        debugPrint('Failed to fetch Arabic text for verse: $e');
      }

      return '';
    });

// Tafsir API fetch provider with SharedPreferences caching
final verseTafsirProvider =
    FutureProvider.family<String, ({int surah, int ayah, String tafsirId})>((
      ref,
      arg,
    ) async {
      final prefs = ref.watch(sharedPreferencesProvider);
      final cacheKey = 'tafsir_${arg.tafsirId}_${arg.surah}_${arg.ayah}';

      final cached = prefs.getString(cacheKey);
      if (cached != null) return cached;

      final dio = ref.watch(dioProvider);
      try {
        final response = await dio.get(
          'https://api.alquran.cloud/v1/ayah/${arg.surah}:${arg.ayah}/${arg.tafsirId}',
        );
        if (response.statusCode == 200) {
          final text = response.data['data']['text'] as String;
          await prefs.setString(cacheKey, text);
          return text;
        }
      } catch (e) {
        return 'تعذر تحميل التفسير حالياً. تأكد من اتصالك بالإنترنت.';
      }
      return 'تعذر تحميل التفسير.';
    });

// Favorite status provider for reactive UI updates
final isVerseFavoriteProvider =
    FutureProvider.family<bool, ({int surah, int ayah})>((ref, arg) async {
      final repo = ref.watch(quranRepositoryProvider);
      return await repo.isVerseFavorite(arg.surah, arg.ayah);
    });

class AyahPlacement {
  final QcfVerse verse;
  final int startIndex;
  final int endIndex;

  AyahPlacement({
    required this.verse,
    required this.startIndex,
    required this.endIndex,
  });
}

class MushafScreen extends ConsumerStatefulWidget {
  final int startPage;
  const MushafScreen({super.key, required this.startPage});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showOverlay = true;
  QcfVerse? _selectedVerse;
  StreamSubscription? _audioSubscription;

  List<Surah> _surahs = [];
  Map<int, int> _surahStartPages = {};

  static const Map<int, int> _juzStartPages = {
    1: 1,
    2: 22,
    3: 42,
    4: 62,
    5: 82,
    6: 102,
    7: 122,
    8: 142,
    9: 162,
    10: 182,
    11: 202,
    12: 222,
    13: 242,
    14: 262,
    15: 282,
    16: 302,
    17: 322,
    18: 342,
    19: 362,
    20: 382,
    21: 402,
    22: 422,
    23: 442,
    24: 462,
    25: 482,
    26: 502,
    27: 522,
    28: 542,
    29: 562,
    30: 582,
  };

  void _preloadAdjacentPages(int currentPage) {
    // Preload next 2 pages and previous page to ensure completely smooth flipping
    final pagesToPreload = [
      currentPage + 1,
      currentPage + 2,
      if (currentPage > 1) currentPage - 1,
    ];

    for (final page in pagesToPreload) {
      if (page >= 1 && page <= 604) {
        // Trigger background loading of page data and font
        ref.read(qcfPageProvider(page).future).then((_) {}, onError: (_) {});
        ref.read(pageFontProvider(page).future).then((_) {}, onError: (_) {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.startPage;
    _pageController = PageController(initialPage: widget.startPage - 1);

    _loadSurahData();
    _preloadAdjacentPages(widget.startPage);

    // Save initial reading page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lastReadPageNotifierProvider.notifier)
          .updatePage(widget.startPage);

      // Subscribe to page completion events for continuous play
      _audioSubscription = ref
          .read(audioPlayerProvider.notifier)
          .pageCompletedStream
          .listen((_) async {
            if (!mounted) return;

            final playbackState = ref.read(audioPlayerProvider);
            if (playbackState.isSingleAyahPlay) {
              ref.read(audioPlayerProvider.notifier).stop();
              return;
            }

            // Advance to the next page if continuous page play is active
            if (_currentPage < 604) {
              final nextPage = _currentPage + 1;
              await _pageController.animateToPage(
                nextPage - 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );

              try {
                final pageData = await ref.read(
                  qcfPageProvider(nextPage).future,
                );
                if (pageData.verses.isNotEmpty) {
                  ref
                      .read(audioPlayerProvider.notifier)
                      .playPageAyahs(
                        ref.read(audioPlayerProvider).activeReciterId,
                        pageData.verses,
                      );
                }
              } catch (e) {
                debugPrint('Failed to load next page verses: $e');
              }
            } else {
              ref.read(audioPlayerProvider.notifier).stop();
            }
          });
    });
  }

  Future<void> _loadSurahData() async {
    final repo = ref.read(quranRepositoryProvider);
    final surahs = await repo.getAllSurahs();
    final startPages = await repo.getSurahStartPages();
    if (mounted) {
      setState(() {
        _surahs = surahs;
        _surahStartPages = startPages;
      });
    }
  }

  int _getJuzForPage(int pageNum) {
    int currentJuz = 1;
    for (final entry in _juzStartPages.entries) {
      if (entry.value <= pageNum) {
        currentJuz = entry.key;
      } else {
        break;
      }
    }
    return currentJuz;
  }

  Surah? _getSurahForPage(int pageNum) {
    if (_surahs.isEmpty || _surahStartPages.isEmpty) return null;

    Surah? currentSurah;
    for (final surah in _surahs) {
      final startPage = _surahStartPages[surah.number] ?? 1;
      if (startPage <= pageNum) {
        currentSurah = surah;
      } else {
        break;
      }
    }
    return currentSurah;
  }

  String _getSurahNameArabicFallback(int surahNumber) {
    if (surahNumber >= 1 && surahNumber <= 114) {
      return surahNamesWithTashkeel[surahNumber - 1];
    }
    return '';
  }

  CustomBookmark? _getBookmarkForPage(int pageNum) {
    final bookmarks = ref.read(customBookmarksNotifierProvider);
    final match = bookmarks.where((b) => b.page == pageNum);
    return match.isNotEmpty ? match.first : null;
  }

  void _handleBookmarkTap(int pageNum) {
    final theme = Theme.of(context);
    final bookmarks = ref.read(customBookmarksNotifierProvider);
    final pageBookmark = _getBookmarkForPage(pageNum);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            AppInsets.sheetBottom(context, gap: 24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ArabicText(
                pageBookmark != null
                    ? 'إدارة العلامة الحالية'
                    : 'خيارات حفظ العلامة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (pageBookmark != null) ...[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(
                      pageBookmark.colorValue,
                    ).withValues(alpha: 0.1),
                    child: Icon(
                      Icons.bookmark,
                      color: Color(pageBookmark.colorValue),
                    ),
                  ),
                  title: ArabicText(
                    pageBookmark.name,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  subtitle: ArabicText(
                    'صفحة ${pageBookmark.page}',
                    style: GoogleFonts.cairo(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteBookmark(pageBookmark.id);
                    },
                  ),
                ),
                const Divider(),
              ],

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showNewBookmarkDialog(pageNum);
                },
                icon: const Icon(Icons.bookmark_add),
                label: ArabicText(
                  'وضع علامة جديدة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (bookmarks.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showMoveBookmarkBottomSheet(pageNum);
                  },
                  icon: const Icon(Icons.drive_file_move_outlined),
                  label: ArabicText(
                    'نقل علامة قديمة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNewBookmarkDialog(int pageNum) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    int selectedColorValue = 0xFF8B001B;

    final List<int> availableColors = [
      0xFF8B001B,
      0xFFD4AF37,
      0xFF2E7D32,
      0xFFFF8F00,
      0xFF00796B,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: ArabicText(
                'علامة قراءة جديدة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'اسم العلامة',
                        labelStyle: GoogleFonts.cairo(fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ArabicText(
                      'اختر لون العلامة:',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: availableColors.map((colorVal) {
                        final isSelected = selectedColorValue == colorVal;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColorValue = colorVal;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: ArabicText(
                    'إلغاء',
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(context);
                      final newBookmark = CustomBookmark(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        colorValue: selectedColorValue,
                        page: pageNum,
                        createdAt: DateTime.now(),
                      );
                      ref
                          .read(customBookmarksNotifierProvider.notifier)
                          .addBookmark(newBookmark);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: ArabicText(
                    'حفظ',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMoveBookmarkBottomSheet(int pageNum) {
    final theme = Theme.of(context);
    final bookmarks = ref.read(customBookmarksNotifierProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, AppInsets.sheetBottom(context, gap: 16)),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ArabicText(
                'اختر العلامة لنقلها هنا',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              ArabicText(
                'سيتم نقل العلامة المحددة إلى صفحة $pageNum',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: bookmarks.isEmpty
                    ? Center(
                        child: ArabicText(
                          'لا توجد علامات حالياً',
                          style: GoogleFonts.cairo(),
                        ),
                      )
                    : ListView.builder(
                        itemCount: bookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = bookmarks[index];
                          return ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              _moveBookmarkToPage(bookmark.id, pageNum);
                            },
                            leading: CircleAvatar(
                              backgroundColor: Color(
                                bookmark.colorValue,
                              ).withValues(alpha: 0.1),
                              child: Icon(
                                Icons.bookmark,
                                color: Color(bookmark.colorValue),
                              ),
                            ),
                            title: ArabicText(
                              bookmark.name,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: ArabicText(
                              'كانت في صفحة ${bookmark.page}',
                              style: GoogleFonts.cairo(fontSize: 11),
                            ),
                            trailing: Icon(
                              Icons.drive_file_move_outlined,
                              color: theme.colorScheme.secondary,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteBookmark(String id) {
    ref.read(customBookmarksNotifierProvider.notifier).deleteBookmark(id);
  }

  void _moveBookmarkToPage(String id, int pageNum) {
    ref
        .read(customBookmarksNotifierProvider.notifier)
        .moveBookmark(id, pageNum);
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _pageController.dispose();
    ref.read(audioPlayerProvider.notifier).stop();
    super.dispose();
  }

  // Helper to map lines to verses
  Map<int, List<AyahPlacement>> _calculateLineToAyahsMap(QcfPage page) {
    final map = <int, List<AyahPlacement>>{};
    final textLines =
        page.lines
            .where((l) => l.surahNumber == null && !l.isBismillah)
            .toList()
          ..sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
    final verses = List<QcfVerse>.from(page.verses)
      ..sort((a, b) => a.id.compareTo(b.id));

    if (textLines.isNotEmpty && verses.isNotEmpty) {
      int currentVerseIdx = 0;
      int verseCharIdx = 0;
      String currentVerseCode = verses[0].codeV1.replaceAll(' ', '');

      for (final line in textLines) {
        final placements = <AyahPlacement>[];
        final originalText = line.text;
        int lineCharIdx = 0;
        int currentPlacementStart = 0;

        while (lineCharIdx < originalText.length &&
            currentVerseIdx < verses.length) {
          final char = originalText[lineCharIdx];
          if (char == ' ' || char == '\n' || char == '\r') {
            if (currentPlacementStart == lineCharIdx) {
              currentPlacementStart++;
            }
            lineCharIdx++;
            continue;
          }

          final currentVerse = verses[currentVerseIdx];
          verseCharIdx++;
          lineCharIdx++;

          if (verseCharIdx >= currentVerseCode.length) {
            placements.add(
              AyahPlacement(
                verse: currentVerse,
                startIndex: currentPlacementStart,
                endIndex: lineCharIdx,
              ),
            );
            currentVerseIdx++;
            if (currentVerseIdx < verses.length) {
              currentVerseCode = verses[currentVerseIdx].codeV1.replaceAll(
                ' ',
                '',
              );
              verseCharIdx = 0;
              currentPlacementStart = lineCharIdx;
            }
          }
        }

        if (currentPlacementStart < originalText.length &&
            currentVerseIdx < verses.length) {
          placements.add(
            AyahPlacement(
              verse: verses[currentVerseIdx],
              startIndex: currentPlacementStart,
              endIndex: originalText.length,
            ),
          );
        }

        map[line.lineNumber] = placements;
      }
    }
    return map;
  }

  void _showVerseQuickView(BuildContext context, QcfVerse verse) {
    setState(() {
      _selectedVerse = verse;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VerseQuickViewSheet(verse: verse);
      },
    ).then((_) {
      // Clear selection when sheet is closed
      if (mounted) {
        setState(() {
          _selectedVerse = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Select only properties that do not change rapidly (exclude position/duration updates)
    // to prevent continuous rebuilds during playback which cancel touch gestures.
    final selectedState = ref.watch(
      audioPlayerProvider.select(
        (s) => (
          isPlaying: s.isPlaying,
          isLoading: s.isLoading,
          activeReciterId: s.activeReciterId,
          isPageMode: s.isPageMode,
          currentAyahIndex: s.currentAyahIndex,
          pageVerses: s.pageVerses,
          currentSurah: s.currentSurah,
          isSingleAyahPlay: s.isSingleAyahPlay,
        ),
      ),
    );

    final playbackState = AudioPlaybackState(
      isPlaying: selectedState.isPlaying,
      isLoading: selectedState.isLoading,
      activeReciterId: selectedState.activeReciterId,
      isPageMode: selectedState.isPageMode,
      currentAyahIndex: selectedState.currentAyahIndex,
      pageVerses: selectedState.pageVerses,
      currentSurah: selectedState.currentSurah,
      isSingleAyahPlay: selectedState.isSingleAyahPlay,
      position: Duration.zero,
      duration: Duration.zero,
      playbackSpeed: 1.0,
    );
    ref.watch(customBookmarksNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Mushaf PageView
          GestureDetector(
            onTap: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
            child: PageView.builder(
              controller: _pageController,
              reverse: false, // Right-to-Left scrolling naturally in RTL mode
              itemCount: 604,
              onPageChanged: (index) {
                final pageNum = index + 1;
                setState(() {
                  _currentPage = pageNum;
                  _selectedVerse = null;
                });
                // Save reading progress
                ref
                    .read(lastReadPageNotifierProvider.notifier)
                    .updatePage(pageNum);
                // Preload adjacent pages
                _preloadAdjacentPages(pageNum);
              },
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                return _buildMushafPage(pageNum, theme, playbackState);
              },
            ),
          ),

          // Custom Premium Overlay Bar (Top AppBar)
          if (_showOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopOverlay(theme),
            ),

          // Custom Premium Overlay Control Bar (Bottom Player)
          if (_showOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPlayerOverlay(theme, playbackState),
            ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BackButton(),
            Expanded(
              child: ArabicText(
                'خيارات التلاوة والاستماع',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showHelpDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ArabicText(
          'طريقة القراءة والتفاعل',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: ArabicText(
          '• اسحب لليمين واليسار للتنقل بين الصفحات.\n'
          '• اضغط ضغطة واحدة في منتصف الصفحة لإظهار أو إخفاء أزرار التحكم.\n'
          '• اضغط على أي آية (كلمات الآية) لعرض تفسيرها، ترجمتها، حفظها، أو تلاوتها.\n'
          '• اضغط ضغطة مطولة على أي آية لتشغيل تلاوتها الصوتية مباشرةً.',
          style: GoogleFonts.cairo(height: 1.6),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ArabicText(
              'حسناً',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSurahSelectionBottomSheet(ThemeData theme) {
    final searchController = TextEditingController();
    final listController = ScrollController();
    String searchQuery = '';
    var didCenterCurrent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredSurahs = _surahs.where((surah) {
              final query = searchQuery.trim().toLowerCase();
              if (query.isEmpty) return true;
              final numberMatch = surah.number.toString() == query;
              final arabicMatch =
                  surah.nameArabic.contains(query) ||
                  surah.name.contains(query);
              final englishMatch = surah.nameEnglish.toLowerCase().contains(
                query,
              );
              return numberMatch || arabicMatch || englishMatch;
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: AppInsets.sheetBottom(context, gap: 8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ArabicText(
                      'اختر السورة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setSheetState(() {
                            searchQuery = value;
                          });
                        },
                        style: GoogleFonts.cairo(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن سورة...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.primary,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    searchController.clear();
                                    setSheetState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: filteredSurahs.isEmpty
                          ? Center(
                              child: ArabicText(
                                'لا توجد نتائج بحث مطابقة',
                                style: GoogleFonts.cairo(color: Colors.grey),
                              ),
                            )
                          : Builder(
                              builder: (context) {
                                if (searchQuery.isEmpty && !didCenterCurrent) {
                                  final current = _getSurahForPage(
                                    _currentPage,
                                  );
                                  final currentIndex = current == null
                                      ? -1
                                      : filteredSurahs.indexWhere(
                                          (s) => s.number == current.number,
                                        );
                                  if (currentIndex > 0) {
                                    didCenterCurrent = true;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (!listController.hasClients) {
                                            return;
                                          }
                                          const itemExtent = 72.0;
                                          final viewport = listController
                                              .position
                                              .viewportDimension;
                                          final offset =
                                              currentIndex * itemExtent -
                                              (viewport - itemExtent) / 2;
                                          final max = listController
                                              .position
                                              .maxScrollExtent;
                                          if (max <= 0) return;
                                          listController.jumpTo(
                                            offset.clamp(0.0, max),
                                          );
                                        });
                                  }
                                }
                                return ListView.builder(
                                  controller: listController,
                                  itemExtent: 72,
                                  itemCount: filteredSurahs.length,
                                  itemBuilder: (context, index) {
                                    final surah = filteredSurahs[index];
                                    final startPage =
                                        _surahStartPages[surah.number] ?? 1;
                                    final isCurrent =
                                        surah.number ==
                                        _getSurahForPage(_currentPage)?.number;

                                    return ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pageController.jumpToPage(
                                          startPage - 1,
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: isCurrent
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.primary
                                                  .withValues(alpha: 0.08),
                                        foregroundColor: isCurrent
                                            ? Colors.white
                                            : theme.colorScheme.primary,
                                        child: ArabicText(
                                          surah.number.toString(),
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: ArabicText(
                                        'سورة ${surah.nameArabic}',
                                        style: GoogleFonts.amiri(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent
                                              ? theme.colorScheme.secondary
                                              : theme.colorScheme.primary,
                                        ),
                                      ),
                                      subtitle: ArabicText(
                                        'صفحة $startPage • ${surah.numberOfAyahs} آية',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: theme.colorScheme.secondary
                                            .withValues(alpha: 0.6),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      searchController.dispose();
      listController.dispose();
    });
  }

  void _showJuzSelectionBottomSheet(ThemeData theme) {
    final gridController = ScrollController();
    var didCenterCurrent = false;
    final currentJuz = _getJuzForPage(_currentPage);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ArabicText(
                'اختر الجزء',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (!didCenterCurrent && currentJuz > 1) {
                      didCenterCurrent = true;
                      const horizontalPadding = 32.0;
                      const crossSpacing = 24.0;
                      const mainSpacing = 12.0;
                      const topPadding = 16.0;
                      final itemWidth =
                          (constraints.maxWidth -
                              horizontalPadding -
                              crossSpacing) /
                          3;
                      final itemHeight = itemWidth / 1.8;
                      final row = (currentJuz - 1) ~/ 3;
                      final itemTop =
                          topPadding + row * (itemHeight + mainSpacing);
                      final offset =
                          itemTop - (constraints.maxHeight - itemHeight) / 2;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!gridController.hasClients) return;
                        final max = gridController.position.maxScrollExtent;
                        if (max <= 0) return;
                        gridController.jumpTo(offset.clamp(0.0, max));
                      });
                    }
                    return GridView.builder(
                      controller: gridController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.8,
                          ),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final juzNum = index + 1;
                        final startPage = _juzStartPages[juzNum] ?? 1;
                        final isCurrent =
                            juzNum == _getJuzForPage(_currentPage);

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _pageController.jumpToPage(startPage - 1);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ArabicText(
                                  'الجزء $juzNum',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                                ArabicText(
                                  'صفحة $startPage',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    color: isCurrent
                                        ? Colors.white70
                                        : theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(gridController.dispose);
  }

  void _showPageSelectionBottomSheet(ThemeData theme) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: AppInsets.sheetBottom(context, gap: 8),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ArabicText(
                  'انتقال إلى صفحة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'أدخل رقم الصفحة (1 - 604)',
                          hintStyle: GoogleFonts.cairo(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (val) {
                          final page = int.tryParse(val);
                          if (page != null && page >= 1 && page <= 604) {
                            Navigator.pop(context);
                            _pageController.jumpToPage(page - 1);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final page = int.tryParse(textController.text);
                        if (page != null && page >= 1 && page <= 604) {
                          Navigator.pop(context);
                          _pageController.jumpToPage(page - 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: ArabicText(
                        'اذهب',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [50, 100, 200, 300, 400, 500, 600].map((
                      quickPage,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ActionChip(
                          label: ArabicText(
                            'صفحة $quickPage',
                            style: GoogleFonts.cairo(fontSize: 11),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _pageController.jumpToPage(quickPage - 1);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomPlayerOverlay(
    ThemeData theme,
    AudioPlaybackState playbackState,
  ) {
    final isPlaying = playbackState.isPlaying;
    final isLoading = playbackState.isLoading;
    final recentReciters = ref.watch(recentRecitersProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reciter Selection & Audio Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Modern Reciter Selector Button
                Flexible(
                  child: GestureDetector(
                    onTap: () => _showReciterSelectionBottomSheet(
                      theme,
                      playbackState.activeReciterId,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: ArabicText(
                              (() {
                                try {
                                  return recentReciters
                                      .firstWhere(
                                        (r) =>
                                            r.id ==
                                            playbackState.activeReciterId,
                                      )
                                      .nameArabic;
                                } catch (_) {
                                  return (staticReciters.firstWhere(
                                    (r) =>
                                        r.id == playbackState.activeReciterId,
                                    orElse: () => staticReciters.first,
                                  )).nameArabic;
                                }
                              })(),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Audio Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_next_outlined),
                      onPressed: () =>
                          ref.read(audioPlayerProvider.notifier).next(),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        if (isPlaying) {
                          ref.read(audioPlayerProvider.notifier).pause();
                        } else {
                          final pageDataAsync = ref.read(
                            qcfPageProvider(_currentPage),
                          );
                          final pageData = pageDataAsync.value;
                          if (pageData != null && pageData.verses.isNotEmpty) {
                            // If there is a manually selected/highlighted verse on the current page, play starting from it
                            if (_selectedVerse != null &&
                                _selectedVerse!.page == _currentPage) {
                              final index = pageData.verses.indexWhere(
                                (v) =>
                                    v.surahNumber ==
                                        _selectedVerse!.surahNumber &&
                                    v.ayahNumber == _selectedVerse!.ayahNumber,
                              );
                              ref
                                  .read(audioPlayerProvider.notifier)
                                  .playPageAyahs(
                                    playbackState.activeReciterId,
                                    pageData.verses,
                                    initialIndex: index >= 0 ? index : 0,
                                  );
                            }
                            // If there is a paused session for the current page, resume it
                            else if (playbackState.pageVerses.isNotEmpty &&
                                playbackState.pageVerses.first.page ==
                                    _currentPage) {
                              ref.read(audioPlayerProvider.notifier).resume();
                            }
                            // Otherwise, play starting from the first verse on the page
                            else {
                              ref
                                  .read(audioPlayerProvider.notifier)
                                  .playPageAyahs(
                                    playbackState.activeReciterId,
                                    pageData.verses,
                                    initialIndex: 0,
                                  );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_outlined),
                      onPressed: () =>
                          ref.read(audioPlayerProvider.notifier).previous(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterSelectionBottomSheet(
    ThemeData theme,
    String activeReciterId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ReciterSelectionSheet(activeReciterId: activeReciterId);
      },
    );
  }

  Widget _buildMushafPage(
    int pageNum,
    ThemeData theme,
    AudioPlaybackState playbackState,
  ) {
    final pageAsync = ref.watch(qcfPageProvider(pageNum));
    final fontAsync = ref.watch(pageFontProvider(pageNum));
    final currentSurah = _getSurahForPage(pageNum);
    final currentJuz = _getJuzForPage(pageNum);
    final pageBookmark = _getBookmarkForPage(pageNum);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // مسافة النظام السفلية (أزرار/شريط التنقّل الجوه الشاشة) عشان كل العناصر
    // السفلية تفضل فوقها على أي جهاز
    final pageNavInset = AppInsets.navBar(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: pageAsync.when(
        data: (page) {
          return fontAsync.when(
            data: (fontFamily) {
              final lineToAyahMap = _calculateLineToAyahsMap(page);

              final playingVerse =
                  (playbackState.isPageMode &&
                      playbackState.currentAyahIndex >= 0)
                  ? playbackState.pageVerses.elementAtOrNull(
                      playbackState.currentAyahIndex,
                    )
                  : null;

              return Stack(
                children: [
                  // 1. اسم السورة (أعلى اليمين - تحت شريط الحالة)
                  Positioned(
                    top: statusBarHeight + 8.0,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _showSurahSelectionBottomSheet(theme),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5), // لون الخلفية العاجي
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ArabicText(
                          currentSurah != null
                              ? currentSurah.nameArabic
                              : '...',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary, // عنابي
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. الجزء الحالي (أعلى اليسار - تحت شريط الحالة)
                  Positioned(
                    top: statusBarHeight + 8.0,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => _showJuzSelectionBottomSheet(theme),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5), // لون الخلفية العاجي
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ArabicText(
                          'الجزء $currentJuz',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary, // عنابي
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. علامة الحفظ والأسهم التنقلية (أعلى المنتصف - تحت شريط الحالة)
                  Positioned(
                    top: statusBarHeight + 2.0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // السهم الأيسر (باصص شمال) - للذهاب للصفحة التالية
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: pageNum % 2 == 0
                                    ? theme
                                          .colorScheme
                                          .primary // نشط (برجاندي غامق)
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.25,
                                      ), // غير نشط (برجاندي خفيف)
                                size: 18,
                              ),
                              onPressed: () {
                                if (pageNum < 604) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),

                            // علامة الحفظ (المنتصف)
                            IconButton(
                              icon: Icon(
                                pageBookmark != null
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: pageBookmark != null
                                    ? Color(pageBookmark.colorValue)
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                size: 26,
                              ),
                              onPressed: () => _handleBookmarkTap(pageNum),
                            ),

                            // السهم الأيمن (باصص يمين) - للذهاب للصفحة السابقة
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: pageNum % 2 != 0
                                    ? theme
                                          .colorScheme
                                          .primary // نشط (برجاندي غامق)
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.25,
                                      ), // غير نشط (برجاندي خفيف)
                                size: 18,
                              ),
                              onPressed: () {
                                if (pageNum > 1) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. رقم الصفحة (أسفل المنتصف - مرتفع قليلاً)
                  // مبدأ النظام: نرفعه فوق شريط التنقّل/الأزرار الجوه الشاشة
                  Positioned(
                    bottom: pageNavInset + 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _showPageSelectionBottomSheet(theme),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFAF8F5,
                            ), // لون الخلفية العاجي
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ArabicText(
                            pageNum.toString(),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary, // عنابي
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. الآيات والمحتوى الفعلي
                  Padding(
                    padding: EdgeInsets.only(
                      top:
                          statusBarHeight +
                          50.0, // تباعد مناسب أسفل أزرار الرأس
                      bottom:
                          56.0 +
                          pageNavInset, // تباعد فوق رقم الصفحة السفلي + شريط النظام
                      left: 12.0,
                      right: 12.0,
                    ),
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isFirstTwoPages = pageNum == 1 || pageNum == 2;
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;
                          final lineHeight = isFirstTwoPages ? 1.2 : 1.6;

                          // ═══ مقاس الخط متوازن بين العرض والارتفاع ═══
                          // قبل كده كان بيتحسب من العرض بس — ففي التابلت وفي
                          // أي شاشة نسبتها أصغر، عمود السطور كان بيطلع أطول
                          // من المساحة المتاحة فآخر سطر بيتقص برّه الشاشة.
                          // دلوقتي بنحسب مقسمين:
                          // (أ) الحد الأقصى حسب العرض — زي زمان.
                          // (ب) الحد الأوسط حسب الارتفاع: نخصم ارتفاعات
                          //     عناصر ثابتة معروفة (البسملة/فريم السورة +
                          //     التباعد) ونقسم الباقي على عدد سطور النص.
                          final fontSizeByWidth = maxW / 14.8;

                          int textLineCount = 0;
                          int bismillahCount = 0;
                          int headerCount = 0;
                          for (final line in page.lines) {
                            if (line.isBismillah) {
                              bismillahCount++;
                            } else if (line.surahNumber != null &&
                                line.surahNumber! > 0) {
                              headerCount++;
                            } else {
                              textLineCount++;
                            }
                          }

                          // ارتفاعات محجوزة للعناصر الخاصة (حسب مقاساتها
                          // الحقيقية: الصورة/الفريم بأبعادها داخل Padding)
                          final bismillahHeight =
                              (maxW * 0.62) / (1458 / 273) + 2.0;
                          final surahFrameHeight =
                              maxW / (678 / 79) + 4.0;
                          double reserved = 0.0;
                          reserved += bismillahCount * bismillahHeight;
                          reserved += headerCount * surahFrameHeight;

                          // التباعد الزائد بين العناصر (صفحات الفاتحة/البقرة)
                          final childCount = page.lines.length;
                          final spacingTotal =
                              isFirstTwoPages && childCount > 1
                                  ? 4.0 * (childCount - 1)
                                  : 0.0;

                          // هامش أمان صغير (1.5% + 2px) يغطي أي فرق قياس
                          // جزئي، والسطر يفضل دايمًا جوه المساحة المتاحة
                          final availableForText =
                              (maxH - reserved - spacingTotal) * 0.985 - 2.0;
                          final fontSizeByHeight =
                              textLineCount > 0
                                  ? availableForText /
                                      (textLineCount * lineHeight)
                                  : fontSizeByWidth;
                          final fontSize = math.max(
                            4.0,
                            math.min(fontSizeByWidth, fontSizeByHeight),
                          );

                          return Column(
                            mainAxisAlignment: isFirstTwoPages
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceEvenly,
                            spacing: isFirstTwoPages ? 4.0 : 0.0,
                            children: page.lines.map((line) {
                              if (line.isBismillah) {
                                // البسملة الزخرفية في بداية السور (صورة PNG شفافة، نبيتي محروق داخلها)
                                // معزولة من الخلفية ومقصوصة لحدود الرسم نفسه (1458×273 أساس 3×)
                                // بترسم بـ 62% من عرض المحتوى عشان ما تبقاش كبيرة
                                // ملاحظة: سورة التوبة (٩) مش بتبدأ ببسملة، وده متظبط أصلًا في
                                // [surah_headers.json] — مفيهاش مدخلة isBismillah ليها فمش هتتنعرض خالص
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 1.0,
                                    ),
                                    child: Image.asset(
                                      'assets/images/basmala_new.png',
                                      width: constraints.maxWidth * 0.62,
                                      height:
                                          (constraints.maxWidth * 0.62) /
                                          (1458 / 273),
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                );
                              } else if (line.surahNumber != null &&
                                  line.surahNumber! > 0) {
                                final name = _getSurahNameArabicFallback(
                                  line.surahNumber!,
                                );
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                    ),
                                    child: SurahNameFrame(
                                      surahName: name,
                                      surahNumber: line.surahNumber!,
                                      width: constraints.maxWidth,
                                    ),
                                  ),
                                );
                              } else {
                                final placements =
                                    lineToAyahMap[line.lineNumber] ?? [];

                                return VerseLineWidget(
                                  text: line.text,
                                  placements: placements,
                                  playingVerse: playingVerse,
                                  selectedVerse: _selectedVerse,
                                  fontFamily: fontFamily,
                                  fontSize: fontSize,
                                  lineHeight: lineHeight,
                                  onVerseLongPress: (verse) =>
                                      _showVerseQuickView(context, verse),
                                  onVerseTap: (verse) {
                                    setState(() {
                                      _selectedVerse = null;
                                    });
                                  },
                                );
                              }
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: ArabicText('خطأ في تحميل الخط: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: ArabicText('خطأ في تحميل الصفحة: $err')),
      ),
    );
  }
}

// Stateful Widget for each Mushaf line to isolate gesture recognizers and prevent memory leaks
class VerseLineWidget extends StatefulWidget {
  final String text;
  final List<AyahPlacement> placements;
  final QcfVerse? playingVerse;
  final QcfVerse? selectedVerse;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final ValueChanged<QcfVerse> onVerseLongPress;
  final ValueChanged<QcfVerse> onVerseTap;

  const VerseLineWidget({
    super.key,
    required this.text,
    required this.placements,
    required this.playingVerse,
    required this.selectedVerse,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.onVerseLongPress,
    required this.onVerseTap,
  });

  @override
  State<VerseLineWidget> createState() => _VerseLineWidgetState();
}

class _VerseLineWidgetState extends State<VerseLineWidget> {
  final List<GestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _initRecognizers();
  }

  @override
  void didUpdateWidget(covariant VerseLineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placements != widget.placements ||
        oldWidget.onVerseLongPress != widget.onVerseLongPress ||
        oldWidget.onVerseTap != widget.onVerseTap) {
      _initRecognizers();
    }
  }

  void _initRecognizers() {
    _clearRecognizers();
    for (final placement in widget.placements) {
      final longPressRecognizer = LongPressGestureRecognizer()
        ..onLongPress = () => widget.onVerseLongPress(placement.verse);
      _recognizers.add(longPressRecognizer);

      final tapRecognizer = TapGestureRecognizer()
        ..onTap = () {
          final isSelected =
              widget.selectedVerse?.surahNumber ==
                  placement.verse.surahNumber &&
              widget.selectedVerse?.ayahNumber == placement.verse.ayahNumber;
          if (isSelected) {
            widget.onVerseTap(placement.verse);
          }
        };
      _recognizers.add(tapRecognizer);
    }
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];

    int currIndex = 0;
    for (int i = 0; i < widget.placements.length; i++) {
      final placement = widget.placements[i];
      if (placement.startIndex > currIndex) {
        spans.add(
          TextSpan(
            text: widget.text.substring(currIndex, placement.startIndex),
          ),
        );
      }

      final isPlaying =
          widget.playingVerse?.surahNumber == placement.verse.surahNumber &&
          widget.playingVerse?.ayahNumber == placement.verse.ayahNumber;
      final isSelected =
          widget.selectedVerse?.surahNumber == placement.verse.surahNumber &&
          widget.selectedVerse?.ayahNumber == placement.verse.ayahNumber;

      final longPressRecognizer = (2 * i) < _recognizers.length
          ? _recognizers[2 * i]
          : null;
      final tapRecognizer = (2 * i + 1) < _recognizers.length
          ? _recognizers[2 * i + 1]
          : null;

      TextStyle? style;
      if (isPlaying) {
        style = TextStyle(
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.35),
          fontWeight: FontWeight.bold,
        );
      } else if (isSelected) {
        style = TextStyle(
          color: theme.colorScheme.secondary,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          fontWeight: FontWeight.bold,
        );
      }

      spans.add(
        TextSpan(
          text: widget.text.substring(placement.startIndex, placement.endIndex),
          recognizer: isSelected ? tapRecognizer : longPressRecognizer,
          style: style,
        ),
      );

      currIndex = placement.endIndex;
    }

    if (currIndex < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(currIndex)));
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: RichText(
        softWrap: false,
        textAlign: TextAlign.center,
        // إيقاف تكبير النص حسب إعدادات النظام: خط المصحف الخطوفي لازم يفضل
        // بمقاس ثابت محسوب بدقة عشان السطور تطلع جوه الصفحة على أي جهاز
        textScaler: TextScaler.noScaling,
        text: TextSpan(
          style: TextStyle(
            fontFamily: widget.fontFamily,
            fontSize: widget.fontSize,
            height: widget.lineHeight,
            color: const Color(0xFF3B1E1E), // Deep Brown Text
          ),
          children: spans,
        ),
      ),
    );
  }
}

class _VerseQuickViewSheet extends ConsumerWidget {
  final QcfVerse verse;
  const _VerseQuickViewSheet({required this.verse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Dynamic Providers
    final isFavAsync = ref.watch(
      isVerseFavoriteProvider((
        surah: verse.surahNumber,
        ayah: verse.ayahNumber,
      )),
    );
    final arabicTextAsync = ref.watch(
      verseArabicTextProvider((
        surah: verse.surahNumber,
        ayah: verse.ayahNumber,
      )),
    );
    final jalalaynAsync = ref.watch(
      verseTafsirProvider((
        surah: verse.surahNumber,
        ayah: verse.ayahNumber,
        tafsirId: 'ar.jalalayn',
      )),
    );
    final muyassarAsync = ref.watch(
      verseTafsirProvider((
        surah: verse.surahNumber,
        ayah: verse.ayahNumber,
        tafsirId: 'ar.muyassar',
      )),
    );
    final translationAsync = ref.watch(
      verseTafsirProvider((
        surah: verse.surahNumber,
        ayah: verse.ayahNumber,
        tafsirId: 'en.asad',
      )),
    );
    final pageAsync = ref.watch(qcfPageProvider(verse.page));

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        AppInsets.sheetBottom(context, gap: 24),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isFavAsync.when(
                data: (isFav) => IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark : Icons.bookmark_border,
                    color: isFav ? theme.colorScheme.secondary : Colors.grey,
                  ),
                  onPressed: () async {
                    final repo = ref.read(quranRepositoryProvider);
                    await repo.toggleVerseFavorite(
                      verse.surahNumber,
                      verse.ayahNumber,
                    );
                    ref.invalidate(
                      isVerseFavoriteProvider((
                        surah: verse.surahNumber,
                        ayah: verse.ayahNumber,
                      )),
                    );
                  },
                ),
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stack) => const SizedBox(),
              ),
              FutureBuilder<Surah?>(
                future: ref
                    .read(quranRepositoryProvider)
                    .getSurahByNumber(verse.surahNumber),
                builder: (context, snapshot) {
                  final surahName = snapshot.data?.nameArabic ?? '';
                  return ArabicText(
                    'سورة $surahName - آية ${verse.ayahNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final arabicText = arabicTextAsync.value ?? '';
                  final shareText =
                      'قال تعالى:\n'
                      '« $arabicText »\n\n'
                      '[سورة ${verse.surahNumber}، الآية ${verse.ayahNumber}]\n'
                      'رابط التلاوة: https://everyayah.com/data/Alafasy_128kbps/'
                      '${verse.surahNumber.toString().padLeft(3, "0")}${verse.ayahNumber.toString().padLeft(3, "0")}.mp3\n\n'
                      'تمت المشاركة من تطبيق إيمان';

                  SharePlus.instance.share(ShareParams(text: shareText));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic Plain Text display
                  arabicTextAsync.when(
                    data: (text) {
                      if (text.isEmpty) return const SizedBox();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.03,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: ArabicText(
                          text,
                          style: GoogleFonts.amiri(
                            fontSize: 20,
                            height: 1.6,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3B1E1E), // Deep Brown Text
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    loading: () => _buildArabicTextSkeleton(context),
                    error: (err, stack) => const SizedBox(),
                  ),

                  // Quick Recitation Action
                  ElevatedButton.icon(
                    onPressed: () {
                      final pageData = pageAsync.value;
                      if (pageData != null && pageData.verses.isNotEmpty) {
                        final index = pageData.verses.indexWhere(
                          (v) =>
                              v.surahNumber == verse.surahNumber &&
                              v.ayahNumber == verse.ayahNumber,
                        );
                        ref
                            .read(audioPlayerProvider.notifier)
                            .playPageAyahs(
                              ref.read(audioPlayerProvider).activeReciterId,
                              pageData.verses,
                              initialIndex: index >= 0 ? index : 0,
                            );
                      } else {
                        ref
                            .read(audioPlayerProvider.notifier)
                            .playSingleAyah(
                              ref.read(audioPlayerProvider).activeReciterId,
                              verse,
                            );
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.volume_up),
                    label: ArabicText(
                      'تلاوة الآية الكريمة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tafsir sections
                  ArabicText(
                    'التفسير الميسر',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  muyassarAsync.when(
                    data: (text) => ArabicText(
                      text,
                      style: GoogleFonts.cairo(fontSize: 14, height: 1.6),
                      textAlign: TextAlign.right,
                    ),
                    loading: () =>
                        _buildSkeletonParagraph(context, isRtl: true),
                    error: (err, _) => ArabicText('خطأ في التحميل: $err'),
                  ),
                  const SizedBox(height: 16),

                  ArabicText(
                    'تفسير الجلالين',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  jalalaynAsync.when(
                    data: (text) => ArabicText(
                      text,
                      style: GoogleFonts.cairo(fontSize: 14, height: 1.6),
                      textAlign: TextAlign.right,
                    ),
                    loading: () =>
                        _buildSkeletonParagraph(context, isRtl: true),
                    error: (err, _) => ArabicText('خطأ في التحميل: $err'),
                  ),
                  const SizedBox(height: 16),

                  ArabicText(
                    'English Translation (Asad)',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  translationAsync.when(
                    data: (text) => ArabicText(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.5,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    loading: () =>
                        _buildSkeletonParagraph(context, isRtl: false),
                    error: (err, _) =>
                        ArabicText('Error loading translation: $err'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArabicTextSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary.withValues(alpha: 0.05);
    final highlightColor = theme.colorScheme.primary.withValues(alpha: 0.15);
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          _buildSkeletonLine(
            widthPct: 0.8,
            height: 20,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 12),
          _buildSkeletonLine(
            widthPct: 0.5,
            height: 20,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonParagraph(BuildContext context, {required bool isRtl}) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary.withValues(alpha: 0.05);
    final highlightColor = theme.colorScheme.primary.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: isRtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildSkeletonLine(
          widthPct: 0.95,
          height: 12,
          baseColor: baseColor,
          highlightColor: highlightColor,
          isRtl: isRtl,
        ),
        const SizedBox(height: 8),
        _buildSkeletonLine(
          widthPct: 0.85,
          height: 12,
          baseColor: baseColor,
          highlightColor: highlightColor,
          isRtl: isRtl,
        ),
        const SizedBox(height: 8),
        _buildSkeletonLine(
          widthPct: 0.60,
          height: 12,
          baseColor: baseColor,
          highlightColor: highlightColor,
          isRtl: isRtl,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSkeletonLine({
    required double widthPct,
    required double height,
    required Color baseColor,
    required Color highlightColor,
    bool isRtl = true,
  }) {
    return Align(
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: widthPct,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: highlightColor);
  }
}

class _ReciterSelectionSheet extends ConsumerStatefulWidget {
  final String activeReciterId;
  const _ReciterSelectionSheet({required this.activeReciterId});

  @override
  ConsumerState<_ReciterSelectionSheet> createState() =>
      _ReciterSelectionSheetState();
}

class _ReciterSelectionSheetState
    extends ConsumerState<_ReciterSelectionSheet> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentReciters = ref.watch(recentRecitersProvider);

    List<Widget> listItems = [];

    if (_searchQuery.isEmpty) {
      // Show recent 6 reciters if available
      if (recentReciters.isNotEmpty) {
        listItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'القراء الأخيرون',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        );

        listItems.addAll(
          recentReciters.map((reciter) {
            final isCurrent = reciter.id == widget.activeReciterId;
            return ListTile(
              onTap: () {
                Navigator.pop(context);
                ref.read(recentRecitersProvider.notifier).addReciter(reciter);
                ref
                    .read(audioPlayerProvider.notifier)
                    .changeReciter(reciter.id);
              },
              leading: CircleAvatar(
                backgroundColor: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.08),
                foregroundColor: isCurrent
                    ? Colors.white
                    : theme.colorScheme.primary,
                child: const Icon(Icons.mic, size: 20),
              ),
              title: ArabicText(
                reciter.nameArabic,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: isCurrent
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
              ),
              trailing: isCurrent
                  ? Icon(Icons.check_circle, color: theme.colorScheme.secondary)
                  : null,
            );
          }),
        );

        listItems.add(const Divider());
      }

      // Show all EveryAyah reciters
      listItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'جميع القراء المتاحين (آية بآية)',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      );

      listItems.addAll(
        allEveryAyahReciters.map((reciter) {
          final isCurrent = reciter.id == widget.activeReciterId;
          return ListTile(
            onTap: () {
              Navigator.pop(context);
              ref.read(recentRecitersProvider.notifier).addReciter(reciter);
              ref.read(audioPlayerProvider.notifier).changeReciter(reciter.id);
            },
            leading: CircleAvatar(
              backgroundColor: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.08),
              foregroundColor: isCurrent
                  ? Colors.white
                  : theme.colorScheme.primary,
              child: const Icon(Icons.person, size: 20),
            ),
            title: ArabicText(
              reciter.nameArabic,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isCurrent
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
            ),
            trailing: isCurrent
                ? Icon(Icons.check_circle, color: theme.colorScheme.secondary)
                : null,
          );
        }),
      );
    } else {
      // Filter from allEveryAyahReciters
      final filteredReciters = allEveryAyahReciters
          .where(
            (r) =>
                r.nameArabic.contains(_searchQuery) ||
                r.nameEnglish.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();

      if (filteredReciters.isEmpty) {
        listItems.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'لا يوجد نتائج بحث مطابقة',
                style: GoogleFonts.cairo(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      } else {
        listItems.addAll(
          filteredReciters.map((reciter) {
            final isCurrent = reciter.id == widget.activeReciterId;
            return ListTile(
              onTap: () {
                Navigator.pop(context);
                ref.read(recentRecitersProvider.notifier).addReciter(reciter);
                ref
                    .read(audioPlayerProvider.notifier)
                    .changeReciter(reciter.id);
              },
              leading: CircleAvatar(
                backgroundColor: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.08),
                foregroundColor: isCurrent
                    ? Colors.white
                    : theme.colorScheme.primary,
                child: const Icon(Icons.search, size: 20),
              ),
              title: ArabicText(
                reciter.nameArabic,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: isCurrent
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
              ),
              trailing: isCurrent
                  ? Icon(Icons.check_circle, color: theme.colorScheme.secondary)
                  : null,
            );
          }),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        AppInsets.sheetBottom(context, gap: 8),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ArabicText(
            'اختر القارئ',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Search Text Field Styled Premiumly
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                color: theme.colorScheme.primary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  size: 20,
                ),
                hintText: 'ابحث عن قارئ...',
                hintStyle: GoogleFonts.cairo(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          Expanded(child: ListView(children: listItems)),
        ],
      ),
    );
  }
}
