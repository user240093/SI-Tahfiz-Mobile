import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/pengumuman_service.dart';
import 'screens/tu_akun_screen.dart';
import 'screens/tu_data_tabs_screen.dart';
import 'screens/tu_konfigurasi_screen.dart';
import 'screens/tu_sistem_tabs_screen.dart';

class TuDashboard extends ConsumerStatefulWidget {
  final int initialIndex;
  final int initialTab;
  const TuDashboard({super.key, this.initialIndex = 0, this.initialTab = 0});

  @override
  ConsumerState<TuDashboard> createState() => _TuDashboardState();
}

class _TuDashboardState extends ConsumerState<TuDashboard> {
  late int _currentIndex;
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentTab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null) {
        final userId = user.supabaseUser?.id ?? user.id;
        final userRole = user.roleString ?? 'tu';
        PengumumanService.checkAndShowPengumuman(context, userRole, userId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant TuDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex || oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _currentIndex = widget.initialIndex;
        _currentTab = widget.initialTab;
      });
    }
  }

  void _onNavigation(int index) {
    String route;
    switch (index) {
      case 0:
        route = '/tu/akun';
        break;
      case 1:
        route = '/tu/data/santri';
        break;
      case 2:
        route = '/tu/konfigurasi';
        break;
      case 3:
        route = '/tu/sistem/audit';
        break;
      default:
        route = '/tu/akun';
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const TuAkunScreen(),
      TuDataTabsScreen(initialTab: _currentTab),
      const TuKonfigurasiScreen(),
      TuSistemTabsScreen(initialTab: _currentTab),
    ];

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'tu',
        isNested: false,
      ),
      body: ResponsiveLayout(
        currentIndex: _currentIndex,
        onIndexChanged: _onNavigation,
        navItems: [
          ResponsiveNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people_rounded,
            label: 'Akun',
          ),
          ResponsiveNavItem(
            icon: Icons.folder_shared_outlined,
            activeIcon: Icons.folder_shared_rounded,
            label: 'Data',
          ),
          ResponsiveNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Konfigurasi',
          ),
          ResponsiveNavItem(
            icon: Icons.shield_outlined,
            activeIcon: Icons.shield_rounded,
            label: 'Sistem',
          ),
        ],
        mobileBody: pages[_currentIndex],
      ),
    );
  }
}

