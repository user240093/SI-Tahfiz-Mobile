import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'wali_home.dart';
import 'wali_tikrar.dart';
import 'wali_chat_list.dart';

class WaliDashboard extends ConsumerStatefulWidget {
  final int initialIndex;
  const WaliDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<WaliDashboard> createState() => _WaliDashboardState();
}

class _WaliDashboardState extends ConsumerState<WaliDashboard> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const WaliHome(),
    const Center(child: Text('Panel Setoran Manzil Anak (Placeholder)')),
    const WaliTikrar(),
    const WaliChatList(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant WaliDashboard oldWidget) {
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
        route = '/ortu/beranda';
        break;
      case 1:
        route = '/ortu/manzil';
        break;
      case 2:
        route = '/ortu/tikrar';
        break;
      case 3:
        route = '/ortu/pesan';
        break;
      default:
        route = '/ortu/beranda';
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'orang_tua',
        isNested: false,
      ),
      body: ResponsiveLayout(
        currentIndex: _currentIndex,
        onIndexChanged: _onNavigation,
        navItems: [
          ResponsiveNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Beranda',
          ),
          ResponsiveNavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: 'Manzil',
          ),
          ResponsiveNavItem(
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning_rounded,
            label: 'Tikrar',
          ),
          ResponsiveNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'Pesan',
          ),
        ],
        mobileBody: _pages[_currentIndex],
      ),
    );
  }
}
