import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';

class KepsekApproval extends StatelessWidget {
  const KepsekApproval({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allUkj = provider.allUkj;
    final pendingUkj = allUkj.where((u) => u.status == 'Pending').toList();

    return pendingUkj.isEmpty
        ? const Center(child: Text('Tidak ada dokumen yang butuh validasi Anda saat ini.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: pendingUkj.length,
            itemBuilder: (context, index) {
              final ukj = pendingUkj[index];
              final santri = provider.getSantriById(ukj.santriId);
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pengajuan UKJ: ${santri?.name ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Butuh Tanda Tangan', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Tgl Pengajuan: ${ukj.requestDate.day}/${ukj.requestDate.month}/${ukj.requestDate.year}'),
                      const Text('Syarat: Lulus ujian lisan & tulis (Telah divalidasi Koordinator).'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => provider.updateUkjStatus(ukj.id, 'Rejected'),
                            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                            onPressed: () {
                              provider.updateUkjStatus(ukj.id, 'Approved');
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dokumen telah ditandatangani secara digital.')));
                            },
                            icon: const Icon(Icons.draw),
                            label: const Text('Approve & TTD Digital'),
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
