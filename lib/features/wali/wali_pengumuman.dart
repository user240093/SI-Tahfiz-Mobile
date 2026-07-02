import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/pengumuman_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/error_state_widget.dart';

class WaliPengumuman extends ConsumerWidget {
  const WaliPengumuman({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(sortedAnnouncementsProvider);

    return announcementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(pengumumanProvider)),
      data: (announcements) {
        return announcements.isEmpty
            ? const Center(child: Text('Belum ada pengumuman.'))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final a = announcements[index];
                  final date = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
                  final author = a['profiles']?['nama_lengkap'] ?? 'Koordinator';
                  
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
                                child: Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              Text(author, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(a['judul'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(a['isi'] ?? '', style: const TextStyle(height: 1.5)),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
