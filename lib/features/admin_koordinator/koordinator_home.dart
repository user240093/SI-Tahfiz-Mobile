import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class KoordinatorHome extends StatelessWidget {
  const KoordinatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allSantri = provider.allSantri;
    final totalSantri = allSantri.length;
    final tikrarCount = allSantri.where((s) => provider.isSantriInTikrar(s.id)).length;
    final pendingIzinCount = provider.getAllPendingIzin().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Statistik', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(context, 'Total Santri', totalSantri.toString(), Icons.group_rounded, Colors.blue),
              _buildStatCard(context, 'Santri Tikrar', tikrarCount.toString(), Icons.warning_rounded, AppTheme.warningColor),
              _buildStatCard(context, 'Izin Pending', pendingIzinCount.toString(), Icons.mark_email_unread_rounded, AppTheme.roleKoordinatorColor),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 48),
          Text('Murobbi Terdaftar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Mock data for murobbi list (derived from users)
          ...provider.getChatContacts().where((u) => u.role == 'Murobbi').map((murobbi) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(murobbi.name),
                subtitle: Text('ID: ${murobbi.id}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
