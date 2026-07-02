import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/ortu_provider.dart';
import '../../../core/providers/tikrar_provider.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/anak_tab_selector.dart';

class OrtuTikrarScreen extends ConsumerStatefulWidget {
  final bool isNested;
  const OrtuTikrarScreen({super.key, this.isNested = false});

  @override
  ConsumerState<OrtuTikrarScreen> createState() => _OrtuTikrarScreenState();
}

class _OrtuTikrarScreenState extends ConsumerState<OrtuTikrarScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    final realWaliId = user.supabaseUser?.id ?? user.id;
    await ref.read(tikrarOrtuProvider.notifier).fetchTikrarWajibRumah(realWaliId);
  }

  Future<void> _konfirmasiSelesai(String tikrarId, String realWaliId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Tikrar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Apakah Tikrar ini sudah diselesaikan di rumah?', style: GoogleFonts.outfit()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.roleWaliColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya, Sudah Selesai', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await ref.read(tikrarOrtuProvider.notifier).tandaiSelesaiRumah(tikrarId, realWaliId);
      
      if (mounted) {
        if (result.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status Tikrar sudah berubah, data diperbarui'),
              backgroundColor: Colors.amber,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tikrar berhasil ditandai selesai di rumah'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatDateString(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateString);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      return '$day/$month/$year';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final realWaliId = user.supabaseUser?.id ?? user.id;
    final ortuState = ref.watch(ortuProvider);
    final selectedAnakId = ortuState.selectedAnakId;
    final tikrarAsync = ref.watch(tikrarOrtuProvider);

    return Scaffold(
      appBar: widget.isNested
          ? null
          : AppBar(
              title: const Text('Tikrar Rumah'),
              backgroundColor: AppTheme.roleWaliColor,
              foregroundColor: Colors.white,
            ),
      body: ortuState.anakList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care_rounded, size: 80, color: Color(0xFFD1D5DB)),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data anak yang terkait.',
                    style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.roleWaliColor,
              child: Column(
                children: [
                  // Child Selector (if parent has > 1 kids)
                  const AnakTabSelector(),

                  // Tikrar List
                  Expanded(
                    child: tikrarAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.roleWaliColor)),
                      error: (err, _) => ErrorStateWidget(
                        message: err.toString(),
                        onRetry: _loadData,
                      ),
                      data: (tikrarList) {
                        // Filter by selected anak
                        final tikrarAnak = tikrarList.where((t) => t['santri_id'] == selectedAnakId).toList();

                        if (tikrarAnak.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.info_outline_rounded, size: 80, color: Color(0xFFD1D5DB)),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tidak ada Tikrar yang perlu diselesaikan di rumah',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          color: const Color(0xFF374151),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Bagus! Semua Tikrar sudah selesai',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: const Color(0xFF6B7280),
                                        ),
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
                          itemCount: tikrarAnak.length,
                          itemBuilder: (context, index) {
                            final tikrar = tikrarAnak[index];
                            final santri = tikrar['santri'] as Map<String, dynamic>? ?? {};
                            final namaSantri = santri['nama_lengkap'] ?? 'Santri';
                            final surah = tikrar['surah'] ?? '';
                            final halAwal = tikrar['halaman_awal'] ?? 0;
                            final halAkhir = tikrar['halaman_akhir'] ?? 0;
                            final tanggal = tikrar['tanggal'] ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
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
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const StatusBadge(status: 'wajib_rumah'),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      children: [
                                        const Icon(Icons.menu_book_rounded, size: 18, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$surah (Hlm. $halAwal-$halAkhir)',
                                          style: GoogleFonts.outfit(fontSize: 14),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatDateString(tanggal),
                                          style: GoogleFonts.outfit(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.roleWaliColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () => _konfirmasiSelesai(tikrar['id'] as String, realWaliId),
                                        child: Text(
                                          'Tandai Selesai di Rumah',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.05);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
