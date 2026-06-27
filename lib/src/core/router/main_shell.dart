import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final path = state.uri.path;
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

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: child,
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
            Text(
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
