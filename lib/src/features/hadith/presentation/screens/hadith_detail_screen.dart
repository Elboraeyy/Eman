import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/repositories/hadith_repository_provider.dart';
import '../../domain/entities/hadith_entities.dart';
import 'hadith_index_screen.dart';
import 'package:iman/src/core/widgets/arabic_text.dart';

final hadithDetailProvider = FutureProvider.family<Hadith?, int>((ref, hadithId) async {
  final repo = ref.watch(hadithRepositoryProvider);
  return await repo.getHadithById(hadithId);
});


class HadithDetailScreen extends ConsumerStatefulWidget {
  final int hadithId;
  const HadithDetailScreen({super.key, required this.hadithId});

  @override
  ConsumerState<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends ConsumerState<HadithDetailScreen> {
  bool _isSourceExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hadithAsync = ref.watch(hadithDetailProvider(widget.hadithId));
    final isBookmarkedAsync = ref.watch(isHadithBookmarkedProvider(widget.hadithId));

    return Scaffold(
      appBar: AppBar(
        title: ArabicText(
          'شرح الحديث',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          isBookmarkedAsync.when(
            data: (isBookmarked) => IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? theme.colorScheme.secondary : theme.colorScheme.onSurface,
                size: 22,
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final repo = ref.read(hadithRepositoryProvider);
                await repo.toggleBookmark(widget.hadithId);
                ref.invalidate(isHadithBookmarkedProvider(widget.hadithId));
                ref.invalidate(bookmarkedHadithsProvider);
                ref.invalidate(filteredHadithsProvider);
              },
            ),
            loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, stack) => const SizedBox(),
          ),
          IconButton(
            icon: Icon(LucideIcons.share, color: theme.colorScheme.onSurface, size: 20),
            onPressed: () {
              final hadith = hadithAsync.value;
              if (hadith != null) {
                final shareText = 'قال رسول الله ﷺ:\n'
                    '« ${hadith.text} »\n\n'
                    'الراوي: ${hadith.narrator}\n'
                    'المصدر: ${hadith.source}\n\n'
                    'تمت المشاركة من تطبيق إيمان';
                SharePlus.instance.share(ShareParams(text: shareText));
              }
            },
          ),
        ],
      ),
      body: hadithAsync.when(
        data: (hadith) {
          if (hadith == null) {
            return Center(
              child: ArabicText(
                'الحديث غير موجود.',
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Main Hadith Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: theme.dividerColor, width: 0.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ArabicText(
                          hadith.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            height: 1.8,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3B1E1E), // Deep brown color
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ArabicText(
                                    'عن: ${hadith.narrator.isNotEmpty ? hadith.narrator : "غير متوفر"}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isSourceExpanded = !_isSourceExpanded;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Row(
                                      children: [
                                        ArabicText(
                                          'المصادر',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isSourceExpanded 
                                              ? LucideIcons.chevronUp 
                                              : LucideIcons.chevronDown,
                                          color: theme.colorScheme.secondary,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_isSourceExpanded) ...[
                              const SizedBox(height: 12),
                              ArabicText(
                                hadith.source,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade().slideY(begin: 0.05, end: 0),

                const SizedBox(height: 20),

                // 2. Explanation Section
                DetailSection(
                  title: 'شرح وتفسير الحديث',
                  icon: LucideIcons.bookOpen,
                  content: ArabicText(
                    hadith.explanation.isNotEmpty ? hadith.explanation : 'لا يتوفر شرح حالياً للحديث.',
                    style: GoogleFonts.cairo(
                      fontSize: 14, 
                      height: 1.6,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ).animate().fade(delay: 100.ms),

                const SizedBox(height: 20),

                // 3. Vocabulary Section
                if (hadith.vocabulary.isNotEmpty) ...[
                  DetailSection(
                    title: 'معاني الكلمات',
                    icon: LucideIcons.info,
                    content: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: hadith.vocabulary.length,
                      itemBuilder: (context, idx) {
                        final vocab = hadith.vocabulary[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor, width: 0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ArabicText(
                                vocab.word,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ArabicText(
                                  vocab.translation,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13, 
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                  textAlign: TextAlign.right, // Align meaning to the right next to the word in RTL
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ).animate().fade(delay: 200.ms),
                  const SizedBox(height: 20),
                ],

                // 4. Life Applications Section
                if (hadith.lifeApplications.isNotEmpty) ...[
                  DetailSection(
                    title: 'الدروس والتطبيق الحياتي',
                    icon: LucideIcons.sparkles,
                    content: Column(
                      children: hadith.lifeApplications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final app = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                ),
                                alignment: Alignment.center,
                                child: ArabicText(
                                  '${index + 1}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ArabicText(
                                  app,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13, 
                                    height: 1.6,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fade(delay: 300.ms),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: ArabicText('حدث خطأ أثناء تحميل الحديث: $err')),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const DetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                ArabicText(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
