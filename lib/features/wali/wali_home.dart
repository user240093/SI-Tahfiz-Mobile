import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import 'ttd_canvas_screen.dart';

class WaliHome extends StatelessWidget {
  const WaliHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    if (user == null) return const SizedBox();

    final santriList = provider.getSantriForWali(user.id);

    return santriList.isEmpty
        ? const Center(child: Text('Tidak ada data anak yang terkait.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: santriList.length,
            itemBuilder: (context, index) {
              final santri = santriList[index];
              final historySetoran = provider.getSetoranForSantri(santri.id);
              final inTikrar = provider.isSantriInTikrar(santri.id);
              final journal = provider.getJournalForSantri(santri.id);
              final nilai = provider.getNilai(santri.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 28, backgroundColor: AppTheme.roleWaliColor.withOpacity(0.1), child: Text(santri.name[0], style: const TextStyle(color: AppTheme.roleWaliColor, fontWeight: FontWeight.bold, fontSize: 24))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(santri.name, style: Theme.of(context).textTheme.titleLarge),
                                Text('Kelas: ${santri.kelas}', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          if (nilai != null)
                            Column(
                              children: [
                                Text('Nilai Akhir', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                Text(nilai.totalNilai.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                              ],
                            )
                        ],
                      ),
                      if (inTikrar)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.warningColor)),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                              SizedBox(width: 12),
                              Expanded(child: Text('Anak Anda masuk program Tikrar.', style: TextStyle(color: Color(0xFF78350F)))),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (journal.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Catatan Murobbi Terbaru:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                              const SizedBox(height: 4),
                              Text('"${journal.last.note}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Divider(),
                      const Text('Histori Setoran Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      historySetoran.isEmpty
                          ? const Text('Belum ada histori setoran.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historySetoran.length,
                              itemBuilder: (context, idx) {
                                final s = historySetoran[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${s.type} - ${s.surah} (${s.ayatStart}-${s.ayatEnd})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text('Tgl: ${s.date.day}/${s.date.month} | Kesalahan: ${s.kesalahan}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      if (s.type == 'Manzil')
                                        s.isValidatedByWali
                                            ? const Icon(Icons.verified_rounded, color: Colors.green)
                                            : ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roleWaliColor),
                                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TtdCanvasScreen(setoranId: s.id))),
                                                icon: const Icon(Icons.draw, size: 16),
                                                label: const Text('Validasi', style: TextStyle(fontSize: 12)),
                                              )
                                    ],
                                  ),
                                );
                              },
                            )
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (150 * index).ms).slideY(begin: 0.1);
            },
          );
  }
}
