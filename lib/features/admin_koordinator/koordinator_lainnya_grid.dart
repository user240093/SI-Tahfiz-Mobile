import 'package:flutter/material.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';

class KoordinatorLainnyaGrid extends StatelessWidget {
  const KoordinatorLainnyaGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': 'Pengumuman',
        'icon': Icons.campaign_rounded,
        'route': '/koordinator/pengumuman',
        'color': Colors.blue,
      },
      {
        'label': 'Rekap',
        'icon': Icons.analytics_rounded,
        'route': '/koordinator/rekap',
        'color': Colors.purple,
      },
      {
        'label': 'Pesan',
        'icon': Icons.chat_bubble_rounded,
        'route': '/koordinator/pesan',
        'color': Colors.orange,
      },
      {
        'label': 'Halaqah',
        'icon': Icons.menu_book_rounded,
        'route': '/koordinator/halaqah',
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
            'Akses menu tambahan pengelolaan program tahfiz.',
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
                  role: 'koordinator',
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
