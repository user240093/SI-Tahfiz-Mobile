import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/mock_data.dart';
import '../../core/app_provider.dart';
import '../murobbi/murobbi_dashboard.dart';
import '../wali/wali_dashboard.dart';
import '../admin_koordinator/koordinator_dashboard.dart';
import '../admin_tu/tu_dashboard.dart';
import '../admin_kepsek/kepsek_dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    
    // We get announcements without listening to avoid unnecessary rebuilds of login
    final provider = Provider.of<AppProvider>(context, listen: false);
    final announcements = provider.allAnnouncements;

    return Scaffold(
      body: Row(
        children: [
          // Left side News/Announcements for Desktop
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
                            const SizedBox(width: 16),
                            Text(
                              'SI-Tahfiz',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                        const SizedBox(height: 64),
                        Text(
                          'Papan Pengumuman',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Berita terkini dari MTs TQ Jamilurrahman',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        const SizedBox(height: 32),
                        Expanded(
                          child: announcements.isEmpty
                              ? const Center(child: Text('Belum ada pengumuman.', style: TextStyle(color: Colors.white54)))
                              : ListView.separated(
                                  itemCount: announcements.length,
                                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final ann = announcements[index];
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                                child: Text(
                                                  '${ann.date.day}/${ann.date.month}/${ann.date.year}',
                                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Text(ann.authorName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(ann.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Text(ann.content, style: const TextStyle(color: Colors.white70, height: 1.5)),
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: (400 + (index * 150)).ms).slideX(begin: -0.1);
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Login Form Section
          Expanded(
            flex: 7,
            child: Container(
              color: AppTheme.backgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isDesktop) ...[
                          Icon(Icons.menu_book_rounded, size: 64, color: AppTheme.primaryColor)
                              .animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          'Selamat Datang',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.textDark,
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan pilih peran untuk masuk ke sistem',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                        const SizedBox(height: 48),
                        
                        // Role Cards
                        ...MockData.users.asMap().entries.map((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          return _buildRoleCard(context, user)
                              .animate()
                              .fadeIn(delay: (300 + (index * 100)).ms)
                              .slideX(begin: 0.1, curve: Curves.easeOut);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, User user) {
    final roleColor = AppTheme.getColorForRole(user.role);
    final iconData = AppTheme.getIconForRole(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black12,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleLogin(context, user),
          splashColor: roleColor.withOpacity(0.1),
          highlightColor: roleColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: roleColor, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.role,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, User user) {
    Provider.of<AppProvider>(context, listen: false).login(user);

    Widget dashboard;
    switch (user.role) {
      case UserRole.murobbi:
        dashboard = const MurobbiDashboard();
        break;
      case UserRole.wali:
        dashboard = const WaliDashboard();
        break;
      case UserRole.koordinator:
        dashboard = const KoordinatorDashboard();
        break;
      case UserRole.tu:
        dashboard = const TuDashboard();
        break;
      case UserRole.kepalaSekolah:
        dashboard = const KepsekDashboard();
        break;
      default:
        dashboard = const Scaffold(body: Center(child: Text('Unknown Role')));
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => dashboard,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
