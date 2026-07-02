import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/ortu_provider.dart';
import '../../../core/providers/setoran_provider.dart';
import '../../../core/providers/tikrar_provider.dart';
import '../../../core/providers/absensi_provider.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/anak_tab_selector.dart';
import '../../../core/widgets/status_badge.dart';

class OrtuBerandaScreen extends ConsumerStatefulWidget {
  const OrtuBerandaScreen({super.key});

  @override
  ConsumerState<OrtuBerandaScreen> createState() => _OrtuBerandaScreenState();
}

class _OrtuBerandaScreenState extends ConsumerState<OrtuBerandaScreen> {
  RealtimeChannel? _alphaChannel;

  @override
  void initState() {
    super.initState();
    _subscribeToAlphaNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = ref.read(authProvider);
    if (user == null) return;
    final userId = user.supabaseUser?.id ?? user.id;

    ref.read(ortuProvider.notifier).loadAnakList(userId);
    ref.read(tikrarOrtuProvider.notifier).fetchTikrarWajibRumah(userId);
    ref.read(setoranProvider.notifier).fetchSetoran();
    ref.read(allAbsensiProvider.notifier).fetchAbsensi();
  }

  void _subscribeToAlphaNotification() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _alphaChannel = Supabase.instance.client
        .channel('notif-ortu-$userId')
        .onBroadcast(
          event: 'alpha_notification',
          callback: (payload) {
            final santriNama = payload['santri_nama'] as String;
            final tanggal = payload['tanggal'] as String;
            _showAlphaBanner(santriNama, tanggal);
            // Refresh attendance data on notification
            ref.read(allAbsensiProvider.notifier).fetchAbsensi();
          },
        );
    _alphaChannel?.subscribe();
  }

  void _showAlphaBanner(String santriNama, String tanggal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠ $santriNama tidak hadir (Alpha) pada $tanggal'),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _alphaChannel?.unsubscribe();
    super.dispose();
  }

  Widget _buildGradeBadge(String? grade) {
    final cleanGrade = (grade ?? '').toLowerCase();
    Color bgColor;
    Color textColor;
    String label;

    switch (cleanGrade) {
      case 'tahsin':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        label = 'Tahsin';
        break;
      case 'takmil':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        label = 'Takmil';
        break;
      case 'tahfiz':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        label = 'Tahfiz';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = grade ?? '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final ortuState = ref.watch(ortuProvider);
    final selectedAnakId = ortuState.selectedAnakId;

    if (selectedAnakId == null) {
      if (ortuState.anakList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(
          'Tidak ada data anak yang terkait.',
          style: AppTextStyles.body.copyWith(color: Colors.grey),
        ),
      );
    }

    final selectedAnak = ortuState.anakList.firstWhere(
      (a) => a['id'] == selectedAnakId,
      orElse: () => {},
    );

    if (selectedAnak.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final String namaAnak = selectedAnak['nama_lengkap'] ?? '';
    final String kelasAnak = selectedAnak['kelas'] ?? '-';
    final String? gradeAnak = selectedAnak['grade'];
    final halaqah = selectedAnak['halaqah'] as Map<String, dynamic>?;
    final String namaHalaqah = halaqah?['nama_halaqah'] ?? 'Tanpa Halaqah';
    final pengampu = halaqah?['profiles'] as Map<String, dynamic>?;
    final String namaPengampu = pengampu?['nama_lengkap'] ?? 'Belum Ditentukan';

    // Watch values for specific cards
    final setoranAsync = ref.watch(setoranForSantriProvider(selectedAnakId));
    final tikrarAsync = ref.watch(tikrarOrtuProvider);
    final absensiAsync = ref.watch(absensiForSantriProvider(selectedAnakId));

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // 1. Anak Tab Selector at top (hidden if only 1 child)
          const AnakTabSelector(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. Info Santri Card
                AppCard(
                  role: 'orang_tua',
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                        child: Text(
                          namaAnak.isNotEmpty ? namaAnak[0].toUpperCase() : '?',
                          style: AppTextStyles.h3.copyWith(color: const Color(0xFF10B981)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(namaAnak, style: AppTextStyles.h3),
                            const SizedBox(height: 2),
                            Text('Kelas: $kelasAnak', style: AppTextStyles.bodySmall),
                            Text('Halaqah: $namaHalaqah', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                            Text('Murobbi: $namaPengampu', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                            const SizedBox(height: 8),
                            _buildGradeBadge(gradeAnak),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // 3. Card: Rekap Setoran Today
                AppCard(
                  role: 'orang_tua',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Setoran Hari Ini', style: AppTextStyles.h4),
                      const Divider(),
                      const SizedBox(height: 8),
                      setoranAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Gagal memuat status setoran: $err'),
                        data: (setoranList) {
                          final todayStr = DateTime.now().toIso8601String().split('T')[0];
                          final sudahManzil = setoranList.any(
                            (s) => s['tipe'] == 'manzil' && s['tanggal'] == todayStr,
                          );

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Manzil (Setoran Mandiri)",
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                              ),
                              StatusBadge(status: sudahManzil ? 'sudah' : 'belum'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // 4. Card: Tikrar Aktif Count
                AppCard(
                  role: 'orang_tua',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tugas Tikrar Aktif', style: AppTextStyles.h4),
                      const Divider(),
                      const SizedBox(height: 8),
                      tikrarAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Gagal memuat tikrar: $err'),
                        data: (tikrarList) {
                          final count = tikrarList.where(
                            (t) => t['santri_id'] == selectedAnakId && t['status'] == 'wajib_rumah',
                          ).length;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Wajib Diselesaikan di Rumah",
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: count > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "$count Tikrar",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 16),

                // 5. Card: Absensi Bulan Ini
                AppCard(
                  role: 'orang_tua',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rekap Kehadiran Bulan Ini', style: AppTextStyles.h4),
                      const Divider(),
                      const SizedBox(height: 12),
                      absensiAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Gagal memuat absensi: $err'),
                        data: (absensiList) {
                          final now = DateTime.now();
                          final currentMonth = now.month;
                          final currentYear = now.year;

                          int alphaCount = 0;
                          int sakitCount = 0;
                          int izinCount = 0;

                          for (var abs in absensiList) {
                            final tglStr = abs['tanggal'] as String?;
                            if (tglStr != null) {
                              final tgl = DateTime.tryParse(tglStr);
                              if (tgl != null && tgl.month == currentMonth && tgl.year == currentYear) {
                                final status = abs['status']?.toString().toLowerCase();
                                if (status == 'alpha') {
                                  alphaCount++;
                                } else if (status == 'sakit') {
                                  sakitCount++;
                                } else if (status == 'izin') {
                                  izinCount++;
                                }
                              }
                            }
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildAbsensiStatItem("Alpha", alphaCount, const Color(0xFFEF4444)),
                              _buildAbsensiStatItem("Sakit", sakitCount, Colors.orange),
                              _buildAbsensiStatItem("Izin", izinCount, Colors.blue),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: AppTextStyles.h2.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
