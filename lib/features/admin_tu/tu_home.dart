import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state_widget.dart';

class TuHome extends ConsumerWidget {
  const TuHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final santriAsync = ref.watch(santriProvider);

    return santriAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(santriProvider)),
      data: (santriList) {
        final totalSantri = santriList.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16), // TU: compact spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Administrasi',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard('Total Santri Aktif', totalSantri.toString(), Icons.group_rounded, const Color(0xFF10B981)),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 24),
              
              AppCard(
                role: 'tu',
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan Kerusakan & Fasilitas',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistem pelaporan sarpras sedang dalam pemeliharaan. Silakan hubungi teknisi secara langsung untuk sementara waktu.',
                      style: AppTextStyles.body.copyWith(color: const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    AppButton.structured(
                      text: 'Buat Laporan Baru',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur menyusul di versi berikutnya.')),
                        );
                      },
                      icon: const Icon(Icons.handyman, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      role: 'tu',
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 220,
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
