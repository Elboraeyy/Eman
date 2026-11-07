import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../data/repositories/adhkar_repository_provider.dart';
import '../../domain/entities/adhkar_entities.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';
import 'package:iman/src/features/tracker/data/repositories/tracker_repository_provider.dart';

enum AdhkarSearchFilter {
  all,
  categories,
  items,
}

// Providers for loading data
final adhkarCategoriesListProvider = FutureProvider<List<AdhkarCategory>>((ref) async {
  final repo = ref.watch(adhkarRepositoryProvider);
  return await repo.getAllCategories();
});

final adhkarAllItemsProvider = FutureProvider<List<AdhkarItem>>((ref) async {
  final repo = ref.watch(adhkarRepositoryProvider);
  return await repo.getAllAdhkarItems();
});

class AdhkarGroup {
  final String title;
  final IconData icon;
  final List<int> categoryIds;

  const AdhkarGroup({
    required this.title,
    required this.icon,
    required this.categoryIds,
  });
}

const List<AdhkarGroup> _adhkarGroups = [
  AdhkarGroup(
    title: 'الأذكار اليومية',
    icon: LucideIcons.sun,
    categoryIds: [1, 2, 3, 28, 29, 30, 31, 134],
  ),
  AdhkarGroup(
    title: 'أدعية اللباس والمنزل والمسجد',
    icon: LucideIcons.home,
    categoryIds: [4, 5, 6, 7, 8, 11, 12, 13, 14, 15],
  ),
  AdhkarGroup(
    title: 'الأذان والطهارة والوضوء',
    icon: LucideIcons.droplets,
    categoryIds: [9, 10, 16],
  ),
  AdhkarGroup(
    title: 'أدعية الصلاة وأذكارها',
    icon: LucideIcons.bookOpen,
    categoryIds: [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 32, 33],
  ),
  AdhkarGroup(
    title: 'أدعية الهم والكرب وتفريج الشدائد',
    icon: LucideIcons.helpCircle,
    categoryIds: [34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 81, 125, 127],
  ),
  AdhkarGroup(
    title: 'العلاقات والتعاملات الاجتماعية والأسرة',
    icon: LucideIcons.userCheck,
    categoryIds: [46, 47, 78, 79, 80, 82, 83, 84, 85, 86, 88, 89, 90, 92, 107, 108, 111, 112, 113, 121, 122, 124],
  ),
  AdhkarGroup(
    title: 'أدعية المرض والموت والجنائز',
    icon: LucideIcons.heartPulse,
    categoryIds: [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 123],
  ),
  AdhkarGroup(
    title: 'أدعية السفر والركوب',
    icon: LucideIcons.compass,
    categoryIds: [94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104],
  ),
  AdhkarGroup(
    title: 'أدعية الطعام والشراب والضيافة والعطاس',
    icon: LucideIcons.utensils,
    categoryIds: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77],
  ),
  AdhkarGroup(
    title: 'أدعية الطبيعة والمطر والرياح ورؤية الهلال',
    icon: LucideIcons.cloudRain,
    categoryIds: [60, 61, 62, 63, 64, 65, 66, 109, 110],
  ),
  AdhkarGroup(
    title: 'مناسك الحج والعمرة والرمي',
    icon: LucideIcons.map,
    categoryIds: [114, 115, 116, 117, 118, 119, 120, 126],
  ),
  AdhkarGroup(
    title: 'الاستغفار والرقية الشرعية وفضائل الأذكار',
    icon: LucideIcons.shield,
    categoryIds: [87, 91, 93, 105, 106, 128, 129, 130, 131, 132, 133, 135],
  ),
];

class AdhkarIndexScreen extends ConsumerStatefulWidget {
  const AdhkarIndexScreen({super.key});

  @override
  ConsumerState<AdhkarIndexScreen> createState() => _AdhkarIndexScreenState();
}

