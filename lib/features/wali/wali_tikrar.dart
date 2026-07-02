import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/tikrar_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/error_state_widget.dart';

class WaliTikrar extends ConsumerStatefulWidget {
  const WaliTikrar({super.key});

  @override
  ConsumerState<WaliTikrar> createState() => _WaliTikrarState();
}

class _WaliTikrarState extends ConsumerState<WaliTikrar> {
  String? _ortuId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(authProvider);
    final myId = user?.supabaseUser?.id ?? user?.id ?? '';
    if (myId.isNotEmpty && mounted) {
      setState(() {
        _ortuId = myId;
      });
      await ref.read(tikrarProvider.notifier).fetchTikrarAnak(myId);
    }
  }

  Future<void> _konfirmasiSelesai(String tikrarId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Tikrar', style: AppTextStyles.h4),
        content: Text('Apakah Tikrar ini sudah diselesaikan di rumah?', style: AppTextStyles.body),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          AppButton.warm(
            text: 'Batal',
            variant: AppButtonVariant.secondary,
            isSmall: true,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton.warm(
            text: 'Ya, Sudah Selesai',
            variant: AppButtonVariant.primary,
            isSmall: true,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        if (_ortuId != null) {
          await ref.read(tikrarProvider.notifier).tandaiSelesaiRumah(tikrarId, _ortuId!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tikrar berhasil diselesaikan di rumah'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            ref.read(tikrarProvider.notifier).fetchTikrarAnak(_ortuId!);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tikrarAsync = ref.watch(tikrarProvider);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _ortuId == null
          ? const Center(child: CircularProgressIndicator())
          : tikrarAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateWidget(
                message: e.toString(),
                onRetry: _loadData,
              ),
              data: (tikrarList) {
                if (tikrarList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 72, color: Colors.blue),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada Tikrar yang perlu diselesaikan di rumah',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h5.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: tikrarList.length,
                  itemBuilder: (context, index) {
                    final tikrar = tikrarList[index];
                    final santri = tikrar['santri'] as Map<String, dynamic>? ?? {};
                    final namaSantri = santri['nama_lengkap'] ?? 'Santri';
                    final surah = tikrar['surah'] ?? '';
                    final tanggal = tikrar['tanggal'] ?? '';

                    return AppCard(
                      role: 'orang_tua',
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      namaSantri,
                                      style: AppTextStyles.h4,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: Wajib Rumah',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const StatusBadge(status: 'izin'), // Maps to Blue theme
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(surah, style: AppTextStyles.body),
                              const Spacer(),
                              Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text(tanggal, style: AppTextStyles.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton.warm(
                              text: 'Tandai Selesai di Rumah',
                              onPressed: () => _konfirmasiSelesai(tikrar['id'] as String),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
