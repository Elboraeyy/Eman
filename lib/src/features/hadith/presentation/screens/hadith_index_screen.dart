import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/hadith_repository_provider.dart';
import '../../domain/entities/hadith_entities.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

// Providers for loading books and categories are imported from hadith_repository_provider.dart

// Riverpod states for filtering using modern Notifier classes
// SelectedBookId is no longer needed since books are viewed in separate screens

class SelectedCategoryIdNotifier extends Notifier<int?> {
  @override
  int? build() => 1; // Default to first category
  
  void setCategoryId(int? id) => state = id;
}

final selectedCategoryIdProvider = NotifierProvider<SelectedCategoryIdNotifier, int?>(SelectedCategoryIdNotifier.new);

enum HadithSearchFilter {
  all,
  text,
  narrator,
  explanation,
}

class HadithSearchFilterNotifier extends Notifier<HadithSearchFilter> {
  @override
  HadithSearchFilter build() => HadithSearchFilter.all;

  void setFilter(HadithSearchFilter filter) => state = filter;
}

final hadithSearchFilterProvider = NotifierProvider<HadithSearchFilterNotifier, HadithSearchFilter>(HadithSearchFilterNotifier.new);

class HadithSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void setQuery(String query) => state = query;
}

final hadithSearchQueryProvider = NotifierProvider<HadithSearchQueryNotifier, String>(HadithSearchQueryNotifier.new);

// Dynamically filtered hadiths provider
final filteredHadithsProvider = FutureProvider<List<Hadith>>((ref) async {
  final repo = ref.watch(hadithRepositoryProvider);
  final query = ref.watch(hadithSearchQueryProvider);
  final catId = ref.watch(selectedCategoryIdProvider);
  final filter = ref.watch(hadithSearchFilterProvider);

  if (query.isNotEmpty) {
    final results = await repo.searchHadiths(query);
    switch (filter) {
      case HadithSearchFilter.all:
        return results;
      case HadithSearchFilter.text:
        return results.where((h) => h.text.toLowerCase().contains(query.toLowerCase())).toList();
      case HadithSearchFilter.narrator:
        return results.where((h) => h.narrator.toLowerCase().contains(query.toLowerCase())).toList();
      case HadithSearchFilter.explanation:
        return results.where((h) => h.explanation.toLowerCase().contains(query.toLowerCase())).toList();
    }
  } else if (catId != null) {
    return await repo.getHadithsByCategory(catId);
  } else {
    return await repo.getHadithsByCategory(1);
  }
});

class HadithIndexScreen extends ConsumerStatefulWidget {
  const HadithIndexScreen({super.key});

  @override
  ConsumerState<HadithIndexScreen> createState() => _HadithIndexScreenState();
}

