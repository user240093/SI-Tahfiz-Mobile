import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';

class KoordinatorIzin extends StatelessWidget {
  const KoordinatorIzin({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final pendingIzin = provider.getAllPendingIzin();

    return pendingIzin.isEmpty
        ? const Center(child: Text('Tidak ada pengajuan izin yang pending.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: pendingIzin.length,
            itemBuilder: (context, index) {
              final izin = pendingIzin[index];
              final santri = provider.getSantriById(izin.santriId);
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${santri?.name ?? 'Unknown'} (Kelas ${santri?.kelas})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${izin.date.day}/${izin.date.month}/${izin.date.year}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Alasan: ${izin.reason}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Keterangan: ${izin.description}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => provider.updateIzinStatus(izin.id, 'Rejected'),
                            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => provider.updateIzinStatus(izin.id, 'Approved'),
                            child: const Text('Setujui'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
  }
}
