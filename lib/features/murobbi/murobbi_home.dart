import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state_widget.dart';
import 'input_setoran_screen.dart';

class MurobbiHome extends ConsumerWidget {
  const MurobbiHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final santriListAsync = ref.watch(santriForMurobbiProvider(user.id));

    return santriListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(santriProvider)),
      data: (santriList) {
        return santriList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Belum ada santri binaan.', style: AppTextStyles.body),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: santriList.length,
                itemBuilder: (context, index) {
                  final santri = santriList[index];
                  final name = santri['nama_lengkap'] ?? '';
                  return AppCard(
                    role: 'pengampu',
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputSetoranScreen(santriId: santri['id'], santriName: name),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0] : '?',
                              style: AppTextStyles.h3.copyWith(color: const Color(0xFF10B981)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTextStyles.h4),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Kelas ${santri['kelas'] ?? ''}',
                                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade700),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ID: ${santri['id'].toString().substring(0, 8)}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
                },
              );
      },
    );
  }
}
