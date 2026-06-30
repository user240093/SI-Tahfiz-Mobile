import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'tu_home.dart';
import 'tu_spp_manager.dart';
import 'tu_data_santri.dart';

class TuDashboard extends StatefulWidget {
  const TuDashboard({super.key});

  @override
  State<TuDashboard> createState() => _TuDashboardState();
}

class _TuDashboardState extends State<TuDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TuHome(),
    const TuSppManager(),
    const TuDataSantri(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tata Usaha Panel'),
        backgroundColor: AppTheme.roleTuColor,
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
          ResponsiveNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda TU'),
          ResponsiveNavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments_rounded, label: 'Keuangan SPP'),
          ResponsiveNavItem(icon: Icons.folder_shared_outlined, activeIcon: Icons.folder_shared_rounded, label: 'Buku Induk'),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
