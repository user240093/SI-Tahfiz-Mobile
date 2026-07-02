import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/pengumuman_service.dart';
import '../pengampu/screens/pengampu_setoran_screen.dart';
import '../pengampu/screens/pengampu_absensi_screen.dart';
import 'murobbi_beranda.dart';
import 'murobbi_lainnya_grid.dart';

class MurobbiDashboard extends ConsumerStatefulWidget {
  final int initialIndex;
  const MurobbiDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MurobbiDashboard> createState() => _MurobbiDashboardState();
}

class _MurobbiDashboardState extends ConsumerState<MurobbiDashboard> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const MurobbiBeranda(),
    const PengampuSetoranScreen(),
    const PengampuAbsensiScreen(),
    const MurobbiLainnyaGrid(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null) {
        final userId = user.supabaseUser?.id ?? user.id;
        final userRole = user.roleString ?? 'pengampu';
        PengumumanService.checkAndShowPengumuman(context, userRole, userId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MurobbiDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onNavigation(int index) {
    if (index == 3) {
      setState(() {
        _currentIndex = 3;
      });
      return;
    }

    String route;
    switch (index) {
      case 0:
        route = '/pengampu/beranda';
        break;
      case 1:
        route = '/pengampu/setoran';
        break;
      case 2:
        route = '/pengampu/absensi';
        break;
      default:
        route = '/pengampu/beranda';
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'pengampu',
        isNested: false,
      ),
      body: ResponsiveLayout(
        currentIndex: _currentIndex,
        onIndexChanged: _onNavigation,
        navItems: [
          ResponsiveNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Beranda',
          ),
          ResponsiveNavItem(
            icon: Icons.assignment_turned_in_outlined,
            activeIcon: Icons.assignment_turned_in_rounded,
            label: 'Setoran',
          ),
          ResponsiveNavItem(
            icon: Icons.co_present_outlined,
            activeIcon: Icons.co_present_rounded,
            label: 'Absensi',
          ),
          ResponsiveNavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'Lainnya',
          ),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
