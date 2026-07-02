import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pekan_murajaah_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';

class KoordinatorPekanMurajaahScreen extends ConsumerStatefulWidget {
  const KoordinatorPekanMurajaahScreen({super.key});

  @override
  ConsumerState<KoordinatorPekanMurajaahScreen> createState() => _KoordinatorPekanMurajaahScreenState();
}

class _KoordinatorPekanMurajaahScreenState extends ConsumerState<KoordinatorPekanMurajaahScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pekanMurajaahProvider.notifier).fetchAll();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {
        return dateStr;
      }
    }
  }

  void _showTetapkanPeriodeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _TetapkanPeriodeModal();
      },
    );
  }

  void _confirmAkhiriPeriode(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Akhiri Pekan Murajaah?'),
          content: const Text('Pekan Murajaah akan diakhiri sekarang. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textLight)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(pekanMurajaahProvider.notifier).akhiriPeriode(id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pekan Murajaah telah diakhiri'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengakhiri periode: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Akhiri'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(pekanMurajaahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pekan Murajaah'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text('Terjadi kesalahan: $e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(pekanMurajaahProvider.notifier).fetchAll(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          final isAktif = state.aktivPekan != null;
          List<dynamic> activeTargets = [];

          if (isAktif) {
            final activeInHistory = state.riwayat.firstWhere(
              (item) => item['id'] == state.aktivPekan!['id'],
              orElse: () => <String, dynamic>{},
            );
            activeTargets = activeInHistory['target_murajaah'] as List? ?? [];
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(pekanMurajaahProvider.notifier).fetchAll(),
            color: AppTheme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // STATUS CARD
                if (isAktif) ...[
                  Card(
                    color: const Color(0xFFFEF3C7), // Light orange #FEF3C7
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706), // Orange badge
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Periode Aktif',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(Icons.star_rounded, color: Color(0xFFD97706)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${_formatDate(state.aktivPekan!['tanggal_mulai'])} - ${_formatDate(state.aktivPekan!['tanggal_selesai'])}',
                            style: AppTextStyles.h4.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Target Murajaah per Halaqah:',
                            style: AppTextStyles.h5.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (activeTargets.isEmpty)
                            const Text(
                              'Belum ada target harian yang diinput oleh pengampu.',
                              style: TextStyle(color: Color(0xFF92400E), fontSize: 13, fontStyle: FontStyle.italic),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activeTargets.length,
                              itemBuilder: (context, idx) {
                                final target = activeTargets[idx];
                                final halaqahName = target['halaqah']?['nama_halaqah'] ?? 'Halaqah';
                                final baris = target['target_baris_per_hari'] ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFFD97706)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '$halaqahName: $baris baris/hari',
                                          style: const TextStyle(
                                            color: Color(0xFF92400E),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () => _confirmAkhiriPeriode(context, state.aktivPekan!['id']),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                              side: const BorderSide(color: AppTheme.errorColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Akhiri Periode Sekarang',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ] else ...[
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  'Tidak ada periode aktif',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(Icons.info_outline_rounded, color: Colors.grey.shade400),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada Pekan Murajaah yang sedang berjalan hari ini.',
                            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _showTetapkanPeriodeModal(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Tetapkan Periode Baru',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ],

                const SizedBox(height: 16),

                // INFO BOX
                Card(
                  color: const Color(0xFFEFF6FF), // Light blue #EFF6FF
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_rounded, color: Color(0xFF3B82F6), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prosedur Pekan Murajaah',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Setelah menetapkan periode, informasikan target harian ke masing-masing pengampu. Pengampu akan menginput target di halaman setoran mereka.',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 24),

                // RIWAYAT SECTION
                Row(
                  children: [
                    const Icon(Icons.history_rounded, color: AppTheme.textLight, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Riwayat Periode',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (state.riwayat.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          const Text(
                            'Belum ada riwayat periode.',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.riwayat.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    
                    // Check if today falls in this period to mark active in history
                    final todayStr = DateTime.now().toIso8601String().split('T')[0];
                    final start = item['tanggal_mulai'] as String;
                    final end = item['tanggal_selesai'] as String;
                    final isRowActive = todayStr.compareTo(start) >= 0 && todayStr.compareTo(end) <= 0;

                    final dibuatOleh = item['profiles']?['nama_lengkap'] ?? '-';
                    final targetsList = item['target_murajaah'] as List? ?? [];

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isRowActive ? const Color(0xFFFEF3C7) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isRowActive ? const Color(0xFFFDE68A) : Colors.grey.shade200,
                          width: isRowActive ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_formatDate(start)} - ${_formatDate(end)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isRowActive ? const Color(0xFF92400E) : AppTheme.textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (isRowActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Aktif',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Dibuat oleh: $dibuatOleh',
                              style: TextStyle(
                                fontSize: 12,
                                color: isRowActive ? const Color(0xFF92400E).withOpacity(0.7) : AppTheme.textLight,
                              ),
                            ),
                            if (targetsList.isNotEmpty) ...[
                              const Divider(height: 16),
                              Text(
                                'Target: ${targetsList.length} Halaqah telah diisi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isRowActive ? const Color(0xFF92400E) : AppTheme.textLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (idx * 50).ms);
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TetapkanPeriodeModal extends ConsumerStatefulWidget {
  const _TetapkanPeriodeModal();

  @override
  ConsumerState<_TetapkanPeriodeModal> createState() => _TetapkanPeriodeModalState();
}

class _TetapkanPeriodeModalState extends ConsumerState<_TetapkanPeriodeModal> {
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isSaving = false;

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  Future<void> _selectTanggalMulai(BuildContext context) async {
    final today = DateTime.now();
    final initialDate = _tanggalMulai ?? today;
    final firstDate = DateTime(today.year, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;
        if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(_tanggalMulai!)) {
          _tanggalSelesai = _tanggalMulai;
        }
      });
    }
  }

  Future<void> _selectTanggalSelesai(BuildContext context) async {
    final today = DateTime.now();
    final firstDate = _tanggalMulai ?? DateTime(today.year, today.month, today.day);
    final initialDate = _tanggalSelesai ?? firstDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalSelesai = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field tanggal wajib diisi'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh lebih awal dari tanggal mulai'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final currentUser = ref.read(authProvider);
      final userId = currentUser?.supabaseUser?.id ?? currentUser?.id ?? '';
      
      final mulaiStr = _tanggalMulai!.toIso8601String().split('T')[0];
      final selesaiStr = _tanggalSelesai!.toIso8601String().split('T')[0];

      await ref.read(pekanMurajaahProvider.notifier).tetapkanPeriode(mulaiStr, selesaiStr, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pekan Murajaah berhasil ditetapkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tetapkan Periode Baru',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),
          
          // Tanggal Mulai
          const Text(
            'Tanggal Mulai',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectTanggalMulai(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tanggalMulai != null ? _dateFormat.format(_tanggalMulai!) : 'Pilih Tanggal Mulai',
                    style: TextStyle(
                      color: _tanggalMulai != null ? AppTheme.textDark : Colors.grey.shade400,
                      fontWeight: _tanggalMulai != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tanggal Selesai
          const Text(
            'Tanggal Selesai',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectTanggalSelesai(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tanggalSelesai != null ? _dateFormat.format(_tanggalSelesai!) : 'Pilih Tanggal Selesai',
                    style: TextStyle(
                      color: _tanggalSelesai != null ? AppTheme.textDark : Colors.grey.shade400,
                      fontWeight: _tanggalSelesai != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
