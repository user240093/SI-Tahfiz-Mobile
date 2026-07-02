import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/pengumuman_service.dart';
import 'kepsek_home.dart';
import 'kepsek_kinerja.dart';

class KepsekDashboard extends ConsumerStatefulWidget {
  final int initialIndex;
  const KepsekDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<KepsekDashboard> createState() => _KepsekDashboardState();
}

class _KepsekDashboardState extends ConsumerState<KepsekDashboard> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const KepsekHome(),
    const KepsekKinerja(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null) {
        final userId = user.supabaseUser?.id ?? user.id;
        final userRole = user.roleString ?? 'kepsek';
        PengumumanService.checkAndShowPengumuman(context, userRole, userId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant KepsekDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onNavigation(int index) {
    String route = index == 0 ? '/kepsek/dashboard' : '/kepsek/rekap';
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'kepsek',
        isNested: false,
      ),
      body: ResponsiveLayout(
        currentIndex: _currentIndex,
        onIndexChanged: _onNavigation,
        navItems: [
          ResponsiveNavItem(
            icon: Icons.auto_graph_outlined,
            activeIcon: Icons.auto_graph_rounded,
            label: 'Dashboard',
          ),
          ResponsiveNavItem(
            icon: Icons.supervised_user_circle_outlined,
            activeIcon: Icons.supervised_user_circle_rounded,
            label: 'Rekap',
          ),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