class _AdhkarIndexScreenState extends ConsumerState<AdhkarIndexScreen> {
  AdhkarCategory? _selectedCategory;
  List<AdhkarItem>? _cachedCategoryItems;
  Map<int, int> _itemsProgress = {}; // itemId -> currentCount
  bool _isLoadingCategory = false;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  AdhkarSearchFilter _selectedFilter = AdhkarSearchFilter.all;
  int? _expandedGroupIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryItems(AdhkarCategory cat) async {
    setState(() {
      _isLoadingCategory = true;
      _selectedCategory = cat;
    });

    try {
      final repo = ref.read(adhkarRepositoryProvider);
      final items = await repo.getAdhkarByCategory(cat.id);
      final todayStr = DateFormat('yyyy-MM-DD').format(DateTime.now());
      
      final Map<int, int> progress = {};
      for (final item in items) {
        final count = await repo.getAdhkarProgress(item.id, todayStr);
        progress[item.id] = count;
      }

      setState(() {
        _cachedCategoryItems = items;
        _itemsProgress = progress;
        _isLoadingCategory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategory = false;
      });
    }
  }

  Future<void> _incrementProgress(AdhkarItem item) async {
    final current = _itemsProgress[item.id] ?? 0;
    if (current >= item.targetCount) return; // Already completed

    final todayStr = DateFormat('yyyy-MM-DD').format(DateTime.now());
    final repo = ref.read(adhkarRepositoryProvider);
    
    // Light haptic feedback for each tap
    HapticFeedback.lightImpact();

    await repo.incrementAdhkarProgress(item.id, todayStr, item.targetCount);
    
    final newCount = current + 1;
    setState(() {
      _itemsProgress[item.id] = newCount;
    });

    // Heavy haptic feedback when completed
    if (newCount == item.targetCount) {
      HapticFeedback.heavyImpact();
      try {
        ref.read(trackerRepositoryProvider).recordAdhkarCompleted();
      } catch (_) {}
    }
  }

  Future<void> _resetCategoryProgress() async {
    if (_selectedCategory == null) return;
    final todayStr = DateFormat('yyyy-MM-DD').format(DateTime.now());
    final repo = ref.read(adhkarRepositoryProvider);
    
    await repo.resetAdhkarProgress(_selectedCategory!.id, todayStr);
    
    final updatedProgress = <int, int>{};
    for (final key in _itemsProgress.keys) {
      updatedProgress[key] = 0;
    }

    setState(() {
      _itemsProgress = updatedProgress;
    });
  }

  IconData _getCategoryIcon(int id) {
    switch (id) {
      case 1:
        return Icons.wb_sunny_rounded; // أذكار الصباح
      case 2:
        return Icons.nights_stay_rounded; // أذكار المساء
      case 3:
        return Icons.bedtime_rounded; // أذكار النوم
      case 4:
        return Icons.wb_twilight_rounded; // أذكار الاستيقاظ
      case 5:
      case 6:
        return Icons.mosque_rounded; // أذكار الصلاة / بعد الصلاة
      default:
        return Icons.bookmark_added_rounded;
    }
  }

