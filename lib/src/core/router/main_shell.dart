import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zad/src/core/widgets/arabic_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zad/src/features/quran/presentation/controllers/audio_player_controller.dart';
import 'package:zad/src/features/quran/presentation/screens/quran_index_screen.dart'; // for surahsListProvider
import 'package:zad/src/features/home/presentation/screens/audios_screen.dart'; // for NowPlayingOverlay

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openNowPlaying(BuildContext context, AudioPlaybackState stateVal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      enableDrag: true,
      isDismissible: true,
      builder: (context) => NowPlayingOverlay(playbackState: stateVal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.state.uri.path;
    final theme = Theme.of(context);
    
    // Resolve active tab index
    int selectedIndex = 2; // Default to Home
    if (path.startsWith('/settings')) {
      selectedIndex = 0;
    } else if (path.startsWith('/tracker/stats')) {
      selectedIndex = 1;
    } else if (path.startsWith('/home')) {
      selectedIndex = 2;
    } else if (path.startsWith('/tracker/tasks')) {
      selectedIndex = 3;
    } else if (path.startsWith('/quran')) {
      selectedIndex = 4;
    }

    final playbackState = ref.watch(audioPlayerProvider);
    final hasAudio = playbackState.currentSurah != 0 || playbackState.customTitle != null;

    String title = 'صوتيات...';
    String subtitle = 'جاري التحميل...';

    if (playbackState.currentSurah > 0) {
      final reciter = staticReciters.firstWhere((r) => r.id == playbackState.activeReciterId, orElse: () => staticReciters.first);
      subtitle = reciter.nameArabic;
      final surahsAsync = ref.watch(surahsListProvider);
      surahsAsync.whenData((list) {
        final match = list.firstWhere((s) => s.number == playbackState.currentSurah, orElse: () => list.first);
        title = 'سورة ${match.nameArabic}';
      });
    } else {
      title = playbackState.customTitle ?? 'بث صوتي';
      subtitle = playbackState.customSubtitle ?? 'زاد المسلم';
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.child,
          ),
          
          // Floating Audio Widget
          if (hasAudio)
            Positioned(
              left: 24,
              bottom: 96 + MediaQuery.of(context).padding.bottom,
              child: GestureDetector(
                onTap: () {
                  if (!_isExpanded) {
                    setState(() {
                      _isExpanded = true;
                    });
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, childWidget) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.fastOutSlowIn,
                      clipBehavior: Clip.antiAlias,
                      width: _isExpanded ? MediaQuery.of(context).size.width - 48 : 52,
                      height: _isExpanded ? 64 : 52,
                      decoration: BoxDecoration(
                        color: _isExpanded ? Colors.white : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(_isExpanded ? 20 : 26),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: _isExpanded ? 0.08 : (0.25 + _pulseController.value * 0.15)
                            ),
                            blurRadius: _isExpanded ? 12 : (8 + _pulseController.value * 6),
                            spreadRadius: _isExpanded ? 0 : (_pulseController.value * 2),
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: _isExpanded ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: _isExpanded
                          ? _buildExpandedMiniPlayer(theme, playbackState, title, subtitle)
                          : _buildCollapsedBubble(playbackState),
                    );
                  },
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: const Color(0xFFFAF8F5), // Restored Background Color as Border
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. Mushaf (المصحف)
                    _buildNavItem(
                      index: 4,
                      icon: 'assets/Icon/quran-rehal-svgrepo-com.svg',
                      activeIcon: 'assets/Icon/quran-rehal-svgrepo-com.svg',
                      label: 'المصحف',
                      selectedIndex: selectedIndex,
                      context: context,
                      route: '/quran',
                    ),

                    // 2. Tasks (المهام)
                    _buildNavItem(
                      index: 3,
                      icon: Icons.check_circle_outline,
                      activeIcon: Icons.check_circle,
                      label: 'المهام',
                      selectedIndex: selectedIndex,
                      context: context,
                      route: '/tracker/tasks',
                    ),

                    // 3. Home (الرئيسية) - Raised Circular Button
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Transform.translate(
                        offset: const Offset(0, -16), // Raised effect
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary, // Emerald Green
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.secondary, // Muted Gold
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 4. Statistics (الإحصائيات)
                    _buildNavItem(
                      index: 1,
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: 'الإحصائيات',
                      selectedIndex: selectedIndex,
                      context: context,
                      route: '/tracker/stats',
                    ),

                    // 5. Settings (إعدادات)
                    _buildNavItem(
                      index: 0,
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'إعدادات',
                      selectedIndex: selectedIndex,
                      context: context,
                      route: '/settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedBubble(AudioPlaybackState playbackState) {
    return Center(
      child: playbackState.isPlaying
          ? const Icon(
              LucideIcons.headphones,
              color: Colors.white,
              size: 22,
            )
          : const Icon(
              LucideIcons.play,
              color: Colors.white,
              size: 22,
            ),
    );
  }

  Widget _buildExpandedMiniPlayer(ThemeData theme, AudioPlaybackState playbackState, String title, String subtitle) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 48,
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 12),
            // Play/Pause button
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
            const SizedBox(width: 12),
            // Title & Artist
            Expanded(
              child: GestureDetector(
                onTap: () => _openNowPlaying(context, playbackState),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    ArabicText(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Collapse button on the far left
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required dynamic icon,
    required dynamic activeIcon,
    required String label,
    required int selectedIndex,
    required BuildContext context,
    required String route,
  }) {
    final theme = Theme.of(context);
    final isActive = selectedIndex == index;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = const Color(0xFF7D5852); // Medium Brown Text

    Widget buildIconWidget() {
      final targetIcon = isActive ? activeIcon : icon;
      final color = isActive ? activeColor : inactiveColor;
      
      if (targetIcon is IconData) {
        return Icon(
          targetIcon,
          color: color,
          size: 22,
        );
      } else if (targetIcon is String) {
        return SvgPicture.asset(
          targetIcon,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      }
      return const SizedBox(width: 22, height: 22);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildIconWidget(),
            const SizedBox(height: 3),
            ArabicText(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
