import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'tu_home.dart';
import 'tu_data_santri.dart';

class TuDashboard extends ConsumerStatefulWidget {
  final int initialIndex;
  const TuDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<TuDashboard> createState() => _TuDashboardState();
}

class _TuDashboardState extends ConsumerState<TuDashboard> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const TuHome(),
    const TuDataSantri(),
    const Center(child: Text('Panel Konfigurasi Sistem (Placeholder)')),
    const Center(child: Text('Panel Audit Trail (Placeholder)')),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant TuDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
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
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
