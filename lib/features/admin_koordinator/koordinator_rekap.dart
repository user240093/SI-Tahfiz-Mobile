import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class KoordinatorRekap extends StatelessWidget {
  const KoordinatorRekap({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final santriList = provider.allSantri;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: santriList.length,
      itemBuilder: (context, index) {
        final santri = santriList[index];
        final nilai = provider.getNilai(santri.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(santri.name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(santri.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Kelas: ${santri.kelas} | NIS: ${santri.nis}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                  child: nilai != null ? Column(
                    children: [
                      _buildNilaiRow('Setoran (40%)', nilai.setoranPercent),
                      _buildNilaiRow('UAS (40%)', nilai.uasPercent),
                      _buildNilaiRow('Akhlaq (10%)', nilai.akhlaqPercent),
                      _buildNilaiRow('Kehadiran (10%)', nilai.kehadiranPercent),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Nilai Akhir', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(nilai.totalNilai.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryColor)),
                        ],
                      ),
                    ],
                  ) : const Text('Nilai belum direkap.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                )
              ],
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildNilaiRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textDark)),
          Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
