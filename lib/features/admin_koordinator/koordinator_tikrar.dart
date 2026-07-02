import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/tikrar_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/error_state_widget.dart';

class KoordinatorTikrar extends ConsumerWidget {
  const KoordinatorTikrar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final santriAsync = ref.watch(santriProvider);
    final tikrarAsync = ref.watch(tikrarProvider);

    final content = santriAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () {
          ref.invalidate(santriProvider);
          ref.invalidate(tikrarProvider);
        },
      ),
      data: (santriList) {
        return tikrarAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading tikrar: $e', style: AppTextStyles.body)),
          data: (tikrarList) {
            final tikrarSantri = santriList.where((s) => tikrarList.any((t) => t['santri_id'] == s['id'])).toList();

            return tikrarSantri.isEmpty
                ? Center(child: Text('Alhamdulillah, tidak ada santri di program Tikrar saat ini.', style: AppTextStyles.body))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tikrarSantri.length,
                    itemBuilder: (context, index) {
                      final santri = tikrarSantri[index];
                      final tikrarEntry = tikrarList.firstWhere((t) => t['santri_id'] == santri['id']);

                      return AppCard(
                        role: 'koordinator',
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_rounded, color: Color(0xFFF59E0B), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(santri['nama_lengkap'] ?? '', style: AppTextStyles.h5),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kelas ${santri['kelas']} - Status: ${tikrarEntry['status'] ?? 'wajib_sekolah'}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            AppButton.clean(
                              text: 'Selesai',
                              isSmall: true,
                              onPressed: () async {
                                final id = tikrarEntry['id'];
                                if (id != null) {
                                  await ref.read(tikrarProvider.notifier).updateTikrar(id, {
                                    'status': 'selesai_sekolah',
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Santri ditandai telah selesai sekolah Tikrar.')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
          },
        );
      },
    );

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'koordinator',
        isNested: true,
        title: 'Detail Halaqah / Tikrar',
      ),
      body: content,
    );
  }
}
