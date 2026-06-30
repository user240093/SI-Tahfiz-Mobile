import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';

class KepsekHome extends StatelessWidget {
  const KepsekHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // Aggregate stats
    final totalSantri = provider.allSantri.length;
    final totalMurobbi = provider.getChatContacts().where((u) => u.role == 'Murobbi').length; // Dummy
    final totalTikrar = provider.allSantri.where((s) => provider.isSantriInTikrar(s.id)).length;
    final totalDanaMasuk = provider.allSpp.fold(0.0, (sum, spp) => sum + spp.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Executive Summary', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(context, 'Total Santri Aktif', totalSantri.toString(), Icons.school_rounded, Colors.blue),
              _buildStatCard(context, 'Total Murobbi', totalMurobbi.toString(), Icons.person_pin_rounded, Colors.purple),
              _buildStatCard(context, 'Santri Bermasalah (Tikrar)', totalTikrar.toString(), Icons.warning_rounded, Colors.orange),
              _buildStatCard(context, 'Total Pemasukan Bulan Ini', 'Rp ${(totalDanaMasuk/1000).toStringAsFixed(0)}k', Icons.attach_money_rounded, Colors.green),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 48),
          const Text('Aktivitas Terbaru (Log Sistem)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Card(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ListTile(leading: Icon(Icons.history), title: Text('TU menerima SPP dari Zaid (Rp 250,000)'), subtitle: Text('Hari ini, 08:45')),
                ListTile(leading: Icon(Icons.history), title: Text('Koordinator broadcast pengumuman "Libur Idul Adha"'), subtitle: Text('Kemarin, 14:00')),
              ],
            ),
          )
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
