import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/repositories/hadith_repository_provider.dart';
import '../../domain/entities/hadith_entities.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

enum HadithBookSearchFilter {
  all,
  title,
  author,
}

class HadithBooksListScreen extends ConsumerStatefulWidget {
  const HadithBooksListScreen({super.key});

  @override
  ConsumerState<HadithBooksListScreen> createState() => _HadithBooksListScreenState();
}

class _HadithBooksListScreenState extends ConsumerState<HadithBooksListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  HadithBookSearchFilter _selectedFilter = HadithBookSearchFilter.all;

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

  PopupMenuItem<HadithBookSearchFilter> _buildPopupMenuItem({
    required BuildContext context,
    required HadithBookSearchFilter value,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem<HadithBookSearchFilter>(
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

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ابحث في كتب الأحاديث...',
                  hintStyle: GoogleFonts.cairo(color: theme.disabledColor),
                  border: InputBorder.none,
                ),
              )
            : ArabicText(
                'كتب الأحاديث',
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
                PopupMenuButton<HadithBookSearchFilter>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Icon(
                    _selectedFilter == HadithBookSearchFilter.all
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
                      value: HadithBookSearchFilter.all,
                      title: 'البحث في الكل',
                      icon: Icons.all_inclusive_rounded,
                      isSelected: _selectedFilter == HadithBookSearchFilter.all,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithBookSearchFilter.title,
                      title: 'عنوان الكتاب فقط',
                      icon: LucideIcons.bookOpen,
                      isSelected: _selectedFilter == HadithBookSearchFilter.title,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      context: context,
                      value: HadithBookSearchFilter.author,
                      title: 'اسم المؤلف فقط',
                      icon: LucideIcons.user,
                      isSelected: _selectedFilter == HadithBookSearchFilter.author,
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
      body: booksAsync.when(
        data: (books) {
          // Filter books list locally
          final filteredBooks = books.where((book) {
            if (!_isSearching) return true;
            if (_searchQuery.isEmpty) return false; // Show blank page during search when empty
            final q = _searchQuery.toLowerCase();
            switch (_selectedFilter) {
              case HadithBookSearchFilter.all:
                return book.title.toLowerCase().contains(q) ||
                    book.author.toLowerCase().contains(q) ||
                    book.description.toLowerCase().contains(q);
              case HadithBookSearchFilter.title:
                return book.title.toLowerCase().contains(q);
              case HadithBookSearchFilter.author:
                return book.author.toLowerCase().contains(q);
            }
          }).toList();

          if (filteredBooks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ArabicText(
                  _isSearching
                      ? (_searchQuery.isEmpty 
                          ? '' // Blank page as requested when search is clicked but nothing typed yet
                          : 'لا توجد كتب تطابق هذا البحث.')
                      : 'لا توجد كتب متاحة حالياً.',
                  style: GoogleFonts.cairo(color: theme.disabledColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: filteredBooks.length,
            itemBuilder: (context, idx) {
              final book = filteredBooks[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: theme.dividerColor, width: 0.8),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/hadith/book/${book.id}');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.bookOpen,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArabicText(
                                  book.title,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (book.author.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  ArabicText(
                                    book.author,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                if (book.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ArabicText(
                                    book.description,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.chevronLeft,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: (50 * idx).ms).fade().slideY(begin: 0.05, end: 0),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: ArabicText(
            'حدث خطأ أثناء تحميل الكتب: $err',
            style: GoogleFonts.cairo(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}
