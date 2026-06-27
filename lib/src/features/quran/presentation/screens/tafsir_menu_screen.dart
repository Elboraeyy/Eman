import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TafsirMenuScreen extends StatelessWidget {
  const TafsirMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final menuItems = [
      _TafsirCategoryData(
        title: "تفسير القرآن الكريم",
        description: "فهم مبسط وتفاسير معتمدة لآيات الذكر الحكيم تعينك على تدبر كتاب الله.",
        icon: Icons.menu_book,
        route: '/quran/tafsir/surahs',
      ),
      _TafsirCategoryData(
        title: "تفسير الأذكار اليومية",
        description: "افهم وتدبر ما تردده من أذكار الصباح والمساء لتكون أقرب إلى قلبك وجوارحك.",
        icon: Icons.favorite_border,
        route: '/adhkar',
      ),
      _TafsirCategoryData(
        title: "شروح الأحاديث النبوية",
        description: "شرح مبسط لمعاني الأحاديث النبوية الشريفة يوضح مقاصدها وغريب مفرداتها.",
        icon: Icons.auto_stories,
        route: '/hadith',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التفسير والمعاني',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'فهم وتدبر الآيات والأذكار يقرب معانيها إلى قلبك، لتعبد الله بطمأنينة ويقين.',
              style: GoogleFonts.cairo(
                fontSize: 15,
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ).animate().fade(duration: 500.ms),
            
            const SizedBox(height: 32),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  elevation: 0,
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                  ),
                  child: InkWell(
                    onTap: () => context.push(item.route),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.icon,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: (100 * index).ms).fade().slideY(begin: 0.1, end: 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TafsirCategoryData {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  _TafsirCategoryData({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}
