import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/setoran_provider.dart';
import '../../core/providers/akhlaq_provider.dart';
import '../../core/providers/uas_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/error_state_widget.dart';

class WaliHome extends ConsumerWidget {
  const WaliHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final santriListAsync = ref.watch(santriForWaliProvider(user.id));

    return santriListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(santriProvider)),
      data: (santriList) {
        return santriList.isEmpty
            ? Center(child: Text('Tidak ada data anak yang terkait.', style: AppTextStyles.body))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: santriList.length,
                itemBuilder: (context, index) {
                  final santri = santriList[index];
                  final santriId = santri['id'];
                  final santriName = santri['nama_lengkap'] ?? '';

                  final historySetoranAsync = ref.watch(setoranForSantriProvider(santriId));
                  final journalAsync = ref.watch(akhlaqForSantriProvider(santriId));
                  final nilaiAsync = ref.watch(nilaiForSantriProvider(santriId));

                  return AppCard(
                    role: 'orang_tua',
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                              child: Text(
                                santriName.isNotEmpty ? santriName[0] : '?',
                                style: AppTextStyles.h3.copyWith(color: const Color(0xFF10B981)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(santriName, style: AppTextStyles.h3),
                                  Text('Kelas: ${santri['kelas'] ?? ''}', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            nilaiAsync.when(
                              loading: () => const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                              error: (_, __) => const SizedBox(),
                              data: (nilai) => nilai != null
                                  ? Column(
                                      children: [
                                        Text('Nilai Akhir', style: AppTextStyles.bodySmall),
                                        Text(
                                          (nilai['totalNilai'] ?? 0.0).toStringAsFixed(1),
                                          style: AppTextStyles.h4.copyWith(color: const Color(0xFF10B981)),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        journalAsync.when(
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                          data: (journal) => journal.isNotEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Catatan Murobbi Terbaru:', style: AppTextStyles.bodySmall.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('"${journal.last['note']}"', style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Histori Setoran Terakhir', style: AppTextStyles.h4),
                        const SizedBox(height: 12),
                        historySetoranAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Error load histori: $err', style: AppTextStyles.body.copyWith(color: Colors.red)),
                          data: (historySetoran) {
                            return historySetoran.isEmpty
                                ? Text('Belum ada histori setoran.', style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: historySetoran.length,
                                    itemBuilder: (context, idx) {
                                      final s = historySetoran[idx];
                                      final type = s['tipe']?.toString().toUpperCase() ?? '';
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$type - Hlm ${s['halaman_awal']} s/d ${s['halaman_akhir']}',
                                                    style: AppTextStyles.h6,
                                                  ),
                                                  Text(
                                                    'Tgl: ${s['tanggal']} | Kesalahan: ${s['jumlah_kesalahan']} | Baris: ${s['jumlah_baris']}',
                                                    style: AppTextStyles.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            StatusBadge(status: s['status'] ?? 'pending'),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (150 * index).ms).slideY(begin: 0.1);
                },
              );
      },
    );
  }
}
