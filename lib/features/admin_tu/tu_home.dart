import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class TuHome extends StatelessWidget {
  const TuHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allSpp = provider.allSpp;
    final totalSantri = provider.allSantri.length;
    
    // Calculate simple stats
    double totalDanaMasuk = 0;
    for (var spp in allSpp) {
      totalDanaMasuk += spp.amount;
    }
    
    // Asumsi target dana adalah Rp 250.000 x jumlah santri per bulan
    double targetDana = totalSantri * 250000;
    double persenTercapai = targetDana == 0 ? 0 : (totalDanaMasuk / targetDana) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Administrasi & Keuangan', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(context, 'Total Santri Aktif', totalSantri.toString(), Icons.group_rounded, Colors.blue),
              _buildStatCard(context, 'Pemasukan SPP (Bulan Ini)', 'Rp ${(totalDanaMasuk/1000).toStringAsFixed(0)}k', Icons.account_balance_wallet_rounded, Colors.green),
              _buildStatCard(context, 'Target SPP Tercapai', '${persenTercapai.toStringAsFixed(1)}%', Icons.pie_chart_rounded, AppTheme.roleTuColor),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 48),
          
          Card(
            color: AppTheme.roleTuColor.withOpacity(0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppTheme.roleTuColor.withOpacity(0.2))),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Laporan Kerusakan & Fasilitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Sistem pelaporan sarpras sedang dalam pemeliharaan. Silakan hubungi teknisi secara langsung untuk sementara waktu.', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roleTuColor),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur menyusul di versi berikutnya.')));
                    },
                    icon: const Icon(Icons.handyman),
                    label: const Text('Buat Laporan Baru'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      width: 250,
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
