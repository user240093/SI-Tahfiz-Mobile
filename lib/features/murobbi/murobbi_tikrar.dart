import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/halaqah_provider.dart';
import '../../core/providers/tikrar_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/error_state_widget.dart';

class MurobbiTikrar extends ConsumerStatefulWidget {
  const MurobbiTikrar({super.key});

  @override
  ConsumerState<MurobbiTikrar> createState() => _MurobbiTikrarState();
}

class _MurobbiTikrarState extends ConsumerState<MurobbiTikrar> {
  String? _halaqahId;

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
    await ref.read(halaqahProvider.notifier).fetchHalaqah();
    
    final halaqahs = ref.read(halaqahProvider).value ?? [];
    final halaqah = halaqahs.firstWhere(
      (h) => h['pengampu_id'] == myId,
      orElse: () => <String, dynamic>{},
    );

    if (halaqah.isNotEmpty && mounted) {
      setState(() {
        _halaqahId = halaqah['id'] as String;
      });
      await ref.read(tikrarProvider.notifier).fetchTikrarHalaqah(_halaqahId!);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'wajib_sekolah':
        return const Color(0xFFFEE2E2);
      case 'selesai_sekolah':
        return const Color(0xFFFEF3C7);
      case 'wajib_rumah':
        return const Color(0xFFDBEAFE);
      case 'selesai_rumah':
        return const Color(0xFFD1FAE5);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'wajib_sekolah':
        return const Color(0xFF991B1B);
      case 'selesai_sekolah':
        return const Color(0xFF92400E);
      case 'wajib_rumah':
        return const Color(0xFF1E40AF);
      case 'selesai_rumah':
        return const Color(0xFF065F46);
      default:
        return Colors.grey.shade800;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'wajib_sekolah':
        return 'Wajib Sekolah';
      case 'selesai_sekolah':
        return 'Selesai Sekolah';
      case 'wajib_rumah':
        return 'Wajib Rumah';
      case 'selesai_rumah':
        return 'Selesai';
      default:
        return status;
    }
  }

  Future<void> _konfirmasiAksi({
    required String title,
    required String message,
    required Future<void> Function() action,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.roleMurobbiColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Lanjutkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await action();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tikrar berhasil diperbarui'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          if (_halaqahId != null) {
            ref.read(tikrarProvider.notifier).fetchTikrarHalaqah(_halaqahId!);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tikrarAsync = ref.watch(tikrarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tikrar Santri'),
        backgroundColor: AppTheme.roleMurobbiColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _halaqahId == null
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 72, color: Colors.green.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Alhamdulillah, tidak ada santri yang memiliki Tikrar aktif.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
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
                      final status = tikrar['status'] as String? ?? 'wajib_sekolah';
                      final santri = tikrar['santri'] as Map<String, dynamic>? ?? {};
                      final namaSantri = santri['nama_lengkap'] ?? 'Santri';
                      final surah = tikrar['surah'] ?? '';
                      final tanggal = tikrar['tanggal'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      namaSantri,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusLabel(status),
                                      style: TextStyle(
                                        color: _getStatusTextColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(Icons.menu_book_rounded, size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(surah, style: const TextStyle(fontSize: 14)),
                                  const Spacer(),
                                  Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(tanggal, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              if (status == 'wajib_sekolah' || status == 'selesai_sekolah') ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.roleMurobbiColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () {
                                      if (status == 'wajib_sekolah') {
                                        _konfirmasiAksi(
                                          title: 'Selesai di Sekolah?',
                                          message: 'Apakah Tikrar ini sudah diselesaikan di sekolah?',
                                          action: () => ref
                                              .read(tikrarProvider.notifier)
                                              .tandaiSelesaiSekolah(tikrar['id'] as String),
                                        );
                                      } else if (status == 'selesai_sekolah') {
                                        _konfirmasiAksi(
                                          title: 'Alihkan ke Rumah?',
                                          message: 'Apakah Tikrar ini ingin dialihkan ke rumah?',
                                          action: () => ref
                                              .read(tikrarProvider.notifier)
                                              .alihkanKeRumah(tikrar['id'] as String),
                                        );
                                      }
                                    },
                                    child: Text(
                                      status == 'wajib_sekolah'
                                          ? 'Selesai di Sekolah'
                                          : 'Alihkan ke Rumah',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
                    },
                  );
                },
              ),
      ),
    );
  }
}
