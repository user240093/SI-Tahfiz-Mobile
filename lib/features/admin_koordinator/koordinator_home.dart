import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/pesan_provider.dart';
import '../../core/providers/tikrar_provider.dart';
import '../../core/providers/konfigurasi_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state_widget.dart';

class KoordinatorHome extends ConsumerWidget {
  const KoordinatorHome({super.key});

  void _showToggleAkhlaqDialog(BuildContext context, WidgetRef ref, bool newValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(newValue ? 'Aktifkan Fitur Akhlaq?' : 'Nonaktifkan Fitur Akhlaq?', style: AppTextStyles.h3),
          content: Text(
            newValue
                ? 'Fitur penilaian akhlaq akan diaktifkan. Pengampu dapat mulai menginput nilai akhlaq. Lanjutkan?'
                : 'Fitur penilaian akhlaq akan dinonaktifkan. Menu akhlaq tidak akan muncul di halaman pengampu. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppTextStyles.body.copyWith(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                try {
                  await ref.read(konfigurasiProvider.notifier).updateFiturAkhlaq(newValue);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur akhlaq berhasil ${newValue ? 'diaktifkan' : 'dinonaktifkan'}'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text('Lanjutkan', style: AppTextStyles.h5.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final santriAsync = ref.watch(santriProvider);
    final tikrarAsync = ref.watch(tikrarProvider);
    final configAsync = ref.watch(konfigurasiProvider);

    return santriAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () {
          ref.invalidate(santriProvider);
          ref.invalidate(tikrarProvider);
          ref.invalidate(konfigurasiProvider);
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

              // Fitur Akhlaq Toggle Section
              configAsync.maybeWhen(
                data: (configState) {
                  final active = configState.konfigurasi?['fitur_akhlaq_aktif'] ?? false;
                  return AppCard(
                    role: 'koordinator',
                    margin: const EdgeInsets.only(top: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pengaturan Sistem', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fitur Penilaian Akhlaq', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  active ? 'Status: Aktif' : 'Status: Nonaktif',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: active ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: active,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (newValue) {
                                _showToggleAkhlaqDialog(context, ref, newValue);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox(),
              ),
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
