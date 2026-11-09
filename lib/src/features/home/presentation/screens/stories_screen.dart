import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/core/responsive/app_insets.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<dynamic> _allStories = [];
  List<dynamic> _filteredStories = [];
  Set<int> _favoriteIds = {};
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['الكل', 'قصص الأنبياء', 'قصص الصحابة والتابعين', 'قصص وعبر قرآنية'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/stories.json');
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      final prefs = await SharedPreferences.getInstance();
      final List<String>? favList = prefs.getStringList('favorite_stories_ids');
      Set<int> favorites = {};
      if (favList != null) {
        favorites = favList.map(int.parse).toSet();
      }

      setState(() {
        _allStories = data['stories'] ?? [];
        _filteredStories = _allStories;
        _favoriteIds = favorites;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
        HapticFeedback.lightImpact();
      } else {
        _favoriteIds.add(id);
        HapticFeedback.vibrate();
      }
    });
    final list = _favoriteIds.map((e) => e.toString()).toList();
    await prefs.setStringList('favorite_stories_ids', list);
  }

  void _filterAndSearch() {
    setState(() {
      _filteredStories = _allStories.where((story) {
        final matchesCategory = _selectedCategory == 'الكل' || story['category'] == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            story['title'].toString().contains(_searchQuery) ||
            story['content'].toString().contains(_searchQuery) ||
            (story['lessons'] as List).any((l) => l.toString().contains(_searchQuery));
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  int _calculateReadingTime(String content) {
    final words = content.split(RegExp(r'\s+')).length;
    // Average reading speed: 150 words per minute
    return (words / 150).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowRight, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ArabicText(
          'قصص وعبر إسلامية',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      _filterAndSearch();
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قصة، نبي، أو عبرة...',
                      prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _filterAndSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                // 2. Category Chips
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: ArabicText(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            _filterAndSearch();
                          },
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : theme.colorScheme.primary,
                          ),
                          selectedColor: theme.colorScheme.primary,
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : theme.colorScheme.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Stories List
                Expanded(
                  child: _filteredStories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.bookOpen, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              ArabicText(
                                'لم يتم العثور على قصص تطابق البحث.',
                                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20, 4, 20, AppInsets.page(context, gap: 20)),
                          itemCount: _filteredStories.length,
                          itemBuilder: (context, index) {
                            final story = _filteredStories[index];
                            final id = story['id'] as int;
                            final isFav = _favoriteIds.contains(id);
                            final readTime = _calculateReadingTime(story['content']);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: theme.dividerColor.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoryDetailScreen(
                                        story: story,
                                        isFavorite: isFav,
                                        onFavoriteToggled: () => _toggleFavorite(id),
                                      ),
                                    ),
                                  );
                                  // Refresh favorites when returning
                                  _loadData();
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Header inside Card
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ArabicText(
                                              story['category'],
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isFav ? Icons.bookmark : Icons.bookmark_border,
                                              color: isFav ? theme.colorScheme.secondary : Colors.grey,
                                              size: 20,
                                            ),
                                            onPressed: () => _toggleFavorite(id),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Title
                                      ArabicText(
                                        story['title'],
                                        style: GoogleFonts.cairo(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Content Preview
                                      ArabicText(
                                        story['content'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Footer info
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.clock, size: 13, color: Colors.grey),
                                              const SizedBox(width: 5),
                                              ArabicText(
                                                '$readTime دقائق للقراءة',
                                                style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              ArabicText(
                                                'اقرأ القصة',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.secondary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 14,
                                                color: theme.colorScheme.secondary,
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
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> story;
  final bool isFavorite;
  final VoidCallback onFavoriteToggled;

  const StoryDetailScreen({
    super.key,
    required this.story,
    required this.isFavorite,
    required this.onFavoriteToggled,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  double _fontSize = 16.0;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _shareStory() {
    final String shareText = 'من قصص وعبر إيمان:\n\n'
        '📌 ${widget.story['title']}\n\n'
        '${widget.story['content']}\n\n'
        '💡 العبر والدروس المستفادة:\n'
        '${(widget.story['lessons'] as List).map((l) => '- $l').join('\n')}\n\n'
        'تمت المشاركة من تطبيق إيمان 🌸';
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _copyStory() {
    final String copyText = '${widget.story['title']}\n\n'
        '${widget.story['content']}\n\n'
        'الدروس المستفادة:\n'
        '${(widget.story['lessons'] as List).map((l) => '- $l').join('\n')}';
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ArabicText(
          'تم نسخ نص القصة والعبر المستفادة',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasVerses = widget.story['quranVerses'] != null && widget.story['quranVerses'].toString().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm cream background for comfortable reading
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowRight, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ArabicText(
          widget.story['title'],
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: _isFavorite ? theme.colorScheme.secondary : theme.colorScheme.primary,
            ),
            onPressed: () {
              widget.onFavoriteToggled();
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.copy),
            onPressed: _copyStory,
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: _shareStory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Font size slider bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Icon(LucideIcons.type, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                ArabicText(
                  'حجم الخط',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 14.0,
                    max: 28.0,
                    divisions: 7,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    onChanged: (val) {
                      setState(() {
                        _fontSize = val;
                      });
                    },
                  ),
                ),
                ArabicText(
                  _fontSize.toInt().toString(),
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Story Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, AppInsets.page(context, gap: 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category badge
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ArabicText(
                        widget.story['category'],
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Core Content
                  ArabicText(
                    widget.story['content'],
                    style: GoogleFonts.cairo(
                      fontSize: _fontSize,
                      height: 1.8,
                      color: const Color(0xFF3B1E1E), // Deep brown readability color
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Quran verses reference if exists
                  if (hasVerses) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.bookOpen, size: 16, color: theme.colorScheme.secondary),
                              const SizedBox(width: 8),
                              ArabicText(
                                'موضع الآيات في القرآن الكريم',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ArabicText(
                            widget.story['quranVerses'],
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Lessons and morals
                  ArabicText(
                    'الدروس والعبر المستفادة',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (widget.story['lessons'] as List).map((lesson) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ArabicText(
                                lesson,
                                style: GoogleFonts.cairo(
                                  fontSize: _fontSize - 2,
                                  height: 1.5,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
