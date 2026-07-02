import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/pesan_provider.dart';
import '../../core/providers/tikrar_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state_widget.dart';

class KoordinatorHome extends ConsumerWidget {
  const KoordinatorHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final santriAsync = ref.watch(santriProvider);
    final tikrarAsync = ref.watch(tikrarProvider);

    return santriAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () {
          ref.invalidate(santriProvider);
          ref.invalidate(tikrarProvider);
        },
      ),
      data: (santriList) {
        final totalSantri = santriList.length;
        
        final tikrarCount = tikrarAsync.when(
          data: (tList) => tList.length,
          loading: () => 0,
          error: (_, __) => 0,
        );

        final murobbis = ref.watch(chatContactsProvider).where((u) => u.role == 'Murobbi').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Medium spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan Statistik', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Total Santri', totalSantri.toString(), Icons.group_rounded, Colors.blue),
                  _buildStatCard('Santri Tikrar', tikrarCount.toString(), Icons.warning_rounded, const Color(0xFFF59E0B)),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 32),
              Text('Murobbi Terdaftar', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              if (murobbis.isEmpty)
                AppCard(
                  role: 'koordinator',
                  child: Center(
                    child: Text('Belum ada Murobbi terdaftar.', style: AppTextStyles.body),
                  ),
                )
              else
                ...murobbis.map((murobbi) {
                  return AppCard(
                    role: 'koordinator',
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                        child: const Icon(Icons.person, color: Color(0xFF10B981)),
                      ),
                      title: Text(murobbi.name, style: AppTextStyles.h5),
                      subtitle: Text('ID: ${murobbi.id}', style: AppTextStyles.bodySmall),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      role: 'koordinator',
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
