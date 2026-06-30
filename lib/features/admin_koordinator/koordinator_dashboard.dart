import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'koordinator_home.dart';
import 'koordinator_rekap.dart';
import 'koordinator_pengumuman.dart';
import 'koordinator_izin.dart';
import 'koordinator_tikrar.dart';

class KoordinatorDashboard extends StatefulWidget {
  const KoordinatorDashboard({super.key});

  @override
  State<KoordinatorDashboard> createState() => _KoordinatorDashboardState();
}

class _KoordinatorDashboardState extends State<KoordinatorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const KoordinatorHome(),
    const KoordinatorRekap(),
    const KoordinatorPengumuman(),
    const KoordinatorIzin(),
    const KoordinatorTikrar(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppTheme.roleKoordinatorColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              provider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: ResponsiveLayout(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        navItems: [
          ResponsiveNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
          ResponsiveNavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, label: 'Rekap Nilai'),
          ResponsiveNavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'Pengumuman'),
          ResponsiveNavItem(icon: Icons.mark_email_unread_outlined, activeIcon: Icons.mark_email_read_rounded, label: 'Izin Santri'),
          ResponsiveNavItem(icon: Icons.warning_amber_rounded, activeIcon: Icons.warning_rounded, label: 'Tikrar'),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