  Color _getCategoryColor(int id, ThemeData theme) {
    switch (id) {
      case 1:
        return const Color(0xFFFFA000); // Amber
      case 2:
        return const Color(0xFF3F51B5); // Indigo
      case 3:
        return const Color(0xFF673AB7); // Deep Purple
      case 4:
        return const Color(0xFFFF5722); // Orange
      case 5:
      case 6:
        return const Color(0xFF009688); // Teal
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIconData(int id) {
    switch (id) {
      case 1: return LucideIcons.sun; // أذكار الصباح
      case 2: return LucideIcons.moon; // أذكار المساء
      case 3: return LucideIcons.sunrise; // أذكار الاستيقاظ من النوم
      case 4: return LucideIcons.shirt; // دعاء لبس الثوب
      case 5: return LucideIcons.shirt; // دعاء لبس الثوب الجديد
      case 6: return LucideIcons.shirt; // ما يقول إذا وضع الثوب
      case 7: return LucideIcons.doorOpen; // دعاء دخول الخلاء
      case 8: return LucideIcons.doorOpen; // دعاء الخروج من الخلاء
      case 9: return LucideIcons.droplet; // الذكر قبل الوضوء
      case 10: return LucideIcons.droplets; // الذكر بعد الفراغ من الوضوء
      case 11: return LucideIcons.doorOpen; // الذكر عند الخروج من المنزل
      case 12: return LucideIcons.home; // الذكر عند دخول المنزل
      case 13: return LucideIcons.compass; // دعاء الذهاب إلى المسجد
      case 14: return LucideIcons.home; // دعاء دخول المسجد
      case 15: return LucideIcons.doorOpen; // دعاء الخروج من المسجد
      case 16: return LucideIcons.bell; // أذكار الآذان
      case 17: return LucideIcons.bookOpen; // دعاء الاستفتاح
      case 18: return LucideIcons.scroll; // دعاء الركوع
      case 19: return LucideIcons.scroll; // دعاء الرفع من الركوع
      case 20: return LucideIcons.scroll; // دعاء السجود
      case 21: return LucideIcons.scroll; // دعاء الجلسة بين السجدتين
      case 22: return LucideIcons.bookOpen; // دعاء سجود التلاوة
      case 23: return LucideIcons.scroll; // التشهد
      case 24: return LucideIcons.sparkles; // الصلاة على النبي بعد التشهد
      case 25: return LucideIcons.helpCircle; // الدعاء بعد التشهد الأخير قبل السلام
      case 26: return LucideIcons.scroll; // الأذكار بعد السلام من الصلاة
      case 27: return LucideIcons.compass; // دعاء صلاة الاستخارة
      case 28: return LucideIcons.bed; // أذكار النوم
      case 29: return LucideIcons.bed; // الدعاء إذا تقلب في الليل
      case 30: return LucideIcons.alertTriangle; // دعاء الفزع في النوم و من بلي بالوحشة
      case 31: return LucideIcons.smile; // ما يفعل من رأى الرؤيا أو الحلم في النوم
      case 32: return LucideIcons.helpCircle; // دعاء قنوت الوتر
      case 33: return LucideIcons.scroll; // الذكر عقب السلام من الوتر
      case 34: return LucideIcons.frown; // دعاء الهم والحزن
      case 35: return LucideIcons.frown; // دعاء الكرب
      case 36: return LucideIcons.shield; // دعاء لقاء العدو و ذي السلطان
      case 37: return LucideIcons.shieldAlert; // الدعاء على العدو
      case 38: return LucideIcons.alertTriangle; // ما يقول من خاف قوما
      case 39: return LucideIcons.anchor; // دعاء من أصابه وسوسة في الإيمان
      case 40: return LucideIcons.dollarSign; // دعاء قضاء الدين
      case 41: return LucideIcons.alertTriangle; // دعاء الوسوسة في الصلاة و القراءة
      case 42: return LucideIcons.activity; // دعاء من استصعب عليه أمر
      case 43: return LucideIcons.checkCircle; // ما يقول ويفعل من أذنب ذنبا
      case 44: return LucideIcons.shield; // دعاء طرد الشيطان و وساوسه
      case 45: return LucideIcons.anchor; // الدعاء حينما يقع ما لا يرضاه أو غلب على أمره
      case 46: return LucideIcons.gift; // ﺗﻬنئة المولود له وجوابه
      case 47: return LucideIcons.shield; // ما يعوذ به الأولاد
      case 48: return LucideIcons.heart; // الدعاء للمريض في عيادته
      case 49: return LucideIcons.heartPulse; // فضل عيادة المريض
      case 50: return LucideIcons.frown; // دعاء المريض الذي يئس من حياته
      case 51: return LucideIcons.scroll; // تلقين المحتضر
      case 52: return LucideIcons.frown; // دعاء من أصيب بمصيبة
      case 53: return LucideIcons.eye; // الدعاء عند إغماض الميت
      case 54: return LucideIcons.heart; // الدعاء للميت في الصلاة عليه
      case 55: return LucideIcons.heart; // الدعاء للفرط في الصلاة عليه
      case 56: return LucideIcons.users; // دعاء التعزية
      case 57: return LucideIcons.doorOpen; // الدعاء عند إدخال الميت القبر
      case 58: return LucideIcons.anchor; // الدعاء بعد دفن الميت
      case 59: return LucideIcons.compass; // دعاء زيارة القبور
      case 60: return LucideIcons.wind; // دعاء الريح
      case 61: return LucideIcons.zap; // دعاء الرعد
      case 62: return LucideIcons.cloudRain; // من أدعية الاستسقاء
      case 63: return LucideIcons.cloudRain; // الدعاء إذا نزل المطر
      case 64: return LucideIcons.sparkles; // الذكر بعد نزول المطر
      case 65: return LucideIcons.sun; // من أدعية الاستصحاء
      case 66: return LucideIcons.moon; // دعاء رؤية الهلال
      case 67: return LucideIcons.sunset; // الدعاء عند إفطار الصائم
      case 68: return LucideIcons.utensils; // الدعاء قبل الطعام
      case 69: return LucideIcons.utensils; // الدعاء عند الفراغ من الطعام
      case 70: return LucideIcons.heart; // دعاء الضيف لصاحب الطعام
      case 71: return LucideIcons.utensils; // التعريض بالدعاء لطلب الطعام أو الشراب
      case 72: return LucideIcons.home; // الدعاء إذا أفطر عند أهل بيت
      case 73: return LucideIcons.utensils; // دعاء الصائم إذا حضر الطعام ولم يفطر
      case 74: return LucideIcons.smile; // ما يقول الصائم إذا سابه أحد
      case 75: return LucideIcons.sun; // الدعاء عند رؤية باكورة الثمر
      case 76: return LucideIcons.smile; // دعاء العطاس
      case 77: return LucideIcons.users; // ما يقال للكافر إذا عطس فحمد الله
      case 78: return LucideIcons.heart; // الدعاء للمتزوج
      case 79: return LucideIcons.car; // دعاء المتزوج و شراء الدابة
      case 80: return LucideIcons.heart; // الدعاء قبل إتيان الزوجة
      case 81: return LucideIcons.flame; // دعاء الغضب
      case 82: return LucideIcons.activity; // دعاء من رأى مبتلى
      case 83: return LucideIcons.users; // ما يقال في اﻟﻤﺠلس
      case 84: return LucideIcons.archive; // كفارة اﻟﻤﺠلس
      case 85: return LucideIcons.checkCircle; // الدعاء لمن قال غفر الله لك
      case 86: return LucideIcons.gift; // الدعاء لمن صنع إليك معروفا
      case 87: return LucideIcons.shield; // ما يعصم الله به من الدجال
      case 88: return LucideIcons.heart; // الدعاء لمن قال إني أحبك في الله
      case 89: return LucideIcons.dollarSign; // الدعاء لمن عرض عليك ماله
      case 90: return LucideIcons.dollarSign; // الدعاء لمن أقرض عند القضاء
      case 91: return LucideIcons.shieldAlert; // دعاء الخوف من الشرك
      case 92: return LucideIcons.sparkles; // الدعاء لمن قال بارك الله فيك
      case 93: return LucideIcons.alertTriangle; // دعاء كراهية الطيرة
      case 94: return LucideIcons.car; // دعاء الركوب
      case 95: return LucideIcons.plane; // دعاء السفر
      case 96: return LucideIcons.home; // دعاء دخول القرية أو البلدة
      case 97: return LucideIcons.briefcase; // دعاء دخول السوق
      case 98: return LucideIcons.alertTriangle; // الدعاء إذا تعس المركوب
      case 99: return LucideIcons.userCheck; // دعاء المسافر للمقيم
      case 100: return LucideIcons.userCheck; // دعاء المقيم للمسافر
      case 101: return LucideIcons.anchor; // التكبير و التسبيح في سير السفر
      case 102: return LucideIcons.moon; // دعاء المسافر إذا أسحر
      case 103: return LucideIcons.home; // الدعاء إذا نزل مترلا في سفر أو غيره
      case 104: return LucideIcons.doorOpen; // ذكر الرجوع من السفر
      case 105: return LucideIcons.smile; // ما يقول من أتاه أمر يسره أو يكرهه
      case 106: return LucideIcons.sparkles; // فضل الصلاة على النبي صلى الله عليه و سلم
      case 107: return LucideIcons.users; // إفشاء السلام
      case 108: return LucideIcons.users; // كيف يرد السلام على الكافر إذا سلم
      case 109: return LucideIcons.music; // الدعاء عند سماع صياح الديك ونهيق الحمار
      case 110: return LucideIcons.alertTriangle; // دعاء نباح الكلب بالليل
      case 111: return LucideIcons.helpCircle; // الدعاء لمن سببته
      case 112: return LucideIcons.thumbsUp; // ما يقول المسلم إذا مدح المسلم
      case 113: return LucideIcons.thumbsUp; // ما يقول المسلم إذا زكي
      case 114: return LucideIcons.map; // كيف يلبي المحرم في الحج أو العمرة ؟
      case 115: return LucideIcons.checkCircle; // التكبير إذا أتى الركن الأسود
      case 116: return LucideIcons.compass; // الدعاء بين الركن اليماني والحجر الأسود
      case 117: return LucideIcons.map; // دعاء الوقوف على الصفا والمروة
      case 118: return LucideIcons.sun; // الدعاء يوم عرفة
      case 119: return LucideIcons.anchor; // الذكر عند المشعر الحرام
      case 120: return LucideIcons.alertTriangle; // التكبير عند رمي الجمار مع كل حصاة
      case 121: return LucideIcons.info; // دعاء التعجب والأمر السار
      case 122: return LucideIcons.smile; // ما يفعل من أتاه أمر يسره
      case 123: return LucideIcons.heartPulse; // ما يقول من أحس وجعا في جسده
      case 124: return LucideIcons.eye; // دعاء من خشي أن يصيب شيئا بعينه
      case 125: return LucideIcons.alertTriangle; // ما يقال عند الفزع
      case 126: return LucideIcons.utensils; // ما يقول عند الذبح أو النحر
      case 127: return LucideIcons.shield; // ما يقول لرد كيد مردة الشياطين
      case 128: return LucideIcons.scroll; // الاستغفار و التوبة
      case 129: return LucideIcons.sparkles; // التسبيح، التحميد، التهليل، التكبير
      case 130: return LucideIcons.scroll; // كيف كان النبي يسبح؟
      case 131: return LucideIcons.gift; // من أنواع الخير والآداب الجامعة
      case 132: return LucideIcons.bookOpen; // الرقية الشرعية من القرآن الكريم
      case 133: return LucideIcons.shield; // الرقية الشرعية من السنة النبوية
      case 134: return LucideIcons.moon; // من تعار من الليل
      case 135: return LucideIcons.helpCircle; // أماكن وأوقات إجابة الدعاء
      default: return LucideIcons.scroll;
    }
  }

  String _normalizeArabic(String text) {
    final diacritics = RegExp(r'[\u064B-\u0652\u0670]');
    var normalized = text.replaceAll(diacritics, '');
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll('ى', 'ي');
    return normalized.trim();
  }

  List<int> _mapNormalizedToOriginalIndices(String original, String normalized, int normStart, int normLength) {
    int origStart = -1;
    int origEnd = -1;
    int normIdx = 0;
    
    for (int i = 0; i < original.length; i++) {
      if (normIdx == normStart && origStart == -1) {
        origStart = i;
      }
      if (normIdx == normStart + normLength && origEnd == -1) {
        origEnd = i;
        break;
      }
      
      final char = original[i];
      final isDiacritic = RegExp(r'[\u064B-\u0652\u0670]').hasMatch(char);
      if (!isDiacritic) {
        normIdx++;
      }
    }
    
    if (origEnd == -1) origEnd = original.length;
    if (origStart == -1) origStart = 0;
    
    return [origStart, origEnd];
  }

  Widget _buildHighlightedText(String text, String query, TextStyle baseStyle, TextStyle highlightStyle) {
    if (query.isEmpty) return ArabicText(text, style: baseStyle, textAlign: TextAlign.right, textDirection: TextDirection.rtl);
    
    final normalizedText = _normalizeArabic(text);
    final normalizedQuery = _normalizeArabic(query);
    
    final matchIndex = normalizedText.indexOf(normalizedQuery);
    if (matchIndex == -1) {
      return ArabicText(text, style: baseStyle, textAlign: TextAlign.right, textDirection: TextDirection.rtl);
    }
    
    final originalIndices = _mapNormalizedToOriginalIndices(text, normalizedText, matchIndex, normalizedQuery.length);
    final origStart = originalIndices[0];
    final origEnd = originalIndices[1];
    
    return RichText(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: baseStyle,
        children: [
          if (origStart > 0)
            TextSpan(text: text.substring(0, origStart)),
          TextSpan(
            text: text.substring(origStart, origEnd),
            style: highlightStyle,
          ),
          if (origEnd < text.length)
            TextSpan(text: text.substring(origEnd)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<AdhkarCategory> allCategories, List<AdhkarItem> allItems, ThemeData theme) {
    if (_searchQuery.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: theme.disabledColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            ArabicText(
              'ابحث عن الأذكار أو التصنيفات...',
              style: GoogleFonts.cairo(fontSize: 16, color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    final query = _searchQuery.trim();
    final normQuery = _normalizeArabic(query);

    final filteredCategories = _selectedFilter == AdhkarSearchFilter.items
        ? <AdhkarCategory>[]
        : allCategories.where((cat) {
            return _normalizeArabic(cat.title).contains(normQuery) || 
                   _normalizeArabic(cat.description).contains(normQuery);
          }).toList();

    final filteredItems = _selectedFilter == AdhkarSearchFilter.categories
        ? <AdhkarItem>[]
        : allItems.where((item) {
            return _normalizeArabic(item.text).contains(normQuery) || 
                   _normalizeArabic(item.reference).contains(normQuery);
          }).toList();

    if (filteredCategories.isEmpty && filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: theme.disabledColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            ArabicText(
              'لم يتم العثور على أي نتائج لـ "$query"',
              style: GoogleFonts.cairo(fontSize: 16, color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        if (filteredCategories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: ArabicText(
              'الأقسام المطابقة (${filteredCategories.length})',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          ...filteredCategories.map((cat) {
            final catColor = _getCategoryColor(cat.id, theme);
            final catIcon = _getCategoryIcon(cat.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.dividerColor, width: 0.8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 20),
                ),
                title: _buildHighlightedText(
                  cat.title,
                  query,
                  GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface),
                  GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary, backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1)),
                ),
                subtitle: cat.description.isNotEmpty 
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: _buildHighlightedText(
                        cat.description,
                        query,
                        GoogleFonts.cairo(fontSize: 12, color: theme.disabledColor),
                        GoogleFonts.cairo(fontSize: 12, color: theme.colorScheme.primary, backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                    )
                  : null,
                trailing: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                onTap: () {
                  setState(() {
                    _isSearching = false;
                  });
                  _loadCategoryItems(cat);
                },
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
        if (filteredItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ArabicText(
              'الأذكار المطابقة (${filteredItems.length})',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          ...filteredItems.map((item) {
            final cat = allCategories.firstWhere((c) => c.id == item.categoryId, orElse: () => AdhkarCategory(id: 0, title: '', description: ''));
            final catColor = cat.id != 0 ? _getCategoryColor(cat.id, theme) : theme.colorScheme.primary;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.dividerColor, width: 0.8),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (cat.id != 0) {
                    setState(() {
                      _isSearching = false;
                    });
                    _loadCategoryItems(cat);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cat.title.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ArabicText(
                                cat.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      _buildHighlightedText(
                        item.text,
                        query,
                        GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.6,
                          color: theme.colorScheme.onSurface,
                        ),
                        GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.6,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      if (item.reference.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildHighlightedText(
                          'المصدر: ${item.reference}',
                          query,
                          GoogleFonts.cairo(
                            fontSize: 10,
                            color: theme.disabledColor,
                          ),
                          GoogleFonts.cairo(
                            fontSize: 10,
                            color: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(adhkarCategoriesListProvider);
    final allItemsAsync = ref.watch(adhkarAllItemsProvider);

    // If a category is selected, show its Adhkar items view
    if (_selectedCategory != null) {
      return _buildAdhkarItemsView(theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ابحث عن ذكر أو تصنيف...',
                  hintStyle: GoogleFonts.cairo(color: theme.disabledColor),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : ArabicText(
                'الأذكار اليومية',
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
                    _searchQuery = '';
                    _selectedFilter = AdhkarSearchFilter.all;
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            )
          else ...[
            PopupMenuButton<AdhkarSearchFilter>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: Icon(
                _selectedFilter == AdhkarSearchFilter.all
                    ? Icons.filter_list_rounded
                    : Icons.filter_alt_rounded,
              ),
              onSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: AdhkarSearchFilter.all,
                  child: Row(
                    children: [
                      Icon(
                        Icons.all_inclusive_rounded, 
                        size: 18, 
                        color: _selectedFilter == AdhkarSearchFilter.all ? theme.colorScheme.primary : theme.disabledColor,
                      ),
                      const SizedBox(width: 12),
                      ArabicText(
                        'البحث في الكل', 
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: _selectedFilter == AdhkarSearchFilter.all ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: AdhkarSearchFilter.categories,
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_rounded, 
                        size: 18, 
                        color: _selectedFilter == AdhkarSearchFilter.categories ? theme.colorScheme.primary : theme.disabledColor,
                      ),
                      const SizedBox(width: 12),
                      ArabicText(
                        'الأقسام فقط', 
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: _selectedFilter == AdhkarSearchFilter.categories ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: AdhkarSearchFilter.items,
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_rounded, 
                        size: 18, 
                        color: _selectedFilter == AdhkarSearchFilter.items ? theme.colorScheme.primary : theme.disabledColor,
                      ),
                      const SizedBox(width: 12),
                      ArabicText(
                        'الأذكار والأدعية فقط', 
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: _selectedFilter == AdhkarSearchFilter.items ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
          ],
        ],
      ),
      body: _isSearching
          ? categoriesAsync.when(
              data: (categories) => allItemsAsync.when(
                data: (allItems) => _buildSearchResults(categories, allItems, theme),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: ArabicText('خطأ في تحميل البيانات للبحث: $err')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: ArabicText('خطأ في تحميل الأذكار: $err')),
            )
          : categoriesAsync.when(
              data: (categories) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _adhkarGroups.length,
                itemBuilder: (context, index) {
                  final group = _adhkarGroups[index];
                  final groupCategories = categories.where((cat) => group.categoryIds.contains(cat.id)).toList();
                  
                  if (groupCategories.isEmpty) return const SizedBox.shrink();
                  
                  // Sort groupCategories to match the exact order of group.categoryIds
                  groupCategories.sort((a, b) => group.categoryIds.indexOf(a.id).compareTo(group.categoryIds.indexOf(b.id)));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.dividerColor, width: 0.8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent), // Removes ExpansionTile borders when expanded
                      child: ExpansionTile(
                        key: ValueKey('group_${index}_${_expandedGroupIndex == index}'),
                        initiallyExpanded: _expandedGroupIndex == index,
                        onExpansionChanged: (isExpanded) {
                          if (isExpanded) {
                            setState(() {
                              _expandedGroupIndex = index;
                            });
                          } else {
                            if (_expandedGroupIndex == index) {
                              setState(() {
                                _expandedGroupIndex = null;
                              });
                            }
                          }
                        },
                        backgroundColor: theme.colorScheme.surface,
                        collapsedBackgroundColor: theme.colorScheme.surface,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            group.icon,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: ArabicText(
                          group.title,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        children: groupCategories.map((cat) {
                          final catIcon = _getCategoryIconData(cat.id);
                          
                          return Column(
                            children: [
                              const Divider(height: 1),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.06),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    catIcon,
                                    color: theme.colorScheme.secondary,
                                    size: 18,
                                  ),
                                ),
                                title: ArabicText(
                                  cat.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: cat.description.isNotEmpty
                                    ? ArabicText(
                                        cat.description,
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: theme.disabledColor,
                                        ),
                                      )
                                    : null,
                                trailing: Icon(
                                  Directionality.of(context) == TextDirection.rtl
                                      ? Icons.arrow_back_ios
                                      : Icons.arrow_forward_ios,
                                  size: 12,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                ),
                                onTap: () => _loadCategoryItems(cat),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ).animate(delay: (50 * index).ms).fadeIn().slideY(begin: 0.08, end: 0);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: ArabicText('خطأ في تحميل الأذكار: $err')),
            ),
    );
  }

  Widget _buildOverallProgressCard(int completed, int total, ThemeData theme) {
    final percentage = total > 0 ? (completed / total * 100).toInt() : 0;
    final progress = total > 0 ? completed / total : 0.0;
    
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ArabicText(
                  'تقدمك اليومي',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ArabicText(
                    '$percentage%',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 12),
            ArabicText(
              'أتممت قراءة $completed من أصل $total من الأذكار في هذه المجموعة.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: -0.05, end: 0);
  }

  Widget _buildAdhkarItemsView(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          _selectedCategory!.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () {
            setState(() {
              _selectedCategory = null;
              _cachedCategoryItems = null;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: ArabicText('إعادة ضبط العدادات؟', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  content: ArabicText('سيتم تصفير جميع عدادات هذه المجموعة ليومك الحالي.', style: GoogleFonts.cairo()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: ArabicText('إلغاء', style: GoogleFonts.cairo()),
                    ),
                    TextButton(
                      onPressed: () {
                        _resetCategoryProgress();
                        Navigator.pop(context);
                      },
                      child: ArabicText('تصفير', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoadingCategory
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 160, 20, 20),
                    itemCount: _cachedCategoryItems?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = _cachedCategoryItems![index];
                      final progress = _itemsProgress[item.id] ?? 0;
                      final isCompleted = progress >= item.targetCount;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: isCompleted ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isCompleted ? theme.colorScheme.primary : theme.dividerColor,
                            width: isCompleted ? 1.5 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _incrementProgress(item),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArabicText(
                                  item.text,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    height: 1.7,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                if (item.reference.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ArabicText(
                                    'المصدر: ${item.reference}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                                const Divider(height: 24),
                                // Progress Indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (isCompleted)
                                          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20)
                                        else
                                          Icon(Icons.touch_app, color: theme.colorScheme.secondary, size: 20),
                                        const SizedBox(width: 8),
                                        ArabicText(
                                          isCompleted ? 'اكتمل الذكر' : 'اضغط للتكرار',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.copy_rounded, 
                                            color: isCompleted ? theme.colorScheme.primary.withValues(alpha: 0.6) : theme.colorScheme.secondary.withValues(alpha: 0.6), 
                                            size: 18
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: item.text));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: ArabicText(
                                                  'تم نسخ الذكر',
                                                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                                backgroundColor: theme.colorScheme.primary,
                                                duration: const Duration(milliseconds: 800),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                width: 150,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        // Counter Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.secondary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: ArabicText(
                                            '$progress / ${item.targetCount}',
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isCompleted ? Colors.white : theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Solid background container to mask scrolling items in the gap above the progress card
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Builder(
                    builder: (context) {
                      final total = _cachedCategoryItems?.length ?? 0;
                      final completed = _cachedCategoryItems?.where((item) => (_itemsProgress[item.id] ?? 0) >= item.targetCount).length ?? 0;
                      return _buildOverallProgressCard(completed, total, theme);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
