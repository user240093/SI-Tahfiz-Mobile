import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class WaliPengumuman extends StatelessWidget {
  const WaliPengumuman({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final announcements = provider.allAnnouncements;

    return announcements.isEmpty
        ? const Center(child: Text('Belum ada pengumuman.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final a = announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('${a.date.day}/${a.date.month}/${a.date.year}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          Text(a.authorName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(a.content, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
