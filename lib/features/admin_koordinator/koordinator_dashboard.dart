import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/pengumuman_service.dart';
import 'koordinator_home.dart';
import 'koordinator_ukj_approval.dart';
import 'koordinator_lainnya_grid.dart';

class KoordinatorDashboard extends ConsumerStatefulWidget {
  final int initialIndex;
  const KoordinatorDashboard({super.key, this.initialIndex = 0});

  @override
  ConsumerState<KoordinatorDashboard> createState() => _KoordinatorDashboardState();
}

class _KoordinatorDashboardState extends ConsumerState<KoordinatorDashboard> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const KoordinatorHome(),
    const KoordinatorUkjApproval(),
    const SizedBox(), // Dummy for Kelola
    const KoordinatorLainnyaGrid(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null) {
        final userId = user.supabaseUser?.id ?? user.id;
        final userRole = user.roleString ?? 'koordinator';
        PengumumanService.checkAndShowPengumuman(context, userRole, userId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant KoordinatorDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _showKelolaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Kelola Program',
                  style: AppTextStyles.h3,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF10B981)),
                title: Text('Syahrul Quran', style: AppTextStyles.h5),
                subtitle: Text('Atur tanggal mulai & selesai Syahrul Quran', style: AppTextStyles.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/koordinator/kelola/syahrul-quran');
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_week_rounded, color: Color(0xFF10B981)),
                title: Text('Pekan Murajaah', style: AppTextStyles.h5),
                subtitle: Text('Atur tanggal & target Pekan Murajaah', style: AppTextStyles.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/koordinator/kelola/pekan-murajaah');
                },
              ),
              ListTile(
                leading: const Icon(Icons.grade_rounded, color: Color(0xFF10B981)),
                title: Text('Grade Santri', style: AppTextStyles.h5),
                subtitle: Text('Ubah grade santri secara manual', style: AppTextStyles.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/koordinator/kelola/grade');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _onNavigation(int index) {
    if (index == 2) {
      _showKelolaBottomSheet(context);
      return;
    }

    if (index == 3) {
      setState(() {
        _currentIndex = 3;
      });
      return;
    }

    if (index == 1) {
      Navigator.pushNamed(context, '/koordinator/ukj');
      return;
    }

    String route = index == 0 ? '/koordinator/beranda' : '/koordinator/ukj';
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'koordinator',
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
            icon: Icons.verified_outlined,
            activeIcon: Icons.verified_rounded,
            label: 'UKJ',
          ),
          ResponsiveNavItem(
            icon: Icons.tune_outlined,
            activeIcon: Icons.tune_rounded,
            label: 'Kelola',
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
