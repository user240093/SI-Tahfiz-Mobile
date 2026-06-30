import 'package:flutter/material.dart';
import '../theme.dart';

class ResponsiveLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile Layout (Bottom Nav)
          return Scaffold(
            body: mobileBody,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onIndexChanged,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
              destinations: navItems.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon, color: AppTheme.primaryColor),
                  label: item.label,
                );
              }).toList(),
            ),
          );
        } else {
          // Desktop Layout (Sidebar)
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1000,
                  backgroundColor: Colors.white,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onIndexChanged,
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryColor),
                  selectedLabelTextStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  elevation: 4,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Icon(Icons.menu_book_rounded, size: 48, color: AppTheme.primaryColor),
                  ),
                  destinations: navItems.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: Text(item.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
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
