import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class ResponsiveLayout extends ConsumerWidget {
  final Widget mobileBody;
  final Widget? desktopBody;
  final int currentIndex;
  final Function(int) onIndexChanged;
  final List<ResponsiveNavItem> navItems;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.desktopBody,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final String name = authState?.name ?? 'Pengguna';
    final String roleBadge = authState?.role ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile Layout (Bottom Nav)
          return Scaffold(
            body: mobileBody,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor: Colors.transparent,
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      );
                    }
                    return GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onIndexChanged,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  destinations: navItems.map((item) {
                    final isSelected = navItems.indexOf(item) == currentIndex;
                    final color = isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280);
                    return NavigationDestination(
                      icon: Icon(item.icon, color: color),
                      selectedIcon: Icon(item.activeIcon, color: const Color(0xFF10B981)),
                      label: item.label,
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        } else {
          // Desktop Layout (Persistent Sidebar Drawer)
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 240,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drawer Header: Logo + Name + Role Badge
                      Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App Logo
                            Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, color: Color(0xFF10B981), size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'SI-Tahfiz',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // User Name
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                roleBadge,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: navItems.length,
                          itemBuilder: (context, index) {
                            final item = navItems[index];
                            final isSelected = index == currentIndex;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: InkWell(
                                onTap: () => onIndexChanged(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF059669) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? item.activeIcon : item.icon,
                                        color: isSelected ? Colors.white : const Color(0xFF111827),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected ? Colors.white : const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: desktopBody ?? mobileBody,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ResponsiveNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  ResponsiveNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
