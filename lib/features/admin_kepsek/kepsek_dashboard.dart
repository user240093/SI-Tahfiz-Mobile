import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'kepsek_home.dart';
import 'kepsek_kinerja.dart';
import 'kepsek_approval.dart';

class KepsekDashboard extends StatefulWidget {
  const KepsekDashboard({super.key});

  @override
  State<KepsekDashboard> createState() => _KepsekDashboardState();
}

class _KepsekDashboardState extends State<KepsekDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const KepsekHome(),
    const KepsekKinerja(),
    const KepsekApproval(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Panel - Kepala Sekolah'),
        backgroundColor: Colors.purple.shade800, // Khusus untuk kepsek
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
          ResponsiveNavItem(icon: Icons.auto_graph_outlined, activeIcon: Icons.auto_graph_rounded, label: 'Executive Home'),
          ResponsiveNavItem(icon: Icons.supervised_user_circle_outlined, activeIcon: Icons.supervised_user_circle_rounded, label: 'Kinerja Murobbi'),
          ResponsiveNavItem(icon: Icons.verified_outlined, activeIcon: Icons.verified_rounded, label: 'Approval UKJ'),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
