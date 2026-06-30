import 'package:flutter/material.dart';

class KepsekKinerja extends StatelessWidget {
  const KepsekKinerja({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data kinerja Murobbi
    final mockKinerja = [
      {'name': 'Ustadz Ahmad', 'kelas': '7A', 'rataNilai': 85.5, 'santriLulus': 12, 'santriTikrar': 1},
      {'name': 'Ustadz Budi', 'kelas': '7B', 'rataNilai': 78.0, 'santriLulus': 8, 'santriTikrar': 3},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monitoring Kinerja Murobbi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: mockKinerja.length,
              itemBuilder: (context, index) {
                final k = mockKinerja[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.purple.withOpacity(0.1),
                              child: const Icon(Icons.person, color: Colors.purple),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(k['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Wali Kelas ${k['kelas']}', style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text('Rata-rata Nilai Kelas', style: TextStyle(fontSize: 10)),
                                Text('${k['rataNilai']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.purple)),
                              ],
                            )
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildKinerjaStat('Santri Lulus UKJ', '${k['santriLulus']}', Colors.green),
                            _buildKinerjaStat('Santri Tikrar', '${k['santriTikrar']}', Colors.orange),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKinerjaStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
