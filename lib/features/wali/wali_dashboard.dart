import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'wali_home.dart';
import 'wali_chat_list.dart';
import 'wali_izin.dart';
import 'wali_pengumuman.dart';

class WaliDashboard extends StatefulWidget {
  const WaliDashboard({super.key});

  @override
  State<WaliDashboard> createState() => _WaliDashboardState();
}

class _WaliDashboardState extends State<WaliDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WaliHome(),
    const WaliPengumuman(),
    const WaliChatList(),
    const WaliIzin(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wali Santri Panel'),
        backgroundColor: AppTheme.roleWaliColor,
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
          ResponsiveNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
          ResponsiveNavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'Pengumuman'),
          ResponsiveNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Chat Murobbi'),
          ResponsiveNavItem(icon: Icons.edit_document, activeIcon: Icons.edit_document, label: 'Kirim Izin'),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
