import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/repositories/hadith_repository_provider.dart';
import '../../domain/entities/hadith_entities.dart';
import 'hadith_index_screen.dart'; // To reuse HadithSearchFilter
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/responsive/app_insets.dart';

final bookHadithsProvider = FutureProvider.family<List<Hadith>, int>((ref, bookId) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getHadithsByBook(bookId);
});

class HadithBookDetailScreen extends ConsumerStatefulWidget {
  final int bookId;
  const HadithBookDetailScreen({super.key, required this.bookId});

  @override
  ConsumerState<HadithBookDetailScreen> createState() => _HadithBookDetailScreenState();
}

class _HadithBookDetailScreenState extends ConsumerState<HadithBookDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  HadithSearchFilter _selectedFilter = HadithSearchFilter.all;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booksAsync = ref.watch(hadithBooksProvider);
    final hadithsAsync = ref.watch(bookHadithsProvider(widget.bookId));

    // Find current book
    final currentBook = booksAsync.value?.firstWhere(
      (b) => b.id == widget.bookId,
      orElse: () => HadithBook(id: widget.bookId, title: 'الكتاب', author: '', description: ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ابحث في أحاديث الكتاب...',
                  hintStyle: GoogleFonts.cairo(color: theme.disabledColor),
                  border: InputBorder.none,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArabicText(
                    currentBook?.title ?? 'الكتاب',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (currentBook != null && currentBook.author.isNotEmpty)
                    ArabicText(
                      currentBook.author,
                      style: GoogleFonts.cairo(fontSize: 10, color: theme.colorScheme.secondary),
                    ),
                ],
              ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(LucideIcons.arrowRight),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : IconButton(
                icon: const Icon(LucideIcons.arrowRight),
                onPressed: () => context.pop(),
              ),
        actions: _isSearching
            ? [
                PopupMenuButton<HadithSearchFilter>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Icon(
                    _selectedFilter == HadithSearchFilter.all
                        ? LucideIcons.filter
                        : Icons.filter_alt_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.all,
                      title: 'البحث في الكل',
                      icon: Icons.all_inclusive_rounded,
                      isSelected: _selectedFilter == HadithSearchFilter.all,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.text,
                      title: 'متن الحديث فقط',
                      icon: LucideIcons.quote,
                      isSelected: _selectedFilter == HadithSearchFilter.text,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.narrator,
                      title: 'الراوي فقط',
                      icon: LucideIcons.user,
                      isSelected: _selectedFilter == HadithSearchFilter.narrator,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithSearchFilter.explanation,
                      title: 'الشرح والتفسير',
                      icon: LucideIcons.bookOpen,
                      isSelected: _selectedFilter == HadithSearchFilter.explanation,
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () {
                      _searchController.clear();
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
      body: hadithsAsync.when(
        data: (hadiths) {
          // Filter hadiths by search query locally
          final filteredHadiths = hadiths.where((h) {
            if (!_isSearching) return true;
            if (_searchQuery.isEmpty) return false; // Show blank page during search when empty
            final q = _searchQuery.toLowerCase();
            switch (_selectedFilter) {
              case HadithSearchFilter.all:
                return h.text.toLowerCase().contains(q) ||
                    h.narrator.toLowerCase().contains(q) ||
                    h.explanation.toLowerCase().contains(q);
              case HadithSearchFilter.text:
                return h.text.toLowerCase().contains(q);
              case HadithSearchFilter.narrator:
                return h.narrator.toLowerCase().contains(q);
              case HadithSearchFilter.explanation:
                return h.explanation.toLowerCase().contains(q);
            }
          }).toList();

          if (filteredHadiths.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                child: ArabicText(
                  _isSearching
                      ? (_searchQuery.isEmpty
                          ? '' // Blank page
                          : 'لا توجد أحاديث تطابق بحثك في هذا الكتاب.')
                      : 'لا توجد أحاديث في هذا الكتاب حالياً.',
                  style: GoogleFonts.cairo(color: theme.disabledColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + context.navBarInset),
            itemCount: filteredHadiths.length,
            itemBuilder: (context, idx) {
              final hadith = filteredHadiths[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: theme.dividerColor, width: 0.8),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/hadith/detail/${hadith.id}');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.quote,
                                color: theme.colorScheme.secondary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ArabicText(
                                  hadith.narrator.isNotEmpty ? hadith.narrator : 'راوي غير معروف',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ArabicText(
                                  'حديث رقم ${idx + 1}',
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
                            hadith.text,
                            style: GoogleFonts.amiri(
                              fontSize: 16,
                              height: 1.8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B1E1E),
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ArabicText(
                                'تخريج وشرح الحديث...',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: theme.disabledColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronLeft,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: (30 * idx).ms).fade().slideY(begin: 0.05, end: 0),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: ArabicText(
            'حدث خطأ أثناء تحميل الأحاديث: $err',
            style: GoogleFonts.cairo(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}
