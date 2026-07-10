import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';

class SunanScreen extends StatefulWidget {
  const SunanScreen({super.key});

  @override
  State<SunanScreen> createState() => _SunanScreenState();
}

class _SunanScreenState extends State<SunanScreen> {
  List<dynamic> _allSunan = [];
  List<dynamic> _filteredSunan = [];
  Set<int> _completedIds = {};
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  
  final List<String> _categories = ['الكل', 'الاستيقاظ', 'الصلاة والوضوء', 'الطعام والشراب', 'النوم', 'عامة'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Load Sunnahs JSON
      final jsonStr = await rootBundle.loadString('assets/sunan.json');
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      
      // 2. Load SharedPreferences completed status
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final savedDate = prefs.getString('sunan_date');
      
      Set<int> completed = {};
      if (savedDate == today) {
        final List<String>? ids = prefs.getStringList('sunan_completed_ids');
        if (ids != null) {
          completed = ids.map(int.parse).toSet();
        }
      } else {
        // New day, reset completion
        await prefs.setString('sunan_date', today);
        await prefs.setStringList('sunan_completed_ids', []);
      }

      setState(() {
        _allSunan = data['sunan'] ?? [];
        _filteredSunan = _allSunan;
        _completedIds = completed;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sunan: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCompletion(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Ensure day is current
    await prefs.setString('sunan_date', today);

    setState(() {
      if (_completedIds.contains(id)) {
        _completedIds.remove(id);
        HapticFeedback.lightImpact();
      } else {
        _completedIds.add(id);
        HapticFeedback.vibrate();
      }
    });

    final idsList = _completedIds.map((e) => e.toString()).toList();
    await prefs.setStringList('sunan_completed_ids', idsList);
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'الكل') {
        _filteredSunan = _allSunan;
      } else {
        _filteredSunan = _allSunan.where((item) => item['category'] == category).toList();
      }
    });
  }

  void _shareSunnah(Map<String, dynamic> sunnah) {
    final String shareText = 'قال النبي ﷺ:\n'
        '« ${sunnah['hadith']} »\n\n'
        'السنّة المأثورة: ${sunnah['title']}\n'
        '${sunnah['description']}\n\n'
        'المصدر: ${sunnah['reference']}\n'
        'تمت المشاركة من تطبيق زاد المسلم 🌸';
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  String _getEncouragingMessage() {
    if (_allSunan.isEmpty) return '';
    final percent = _completedIds.length / _allSunan.length;
    if (percent == 0) {
      return 'ابدأ يومك بتطبيق سنن الحبيب ﷺ';
    } else if (percent < 0.4) {
      return 'جميل! استمر في إحياء السنّة النبوية';
    } else if (percent < 0.8) {
      return 'عمل رائع! اقتربت من تطبيق سنن اليوم بالكامل';
    } else {
      return 'ما شاء الله! هنيئاً لك إحياء سنن نبيك ﷺ اليوم';
    }
  }

  void _showDetailsBottomSheet(Map<String, dynamic> sunnah) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isCompleted = _completedIds.contains(sunnah['id']);
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Category Badge & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ArabicText(
                            sunnah['category'],
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.share2, size: 20),
                          onPressed: () => _shareSunnah(sunnah),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ArabicText(
                      sunnah['title'],
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ArabicText(
                      sunnah['description'],
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hadith box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.quote, color: theme.colorScheme.secondary, size: 18),
                              const SizedBox(width: 8),
                              ArabicText(
                                'الدليل الشرعي',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ArabicText(
                            '« ${sunnah['hadith']} »',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              height: 1.8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B1E1E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ArabicText(
                            sunnah['reference'],
                            textAlign: TextAlign.left,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reward/Benefit Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.sparkles, color: theme.colorScheme.secondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArabicText(
                                  'الفضل والأجر',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ArabicText(
                                  sunnah['benefit'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyMedium?.color,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Toggle Complete Button in Bottom Sheet
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.grey.shade400 : theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        await _toggleCompletion(sunnah['id']);
                        setModalState(() {});
                        // Update outer state
                        setState(() {});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          ArabicText(
                            isCompleted ? 'تم تطبيق السنة اليوم' : 'طبقتها اليوم',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSunan = _allSunan.length;
    final completedCount = _completedIds.length;
    final progress = totalSunan > 0 ? completedCount / totalSunan : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowRight, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ArabicText(
          'السنن النبوية اليومية',
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
                // 1. Progress Header Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary, // Burgundy
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArabicText(
                                  'إحياء السنّة النبوية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ArabicText(
                                  _getEncouragingMessage(),
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ArabicText(
                                '$completedCount / $totalSunan',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary, // Gold
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Linear progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade().slideY(begin: -0.1, end: 0, duration: 400.ms),
                ),

                // 2. Categories Scrollable Filter
                SizedBox(
                  height: 46,
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
                          onSelected: (_) => _filterByCategory(cat),
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
                const SizedBox(height: 12),

                // 3. ListView of Sunan
                Expanded(
                  child: _filteredSunan.isEmpty
                      ? Center(
                          child: ArabicText(
                            'لا توجد سنن متوفرة في هذا التصنيف.',
                            style: GoogleFonts.cairo(fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: _filteredSunan.length,
                          itemBuilder: (context, index) {
                            final sunnah = _filteredSunan[index];
                            final id = sunnah['id'] as int;
                            final isCompleted = _completedIds.contains(id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isCompleted
                                      ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                                      : theme.dividerColor.withValues(alpha: 0.08),
                                  width: 1.2,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _showDetailsBottomSheet(sunnah),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Circle checkbox / Check state
                                      GestureDetector(
                                        onTap: () => _toggleCompletion(id),
                                        child: AnimatedContainer(
                                          duration: 200.ms,
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isCompleted
                                                ? theme.colorScheme.secondary
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isCompleted
                                                  ? theme.colorScheme.secondary
                                                  : Colors.grey.shade400,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: isCompleted
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Text Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: ArabicText(
                                                    sunnah['category'],
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ArabicText(
                                              sunnah['title'],
                                              style: GoogleFonts.cairo(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: isCompleted
                                                    ? theme.colorScheme.primary.withValues(alpha: 0.6)
                                                    : theme.colorScheme.primary,
                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            ArabicText(
                                              sunnah['description'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Chevron Right
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate(delay: (20 * index).ms).fadeIn().slideY(begin: 0.04, end: 0);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
