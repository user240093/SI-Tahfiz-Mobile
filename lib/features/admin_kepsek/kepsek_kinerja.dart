import 'package:flutter/material.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';

class KepsekKinerja extends StatelessWidget {
  const KepsekKinerja({super.key});

  @override
  Widget build(BuildContext context) {
    final mockKinerja = [
      {'name': 'Ustadz Ahmad', 'kelas': '7A', 'rataNilai': 85.5, 'santriLulus': 12, 'santriTikrar': 1},
      {'name': 'Ustadz Budi', 'kelas': '7B', 'rataNilai': 78.0, 'santriLulus': 8, 'santriTikrar': 3},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monitoring Kinerja Murobbi', style: AppTextStyles.h3),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: mockKinerja.length,
              itemBuilder: (context, index) {
                final k = mockKinerja[index];
                return AppCard(
                  role: 'kepsek',
                  margin: const EdgeInsets.only(bottom: 16),
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
                                Text(k['name'] as String, style: AppTextStyles.h4),
                                Text('Wali Kelas ${k['kelas']}', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text('Rata-rata Nilai Kelas', style: AppTextStyles.label),
                              Text('${k['rataNilai']}', style: AppTextStyles.h3.copyWith(color: Colors.purple)),
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
        Text(value, style: AppTextStyles.h3.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
