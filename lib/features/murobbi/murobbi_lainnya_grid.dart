import 'package:flutter/material.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';

class MurobbiLainnyaGrid extends StatelessWidget {
  const MurobbiLainnyaGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': 'Tikrar & Manzil',
        'icon': Icons.warning_amber_rounded,
        'route': '/pengampu/tikrar',
        'color': Colors.orange,
      },
      {
        'label': 'UKJ',
        'icon': Icons.verified_rounded,
        'route': '/pengampu/ukj',
        'color': Colors.blue,
      },
      {
        'label': 'UAS',
        'icon': Icons.assignment_rounded,
        'route': '/pengampu/uas',
        'color': Colors.purple,
      },
      {
        'label': 'Akhlaq',
        'icon': Icons.favorite_rounded,
        'route': '/pengampu/akhlaq',
        'color': Colors.red,
      },
      {
        'label': 'Pesan',
        'icon': Icons.chat_bubble_rounded,
        'route': '/pengampu/pesan',
        'color': Colors.teal,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Lainnya', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Akses menu tambahan pengajaran halaqah.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return AppCard(
                  role: 'pengampu',
                  onTap: () {
                    Navigator.pushNamed(context, item['route']);
                  },
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['label'] as String,
                          style: AppTextStyles.h5,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
