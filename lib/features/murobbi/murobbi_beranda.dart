import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';

class MurobbiBeranda extends ConsumerWidget {
  const MurobbiBeranda({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final santriListAsync = ref.watch(santriForMurobbiProvider(user.id));
    final totalSantri = santriListAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            role: 'pengampu',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assalamu\'alaikum,', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.normal)),
                const SizedBox(height: 4),
                Text(user.name, style: AppTextStyles.h2.copyWith(color: const Color(0xFF10B981))),
                const SizedBox(height: 16),
                Text(
                  'Selamat datang kembali di Panel Pengampu. Kelola setoran hafalan, manzil, absensi, dan interaksi wali santri dengan mudah.',
                  style: AppTextStyles.body.copyWith(color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Statistik Halaqah', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              AppCard(
                role: 'pengampu',
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people_rounded, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(height: 16),
                      Text('$totalSantri', style: AppTextStyles.h1.copyWith(color: const Color(0xFF10B981))),
                      const SizedBox(height: 4),
                      Text('Santri Binaan', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
