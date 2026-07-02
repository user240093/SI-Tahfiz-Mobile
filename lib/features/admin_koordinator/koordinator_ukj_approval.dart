import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/ukj_provider.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/error_state_widget.dart';

class KoordinatorUkjApproval extends ConsumerWidget {
  const KoordinatorUkjApproval({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ukjAsync = ref.watch(ukjProvider);

    return ukjAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(ukjProvider),
      ),
      data: (allUkj) {
        final pendingUkj = allUkj.where((u) => u['status_approval'].toString().toLowerCase() == 'pending').toList();

        return pendingUkj.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Tidak ada UKJ yang menunggu persetujuan.', style: AppTextStyles.body),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: pendingUkj.length,
                itemBuilder: (context, index) {
                  final ukj = pendingUkj[index];
                  final santriAsync = ref.watch(santriByIdProvider(ukj['santri_id']));
                  final date = DateTime.parse(ukj['created_at'] ?? DateTime.now().toIso8601String());

                  return AppCard(
                    role: 'koordinator',
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: santriAsync.when(
                                loading: () => Text('Loading...', style: AppTextStyles.h4),
                                error: (err, _) => Text('Error: $err', style: AppTextStyles.h4),
                                data: (santri) => Text('Pengajuan UKJ: ${santri?['nama_lengkap'] ?? 'Unknown'}', style: AppTextStyles.h4),
                              ),
                            ),
                            const StatusBadge(status: 'pending'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tgl Pengajuan: ${date.day}/${date.month}/${date.year}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Juz yang Diuji: Juz ${ukj['nomor_juz']} | Nilai: ${ukj['nilai']}',
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Syarat: Lulus ujian lisan & tulis (Telah divalidasi Koordinator).',
                          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton.clean(
                              text: 'Tolak',
                              variant: AppButtonVariant.danger,
                              isSmall: true,
                              onPressed: () => ref.read(ukjProvider.notifier).updateUkjStatus(ukj['id'], 'Rejected'),
                            ),
                            const SizedBox(width: 12),
                            AppButton.clean(
                              text: 'Approve',
                              variant: AppButtonVariant.primary,
                              isSmall: true,
                              onPressed: () {
                                ref.read(ukjProvider.notifier).updateUkjStatus(ukj['id'], 'Approved');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dokumen telah disetujui.')),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}
