import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'murobbi_home.dart';
import 'murobbi_jurnal.dart';
import 'murobbi_chat_list.dart';
import 'murobbi_izin.dart';

class MurobbiDashboard extends StatefulWidget {
  const MurobbiDashboard({super.key});

  @override
  State<MurobbiDashboard> createState() => _MurobbiDashboardState();
}

class _MurobbiDashboardState extends State<MurobbiDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MurobbiHome(),
    const MurobbiJurnal(),
    const MurobbiChatList(),
    const MurobbiIzin(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Murobbi Panel'),
        backgroundColor: AppTheme.roleMurobbiColor,
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
          ResponsiveNavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Santri'),
          ResponsiveNavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Jurnal'),
          ResponsiveNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Chat Wali'),
          ResponsiveNavItem(icon: Icons.mark_email_unread_outlined, activeIcon: Icons.mark_email_read_rounded, label: 'Izin'),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
