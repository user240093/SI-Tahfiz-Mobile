import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/tikrar_provider.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/error_state_widget.dart';

class PengampuTikrarScreen extends ConsumerStatefulWidget {
  const PengampuTikrarScreen({super.key});

  @override
  ConsumerState<PengampuTikrarScreen> createState() => _PengampuTikrarScreenState();
}

class _PengampuTikrarScreenState extends ConsumerState<PengampuTikrarScreen> {
  String? _halaqahId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final user = ref.read(authProvider);
      final userId = user?.supabaseUser?.id ?? user?.id ?? '';

      final halaqahRes = await supabase
          .from('halaqah')
          .select('id')
          .eq('pengampu_id', userId)
          .maybeSingle();

      if (halaqahRes != null) {
        _halaqahId = halaqahRes['id'] as String;
        await _refreshData();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Halaqah tidak ditemukan untuk akun ini.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Gagal memuat data halaqah. Silakan coba lagi.';
      });
    }
  }

  Future<void> _refreshData() async {
    if (_halaqahId == null) return;
    try {
      final dateStr = _selectedDate.toIso8601String().split('T')[0];
      await Future.wait([
        ref.read(tikrarPengampuProvider.notifier).fetchTikrarHalaqah(_halaqahId!),
        ref.read(manzilStatusProvider.notifier).fetchManzilStatus(_halaqahId!, dateStr),
      ]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Gagal memperbarui data.';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.roleMurobbiColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _refreshData();
    }
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
    required String successMessage,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.outfit()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.roleMurobbiColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoading = true;
      });
      final success = await onConfirm();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui status Tikrar (Mungkin status sudah berubah)'),
              backgroundColor: Colors.red,
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: buildCustomAppBar(
          context: context,
          role: 'pengampu',
          isNested: true,
          title: 'Tikrar & Manzil',
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: AppTheme.roleMurobbiColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.roleMurobbiColor,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: 'Tikrar'),
                  Tab(text: 'Status Manzil'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading && _halaqahId == null
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.roleMurobbiColor))
                  : _hasError
                      ? ErrorStateWidget(
                          message: _errorMessage,
                          onRetry: _loadData,
                        )
                      : const TabBarView(
                          children: [
                            _TikrarTab(),
                            _ManzilTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TikrarTab extends ConsumerWidget {
  const _TikrarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tikrarPengampuProvider);
    final screenState = ref.watch(tikrarPengampuProvider.notifier);
    final parentState = context.findAncestorStateOfType<_PengampuTikrarScreenState>();
    final halaqahId = parentState?._halaqahId ?? '';

    return RefreshIndicator(
      onRefresh: () async {
        if (parentState != null) {
          await parentState._refreshData();
        }
      },
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.roleMurobbiColor)),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () {
            if (parentState != null) parentState._loadData();
          },
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
                      const Icon(Icons.info_outline_rounded, size: 80, color: Color(0xFFD1D5DB)),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada Tikrar aktif',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
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
              final santri = tikrar['santri'] as Map<String, dynamic>? ?? {};
              final namaSantri = santri['nama_lengkap'] ?? 'Santri';
              final surah = tikrar['surah'] ?? '';
              final halAwal = tikrar['halaman_awal'] ?? 0;
              final halAkhir = tikrar['halaman_akhir'] ?? 0;
              final status = tikrar['status'] as String? ?? 'wajib_sekolah';
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
                          StatusBadge(status: status),
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
                            parentState?._formatDateString(tanggal) ?? tanggal,
                            style: GoogleFonts.outfit(fontSize: 14),
                          ),
                        ],
                      ),
                      if (status == 'wajib_sekolah') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.roleMurobbiColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              if (parentState != null) {
                                parentState._showConfirmationDialog(
                                  title: 'Konfirmasi Selesai',
                                  message: 'Tandai Tikrar ini selesai di sekolah?',
                                  onConfirm: () => screenState.tandaiSelesaiSekolah(tikrar['id'] as String, halaqahId),
                                  successMessage: 'Tikrar ditandai selesai di sekolah',
                                );
                              }
                            },
                            child: Text(
                              'Selesai di Sekolah',
                              style: GoogleFonts.outfit(
                                color: AppTheme.roleMurobbiColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ] else if (status == 'selesai_sekolah') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.roleMurobbiColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              if (parentState != null) {
                                parentState._showConfirmationDialog(
                                  title: 'Alihkan ke Rumah',
                                  message: 'Tikrar akan dialihkan ke rumah dan orang tua akan memvalidasi. Lanjutkan?',
                                  onConfirm: () => screenState.alihkanKeRumah(tikrar['id'] as String, halaqahId),
                                  successMessage: 'Tikrar dialihkan ke rumah',
                                );
                              }
                            },
                            child: Text(
                              'Alihkan ke Rumah',
                              style: GoogleFonts.outfit(
                                color: AppTheme.roleMurobbiColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.05);
            },
          );
        },
      ),
    );
  }
}

class _ManzilTab extends ConsumerWidget {
  const _ManzilTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manzilStatusProvider);
    final parentState = context.findAncestorStateOfType<_PengampuTikrarScreenState>();
    final formattedDate = parentState != null
        ? parentState._formatDateString(parentState._selectedDate.toIso8601String().split('T')[0])
        : '';

    return Column(
      children: [
        // Date Selector Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanggal Manzil:',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (parentState != null) {
                    parentState._selectDate(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.roleMurobbiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppTheme.roleMurobbiColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: GoogleFonts.outfit(
                          color: AppTheme.roleMurobbiColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Manzil Status List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (parentState != null) {
                await parentState._refreshData();
              }
            },
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.roleMurobbiColor)),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () {
                  if (parentState != null) parentState._loadData();
                },
              ),
              data: (manzilMap) {
                if (manzilMap.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 80, color: Color(0xFFD1D5DB)),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada setoran Manzil',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: const Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Check if all santri have null setoran (no manzil at all)
                final hasAnyManzil = manzilMap.values.any((item) => item['setoran'] != null);
                if (!hasAnyManzil) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 80, color: Color(0xFFD1D5DB)),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada setoran Manzil',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: const Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final entries = manzilMap.entries.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final String name = entry.value['nama_lengkap'] ?? '';
                    final Map<String, dynamic>? setoran = entry.value['setoran'];
                    final bool sudahManzil = setoran != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: sudahManzil
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              child: Icon(
                                sudahManzil ? Icons.check : Icons.remove,
                                color: sudahManzil ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (sudahManzil) ...[
                                    Text(
                                      'Sudah Manzil • ${setoran['jumlah_baris'] ?? 0} baris (Hal. ${setoran['halaman_awal'] ?? 0}-${setoran['halaman_akhir'] ?? 0})',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: const Color(0xFF047857),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Belum Manzil',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (30 * index).ms).slideY(begin: 0.05);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
