import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/pesan_provider.dart';
import '../../core/providers/tikrar_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state_widget.dart';

class KepsekHome extends ConsumerWidget {
  const KepsekHome({super.key});

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
        final totalMurobbi = ref.watch(chatContactsProvider).where((u) => u.role == 'Murobbi').length;
        
        final totalTikrar = tikrarAsync.when(
          data: (tList) => tList.length,
          loading: () => 0,
          error: (_, __) => 0,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Medium spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Executive Summary', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Total Santri Aktif', totalSantri.toString(), Icons.school_rounded, Colors.blue),
                  _buildStatCard('Total Murobbi', totalMurobbi.toString(), Icons.person_pin_rounded, Colors.purple),
                  _buildStatCard('Santri Tikrar', totalTikrar.toString(), Icons.warning_rounded, Colors.orange),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 32),
              Text('Aktivitas Terbaru (Log Sistem)', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              AppCard(
                role: 'kepsek',
                padding: EdgeInsets.zero,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history, color: Color(0xFF6B7280)),
                      title: Text('Koordinator broadcast pengumuman "Libur Idul Adha"', style: AppTextStyles.body),
                      subtitle: Text('Kemarin, 14:00', style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      role: 'kepsek',
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