class _HadithIndexScreenState extends ConsumerState<HadithIndexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PopupMenuItem<HadithSearchFilter> _buildPopupMenuItem({
    required BuildContext context,
    required HadithSearchFilter value,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem<HadithSearchFilter>(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          ArabicText(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, HadithBook book, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: InkWell(
        onTap: () {
          context.push('/hadith/book/${book.id}');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          height: 120,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.bookOpen,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(height: 8),
              ArabicText(
                book.title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              ArabicText(
                book.author,
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  color: theme.disabledColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booksAsync = ref.watch(hadithBooksProvider);
    final categoriesAsync = ref.watch(hadithCategoriesProvider);
    final hadithsAsync = ref.watch(filteredHadithsProvider);

    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final selectedFilter = ref.watch(hadithSearchFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ابحث بالكلمة، الراوي، الكتاب...',
                  hintStyle: GoogleFonts.cairo(color: theme.disabledColor),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  ref.read(hadithSearchQueryProvider.notifier).setQuery(val);
                  if (val.isNotEmpty) {
                    ref.read(selectedCategoryIdProvider.notifier).setCategoryId(null);
                  }
                },
              )
            : ArabicText(
                'الأحاديث النبوية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: _isSearching
            ? BackButton(
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    ref.read(hadithSearchQueryProvider.notifier).setQuery('');
                    ref.read(hadithSearchFilterProvider.notifier).setFilter(HadithSearchFilter.all);
                  });
                },
              )
            : null,
        actions: _isSearching
            ? [
                PopupMenuButton<HadithSearchFilter>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Icon(
                    selectedFilter == HadithSearchFilter.all
                        ? LucideIcons.filter
                        : Icons.filter_alt_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onSelected: (filter) {
                    ref.read(hadithSearchFilterProvider.notifier).setFilter(filter);
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.all,
                      title: 'البحث في الكل',
                      icon: Icons.all_inclusive_rounded,
                      isSelected: selectedFilter == HadithSearchFilter.all,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.text,
                      title: 'متن الحديث فقط',
                      icon: LucideIcons.quote,
                      isSelected: selectedFilter == HadithSearchFilter.text,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.narrator,
                      title: 'الراوي فقط',
                      icon: LucideIcons.user,
                      isSelected: selectedFilter == HadithSearchFilter.narrator,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.explanation,
                      title: 'الشرح والتفسير',
                      icon: LucideIcons.bookOpen,
                      isSelected: selectedFilter == HadithSearchFilter.explanation,
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(hadithSearchQueryProvider.notifier).setQuery('');
                    },
                  ),
              ]
            : [
                IconButton(
                  icon: const Icon(LucideIcons.search, size: 20),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
      ),
      body: _isSearching
          ? _buildSearchResults(hadithsAsync, theme)
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                booksAsync.when(
                  data: (books) {
                    if (books.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ArabicText(
                                'كتب الأحاديث',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push('/hadith/books');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ArabicText(
                                      'المزيد',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      LucideIcons.chevronLeft,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              if (books.isNotEmpty)
                                Expanded(child: _buildBookCard(context, books[0], theme)),
                              if (books.length > 1) ...[
                                const SizedBox(width: 20),
                                Expanded(child: _buildBookCard(context, books[1], theme)),
                              ],
                              if (books.length > 2) ...[
                                const SizedBox(width: 20),
                                Expanded(child: _buildBookCard(context, books[2], theme)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                  error: (err, stack) => const SizedBox.shrink(),
                ),

                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: ArabicText(
                            'التصنيفات',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: categories.length,
                            itemBuilder: (context, idx) {
                              final cat = categories[idx];
                              final isSelected = selectedCategoryId == cat.id;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: InkWell(
                                  onTap: () {
                                    final notifier = ref.read(selectedCategoryIdProvider.notifier);
                                    if (selectedCategoryId == cat.id) {
                                      notifier.setCategoryId(null);
                                    } else {
                                      notifier.setCategoryId(cat.id);
                                      ref.read(hadithSearchQueryProvider.notifier).setQuery('');
                                    }
                                  },
                                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  highlightColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  splashFactory: InkRipple.splashFactory,
                                  borderRadius: BorderRadius.circular(30),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                    constraints: const BoxConstraints(minWidth: 80),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? theme.colorScheme.primary 
                                          : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected 
                                            ? theme.colorScheme.primary 
                                            : theme.dividerColor,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: ArabicText(
                                      cat.title,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                  error: (err, stack) => const SizedBox.shrink(),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ArabicText(
                        'الأحاديث النبوية',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                hadithsAsync.when(
                  data: (hadiths) {
                    if (hadiths.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: ArabicText(
                            'لا توجد أحاديث مطابقة للتصفية الحالية.',
                            style: GoogleFonts.cairo(color: theme.disabledColor),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: hadiths.length,
                      itemBuilder: (context, idx) {
                        final hadith = hadiths[idx];
                        return _buildHadithListItem(hadith, theme, idx);
                      },
                    );
                  },
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator())),
                  error: (err, _) => Center(child: Padding(padding: const EdgeInsets.all(40.0), child: ArabicText('خطأ أثناء تحميل الأحاديث: $err'))),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Hadith>> hadithsAsync, ThemeData theme) {
    if (_searchQuery.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.search, size: 64, color: theme.disabledColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            ArabicText(
              'ابحث بالكلمة، الراوي، الكتاب...',
              style: GoogleFonts.cairo(fontSize: 16, color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    return hadithsAsync.when(
      data: (hadiths) {
        if (hadiths.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: theme.disabledColor.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                ArabicText(
                  'لم يتم العثور على أي نتائج لـ "$_searchQuery"',
                  style: GoogleFonts.cairo(fontSize: 16, color: theme.disabledColor),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: hadiths.length,
          itemBuilder: (context, idx) {
            final hadith = hadiths[idx];
            return _buildHadithListItem(hadith, theme, idx);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: ArabicText(
            'خطأ أثناء تحميل نتائج البحث: $err',
            style: GoogleFonts.cairo(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildHadithListItem(Hadith hadith, ThemeData theme, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: InkWell(
        onTap: () => context.push('/hadith/detail/${hadith.id}'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ArabicText(
                hadith.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B1E1E), // Deep brown matching quran text
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ArabicText(
                      'الراوي: ${hadith.narrator.isNotEmpty ? hadith.narrator : "غير متوفر"}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BookmarkButton(
                        hadithId: hadith.id,
                        onToggle: () {
                          ref.invalidate(bookmarkedHadithsProvider);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.share, 
                          color: theme.colorScheme.secondary.withValues(alpha: 0.7), 
                          size: 20
                        ),
                        onPressed: () {
                          final shareText = 'قال رسول الله ﷺ:\n'
                              '« ${hadith.text} »\n\n'
                              'الراوي: ${hadith.narrator}\n'
                              'المصدر: ${hadith.source}\n\n'
                              'تمت المشاركة من تطبيق إيمان';
                          SharePlus.instance.share(ShareParams(text: shareText));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (30 * index).ms).fadeIn().slideY(begin: 0.05, end: 0);
  }
}

class _BookmarkButton extends ConsumerWidget {
  final int hadithId;
  final VoidCallback? onToggle;

  const _BookmarkButton({required this.hadithId, this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBookmarkedAsync = ref.watch(isHadithBookmarkedProvider(hadithId));

    return isBookmarkedAsync.when(
      data: (isBookmarked) => IconButton(
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: isBookmarked ? theme.colorScheme.secondary : Colors.grey.withValues(alpha: 0.5),
          size: 22,
        ),
        onPressed: () async {
          HapticFeedback.lightImpact();
          final repo = ref.read(hadithRepositoryProvider);
          await repo.toggleBookmark(hadithId);
          ref.invalidate(isHadithBookmarkedProvider(hadithId));
          ref.invalidate(bookmarkedHadithsProvider);
          ref.invalidate(filteredHadithsProvider);
          onToggle?.call();
        },
      ),
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
