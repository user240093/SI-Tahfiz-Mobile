import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/uas_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/error_state_widget.dart';

class KoordinatorRekap extends ConsumerWidget {
  const KoordinatorRekap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final santriAsync = ref.watch(santriProvider);

    final content = santriAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(santriProvider),
      ),
      data: (santriList) {
        if (santriList.isEmpty) {
          return Center(child: Text('Belum ada data santri.', style: AppTextStyles.body));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: santriList.length,
          itemBuilder: (context, index) {
            final santri = santriList[index];
            final nilaiAsync = ref.watch(nilaiForSantriProvider(santri['id']));

            return AppCard(
              role: 'koordinator',
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                        child: Text(
                          (santri['nama_lengkap'] ?? '?')[0],
                          style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(santri['nama_lengkap'] ?? '', style: AppTextStyles.h4),
                            const SizedBox(height: 2),
                            Text('Kelas: ${santri['kelas']} | ID: ${santri['id'].toString().substring(0, 8)}', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: nilaiAsync.when(
                      loading: () => const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                      error: (e, _) => Text('Gagal menghitung nilai: $e', style: AppTextStyles.body.copyWith(color: Colors.red)),
                      data: (nilai) => nilai != null ? Column(
                        children: [
                          _buildNilaiRow('Setoran (40%)', nilai['setoranPercent'] ?? 0.0),
                          _buildNilaiRow('UAS (40%)', nilai['uasPercent'] ?? 0.0),
                          _buildNilaiRow('Akhlaq (10%)', nilai['akhlaqPercent'] ?? 0.0),
                          _buildNilaiRow('Kehadiran (10%)', nilai['kehadiranPercent'] ?? 0.0),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Nilai Akhir', style: AppTextStyles.h5),
                              Text(
                                (nilai['totalNilai'] ?? 0.0).toStringAsFixed(1),
                                style: AppTextStyles.h3.copyWith(color: const Color(0xFF10B981)),
                              ),
                            ],
                          ),
                        ],
                      ) : Text('Nilai belum direkap.', style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)),
                    ),
                  )
                ],
              ),
            ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
          },
        );
      },
    );

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'koordinator',
        isNested: true,
        title: 'Rekap Nilai',
      ),
      body: content,
    );
  }

  Widget _buildNilaiRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value.toStringAsFixed(1), style: AppTextStyles.h6),
        ],
      ),
    );
  }
}
