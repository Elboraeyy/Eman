import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zad/src/features/quran/presentation/controllers/audio_player_controller.dart';
import 'package:zad/src/features/quran/presentation/screens/quran_index_screen.dart'; // Reuses surahsListProvider
import 'package:zad/src/features/home/presentation/controllers/audios_controller.dart';

class AudiosScreen extends ConsumerStatefulWidget {
  const AudiosScreen({super.key});

  @override
  ConsumerState<AudiosScreen> createState() => _AudiosScreenState();
}

class _AudiosScreenState extends ConsumerState<AudiosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic _selectedReciter; // Can be static Reciter or ReciterApi
  PodcastChannel? _selectedPodcast;
  
  final TextEditingController _quranSearchController = TextEditingController();
  final TextEditingController _radioSearchController = TextEditingController();
  final TextEditingController _podcastSearchController = TextEditingController();

  String _quranSearchQuery = '';
  String _radioSearchQuery = '';
  String _podcastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quranSearchController.dispose();
    _radioSearchController.dispose();
    _podcastSearchController.dispose();
    super.dispose();
  }

  bool _isBackArrowVisible() {
    return _selectedReciter != null || _selectedPodcast != null;
  }

  void _handleBackAction() {
    setState(() {
      if (_selectedReciter != null) {
        _selectedReciter = null;
        _quranSearchQuery = '';
        _quranSearchController.clear();
      } else if (_selectedPodcast != null) {
        _selectedPodcast = null;
        _podcastSearchQuery = '';
        _podcastSearchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playbackState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
          onPressed: () {
            if (_isBackArrowVisible()) {
              _handleBackAction();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _selectedReciter != null
              ? (_selectedReciter is Reciter ? _selectedReciter.nameArabic : _selectedReciter.name)
              : (_selectedPodcast != null ? _selectedPodcast!.title : 'الصوتيات الإسلامية'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        bottom: !_isBackArrowVisible()
            ? TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.secondary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'القرآن الكريم'),
                  Tab(text: 'الإذاعة المباشرة'),
                  Tab(text: 'البودكاست'),
                ],
              )
            : null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: !_isBackArrowVisible() ? 8.0 : 0.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: _isBackArrowVisible()
                      ? (_selectedReciter != null
                          ? _buildSurahsList(theme, _selectedReciter!)
                          : _buildPodcastEpisodesList(theme, _selectedPodcast!))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildQuranTab(theme),
                            _buildRadioTab(theme),
                            _buildPodcastTab(theme),
                          ],
                        ),
                ),
                
                // Spacer if the persistent mini player is visible
                if (playbackState.isPlaying || playbackState.isLoading || playbackState.position > Duration.zero)
                  const SizedBox(height: 80),
              ],
            ),
          ),

          // Mini Player
          if (playbackState.isPlaying || playbackState.isLoading || playbackState.position > Duration.zero)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: _MiniPlayer(
                playbackState: playbackState,
                onTap: () => _showNowPlayingOverlay(context, playbackState),
              ),
            ),
        ],
      ),
    );
  }

  // --- Quran Reciters Tab ---

  Widget _buildQuranTab(ThemeData theme) {
    final recitersAsync = ref.watch(recitersApiProvider);

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: TextField(
            controller: _quranSearchController,
            onChanged: (val) {
              setState(() {
                _quranSearchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن قارئ...',
              prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              suffixIcon: _quranSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _quranSearchController.clear();
                        setState(() {
                          _quranSearchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // List of Reciters
        Expanded(
          child: recitersAsync.when(
            data: (apiReciters) {
              // Filter API list by query
              final filteredApi = apiReciters.where((r) => r.name.contains(_quranSearchQuery)).toList();
              
              // Filter static ones by query
              final filteredStatic = staticReciters.where((r) => r.nameArabic.contains(_quranSearchQuery)).toList();

              if (filteredStatic.isEmpty && filteredApi.isEmpty) {
                return Center(
                  child: Text(
                    'لم يتم العثور على قارئ.',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: filteredStatic.length + filteredApi.length,
                itemBuilder: (context, index) {
                  final isStatic = index < filteredStatic.length;
                  final dynamic reciter = isStatic 
                      ? filteredStatic[index] 
                      : filteredApi[index - filteredStatic.length];

                  final String name = isStatic ? reciter.nameArabic : reciter.name;
                  final String info = isStatic ? 'قارئ رئيسي • ${reciter.nameEnglish}' : reciter.rewaya;
                  final initials = name.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join(' ');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08), width: 1),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedReciter = reciter;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            // Calligraphy Gradient Initials
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isStatic 
                                      ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                                      : [theme.colorScheme.primary.withValues(alpha: 0.75), theme.colorScheme.primary.withValues(alpha: 0.4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    info,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (15 * index).ms).fadeIn().slideY(begin: 0.04, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'خطأ في تحميل القراء: تأكد من اتصال الإنترنت.',
                style: GoogleFonts.cairo(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahsList(ThemeData theme, dynamic reciter) {
    final surahsAsync = ref.watch(surahsListProvider);
    final String reciterId = reciter is Reciter ? reciter.id : 'api_${reciter.id}';
    final String reciterName = reciter is Reciter ? reciter.nameArabic : reciter.name;
    final String serverUrl = reciter is Reciter ? (reciter.surahServer ?? reciter.server) : reciter.server;
    final List<int>? allowedSurahs = reciter is ReciterApi ? reciter.surahList : null;

    return Column(
      children: [
        // Search Box inside Surahs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: TextField(
            controller: _quranSearchController,
            onChanged: (val) {
              setState(() {
                _quranSearchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة للقارئ...',
              prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              suffixIcon: _quranSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _quranSearchController.clear();
                        setState(() {
                          _quranSearchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        Expanded(
          child: surahsAsync.when(
            data: (allSurahs) {
              // Filter by both allowedSurahs list (from API) and search query
              final filtered = allSurahs.where((s) {
                final matchesSearch = s.nameArabic.contains(_quranSearchQuery);
                final matchesAllowed = allowedSurahs == null || allowedSurahs.contains(s.number);
                return matchesSearch && matchesAllowed;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد سور متوفرة بصوت هذا القارئ.',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final surah = filtered[index];
                  final playerState = ref.watch(audioPlayerProvider);
                  
                  // Check if this specific surah and reciter is currently playing
                  final bool isCurrentlyPlaying = (playerState.currentSurah == surah.number && playerState.activeReciterId == reciterId) ||
                      (playerState.currentSurah == -1 && playerState.customSubtitle == reciterName && playerState.customTitle == 'سورة ${surah.nameArabic}');

                  final surahMp3Url = '$serverUrl${surah.number.toString().padLeft(3, '0')}.mp3';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: isCurrentlyPlaying
                        ? theme.colorScheme.secondary.withValues(alpha: 0.06)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isCurrentlyPlaying
                            ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                            : theme.dividerColor.withValues(alpha: 0.08),
                        width: 1.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (isCurrentlyPlaying) {
                          if (playerState.isPlaying) {
                            ref.read(audioPlayerProvider.notifier).pause();
                          } else {
                            ref.read(audioPlayerProvider.notifier).resume();
                          }
                        } else {
                          if (reciter is Reciter) {
                            ref.read(audioPlayerProvider.notifier).playSurah(reciter.id, surah.number);
                          } else {
                            ref.read(audioPlayerProvider.notifier).playUrl(
                              surahMp3Url,
                              title: 'سورة ${surah.nameArabic}',
                              subtitle: reciterName,
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: Text(
                                  surah.number.toString(),
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah.nameArabic,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'آياتها ${surah.numberOfAyahs} • ${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrentlyPlaying
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(alpha: 0.06),
                              ),
                              child: Icon(
                                isCurrentlyPlaying && playerState.isPlaying
                                    ? LucideIcons.pause
                                    : LucideIcons.play,
                                size: 14,
                                color: isCurrentlyPlaying ? Colors.white : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (15 * index).ms).fadeIn().slideY(begin: 0.04, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('خطأ في جلب السور: $err')),
          ),
        ),
      ],
    );
  }

  // --- Live Radio Tab ---

  Widget _buildRadioTab(ThemeData theme) {
    final radiosAsync = ref.watch(radiosApiProvider);

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: TextField(
            controller: _radioSearchController,
            onChanged: (val) {
              setState(() {
                _radioSearchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن إذاعة قرآن...',
              prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              suffixIcon: _radioSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _radioSearchController.clear();
                        setState(() {
                          _radioSearchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        Expanded(
          child: radiosAsync.when(
            data: (stations) {
              final filtered = stations.where((s) => s.name.contains(_radioSearchQuery)).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد إذاعة تطابق البحث.',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final station = filtered[index];
                  final playerState = ref.watch(audioPlayerProvider);
                  final bool isPlayingThis = playerState.isPlaying && playerState.isLiveStream && playerState.customTitle == station.name;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: isPlayingThis 
                        ? theme.colorScheme.primary.withValues(alpha: 0.05) 
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isPlayingThis 
                            ? theme.colorScheme.primary.withValues(alpha: 0.3) 
                            : theme.dividerColor.withValues(alpha: 0.08),
                        width: 1.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (isPlayingThis) {
                          ref.read(audioPlayerProvider.notifier).pause();
                        } else {
                          ref.read(audioPlayerProvider.notifier).playUrl(
                            station.url,
                            title: station.name,
                            subtitle: 'إذاعة القرآن الكريم (بث حي)',
                            isLiveStream: true,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Radio Icon or Pulse wave
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPlayingThis 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.primary.withValues(alpha: 0.06),
                              ),
                              child: Icon(
                                LucideIcons.radio,
                                size: 18,
                                color: isPlayingThis ? Colors.white : theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isPlayingThis ? theme.colorScheme.secondary : Colors.grey,
                                        ),
                                      ).animate(target: isPlayingThis ? 1 : 0).fade(duration: 800.ms).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.1, 1.1)),
                                      const SizedBox(width: 6),
                                      Text(
                                        isPlayingThis ? 'جاري التشغيل مباشرة' : 'بث مباشر',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: isPlayingThis ? theme.colorScheme.secondary : Colors.grey,
                                          fontWeight: isPlayingThis ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              isPlayingThis ? LucideIcons.pause : LucideIcons.play,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (15 * index).ms).fadeIn().slideY(begin: 0.04, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'خطأ في تحميل الإذاعات: تأكد من اتصال الإنترنت.',
                style: GoogleFonts.cairo(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Podcasts Tab ---

  Widget _buildPodcastTab(ThemeData theme) {
    final podcastsAsync = ref.watch(podcastsProvider);

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: TextField(
            controller: _podcastSearchController,
            onChanged: (val) {
              setState(() {
                _podcastSearchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن بودكاست...',
              prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              suffixIcon: _podcastSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _podcastSearchController.clear();
                        setState(() {
                          _podcastSearchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        Expanded(
          child: podcastsAsync.when(
            data: (channels) {
              final filtered = channels.where((c) => c.title.contains(_podcastSearchQuery) || c.publisher.contains(_podcastSearchQuery)).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'لم يتم العثور على بودكاست.',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final channel = filtered[index];

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08), width: 1),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPodcast = channel;
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Cover Image Placeholder (Islamic pattern gradient)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [theme.colorScheme.primary.withValues(alpha: 0.8), theme.colorScheme.secondary.withValues(alpha: 0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.headphones,
                                    size: 32,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              channel.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              channel.publisher,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (20 * index).ms).fadeIn().scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('خطأ في جلب البودكاست: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildPodcastEpisodesList(ThemeData theme, PodcastChannel channel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Podcast Header Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.title,
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 2),
              Text(
                'الناشر: ${channel.publisher}',
                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: 6),
              Text(
                channel.description,
                style: GoogleFonts.cairo(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8), height: 1.5),
              ),
            ],
          ),
        ),

        // Search episodes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: TextField(
            controller: _podcastSearchController,
            onChanged: (val) {
              setState(() {
                _podcastSearchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن حلقة...',
              prefixIcon: Icon(LucideIcons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              suffixIcon: _podcastSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _podcastSearchController.clear();
                        setState(() {
                          _podcastSearchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        Expanded(
          child: Builder(
            builder: (context) {
              final episodes = channel.episodes.where((e) => e.title.contains(_podcastSearchQuery)).toList();

              if (episodes.isEmpty) {
                return Center(
                  child: Text(
                    'لم يتم العثور على حلقات.',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
                  final playerState = ref.watch(audioPlayerProvider);
                  final bool isPlayingThis = playerState.isPlaying && playerState.customTitle == episode.title;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: isPlayingThis 
                        ? theme.colorScheme.secondary.withValues(alpha: 0.05) 
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isPlayingThis 
                            ? theme.colorScheme.secondary.withValues(alpha: 0.3) 
                            : theme.dividerColor.withValues(alpha: 0.08),
                        width: 1.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (isPlayingThis) {
                          ref.read(audioPlayerProvider.notifier).pause();
                        } else {
                          ref.read(audioPlayerProvider.notifier).playUrl(
                            episode.url,
                            title: episode.title,
                            subtitle: channel.title,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPlayingThis 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.primary.withValues(alpha: 0.06),
                              ),
                              child: Icon(
                                isPlayingThis ? LucideIcons.pause : LucideIcons.play,
                                size: 14,
                                color: isPlayingThis ? Colors.white : theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    episode.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'المدة: ${episode.duration} • تاريخ النشر: ${episode.pubDate}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: (15 * index).ms).fadeIn().slideY(begin: 0.04, end: 0);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNowPlayingOverlay(BuildContext context, AudioPlaybackState state) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'NowPlaying',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return _NowPlayingOverlay(playbackState: state);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

class _MiniPlayer extends ConsumerWidget {
  final AudioPlaybackState playbackState;
  final VoidCallback onTap;

  const _MiniPlayer({
    required this.playbackState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = playbackState.duration.inMilliseconds > 0
        ? playbackState.position.inMilliseconds / playbackState.duration.inMilliseconds
        : 0.0;

    String title = 'صوتيات...';
    String subtitle = 'جاري التحميل...';

    if (playbackState.currentSurah > 0) {
      // Standard Surah from static reciters
      final reciter = staticReciters.firstWhere((r) => r.id == playbackState.activeReciterId, orElse: () => staticReciters.first);
      subtitle = reciter.nameArabic;
      final surahsAsync = ref.watch(surahsListProvider);
      surahsAsync.whenData((list) {
        final match = list.firstWhere((s) => s.number == playbackState.currentSurah, orElse: () => list.first);
        title = 'سورة ${match.nameArabic}';
      });
    } else {
      // Custom stream/url (Radio, Podcast, or API Surah)
      title = playbackState.customTitle ?? 'بث صوتي';
      subtitle = playbackState.customSubtitle ?? 'زاد المسلم';
    }

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Top Progress line (only show for seekable items, hide for live streams)
                if (!playbackState.isLiveStream)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 2.5,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                    ),
                  ),
                // Contents
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Loading indicator or play/pause button
                      if (playbackState.isLoading)
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            if (playbackState.isPlaying) {
                              ref.read(audioPlayerProvider.notifier).pause();
                            } else {
                              ref.read(audioPlayerProvider.notifier).resume();
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              playbackState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 14),

                      // Text details
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Close button to stop playback
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        color: Colors.grey.shade600,
                        onPressed: () {
                          ref.read(audioPlayerProvider.notifier).stop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 250.ms).fade();
  }
}

class _NowPlayingOverlay extends ConsumerStatefulWidget {
  final AudioPlaybackState playbackState;

  const _NowPlayingOverlay({
    required this.playbackState,
  });

  @override
  ConsumerState<_NowPlayingOverlay> createState() => _NowPlayingOverlayState();
}

class _NowPlayingOverlayState extends ConsumerState<_NowPlayingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    if (widget.playbackState.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _NowPlayingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final playbackState = ref.read(audioPlayerProvider);
    if (playbackState.isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerState = ref.watch(audioPlayerProvider);
    
    final progress = playerState.duration.inMilliseconds > 0
        ? playerState.position.inMilliseconds / playerState.duration.inMilliseconds
        : 0.0;

    String title = 'صوتيات...';
    String subtitle = 'جاري التحميل...';

    if (playerState.currentSurah > 0) {
      final reciter = staticReciters.firstWhere((r) => r.id == playerState.activeReciterId, orElse: () => staticReciters.first);
      subtitle = reciter.nameArabic;
      final surahsAsync = ref.watch(surahsListProvider);
      surahsAsync.whenData((list) {
        final match = list.firstWhere((s) => s.number == playerState.currentSurah, orElse: () => list.first);
        title = 'سورة ${match.nameArabic}';
      });
    } else {
      title = playerState.customTitle ?? 'بث صوتي';
      subtitle = playerState.customSubtitle ?? 'زاد المسلم';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm cream background
      body: SafeArea(
        child: Column(
          children: [
            // Header (Dismiss arrow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down, size: 28, color: theme.colorScheme.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'شاشة الاستماع',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rotating Disc Calligraphy Centerpiece
                    Center(
                      child: RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Icon(
                                playerState.isLiveStream ? LucideIcons.radio : LucideIcons.headphones,
                                size: 80,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Titles
                    Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Slider (Only show if not a live stream)
                    if (!playerState.isLiveStream)
                      Column(
                        children: [
                          Slider(
                            value: progress.clamp(0.0, 1.0),
                            activeColor: theme.colorScheme.secondary,
                            inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            onChanged: (val) {
                              final seekPos = Duration(milliseconds: (val * playerState.duration.inMilliseconds).toInt());
                              ref.read(audioPlayerProvider.notifier).seek(seekPos);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(playerState.position),
                                  style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                Text(
                                  _formatDuration(playerState.duration),
                                  style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // Live Pulsing Dot Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms),
                            const SizedBox(width: 8),
                            Text(
                              'بث حي مباشر',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Speed controller (Only for seekable content)
                        if (!playerState.isLiveStream)
                          PopupMenuButton<double>(
                            icon: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                '${playerState.playbackSpeed}x',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            onSelected: (speed) {
                              ref.read(audioPlayerProvider.notifier).setSpeed(speed);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                              const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                              const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                              const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                              const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                            ],
                          )
                        else
                          const SizedBox(width: 48), // Keep layout balanced

                        // Back / Previous (Only for Surahs)
                        if (playerState.currentSurah > 0)
                          IconButton(
                            icon: Icon(Icons.skip_next, size: 36, color: theme.colorScheme.primary),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref.read(audioPlayerProvider.notifier).previous();
                            },
                          )
                        else
                          const SizedBox(width: 36),

                        // Play/Pause Big Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if (playerState.isPlaying) {
                              ref.read(audioPlayerProvider.notifier).pause();
                            } else {
                              ref.read(audioPlayerProvider.notifier).resume();
                            }
                          },
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              playerState.isPlaying ? LucideIcons.pause : LucideIcons.play,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Next Surah (Only for Surahs)
                        if (playerState.currentSurah > 0)
                          IconButton(
                            icon: Icon(Icons.skip_previous, size: 36, color: theme.colorScheme.primary),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref.read(audioPlayerProvider.notifier).next();
                            },
                          )
                        else
                          const SizedBox(width: 36),

                        // Stop/Close button
                        IconButton(
                          icon: Icon(LucideIcons.square, size: 20, color: Colors.grey.shade600),
                          onPressed: () {
                            ref.read(audioPlayerProvider.notifier).stop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
