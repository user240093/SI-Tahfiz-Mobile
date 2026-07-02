import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/syahrul_quran_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';

class KoordinatorSyahrulQuranScreen extends ConsumerStatefulWidget {
  const KoordinatorSyahrulQuranScreen({super.key});

  @override
  ConsumerState<KoordinatorSyahrulQuranScreen> createState() => _KoordinatorSyahrulQuranScreenState();
}

class _KoordinatorSyahrulQuranScreenState extends ConsumerState<KoordinatorSyahrulQuranScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syahrulQuranProvider.notifier).fetchAll();
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
          title: const Text('Akhiri Periode?'),
          content: const Text(
            'Periode Syahrul Quran akan diakhiri sekarang. Sabki dan Manzil akan kembali aktif. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textLight)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(syahrulQuranProvider.notifier).akhiriPeriode(id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Periode Syahrul Quran telah diakhiri'),
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
    final stateAsync = ref.watch(syahrulQuranProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Syahrul Quran'),
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
                  onPressed: () => ref.read(syahrulQuranProvider.notifier).fetchAll(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          final isAktif = state.aktivPeriode != null;

          return RefreshIndicator(
            onRefresh: () => ref.read(syahrulQuranProvider.notifier).fetchAll(),
            color: AppTheme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // STATUS CARD
                if (isAktif) ...[
                  Card(
                    color: const Color(0xFFD1FAE5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFA7F3D0), width: 1.5),
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
                                  color: const Color(0xFF047857),
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
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF059669)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${_formatDate(state.aktivPeriode!['tanggal_mulai'])} - ${_formatDate(state.aktivPeriode!['tanggal_selesai'])}',
                            style: AppTextStyles.h4.copyWith(
                              color: const Color(0xFF065F46),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selama periode aktif, input Sabki dari pengampu setoran dan input Manzil dari orang tua dinonaktifkan.',
                            style: TextStyle(color: Color(0xFF065F46), fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () => _confirmAkhiriPeriode(context, state.aktivPeriode!['id']),
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
                            'Belum ada periode Syahrul Quran yang sedang berjalan hari ini.',
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

                const SizedBox(height: 28),

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

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isRowActive ? const Color(0xFFECFDF5) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isRowActive ? const Color(0xFFA7F3D0) : Colors.grey.shade200,
                          width: isRowActive ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_formatDate(start)} - ${_formatDate(end)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isRowActive ? const Color(0xFF047857) : AppTheme.textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dibuat oleh: $dibuatOleh',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isRowActive ? const Color(0xFF065F46).withOpacity(0.7) : AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isRowActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF047857),
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
    // Clear hours to allow selecting today even if it's already noon
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
        // Adjust tanggal selesai if it is before tanggal mulai
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

      await ref.read(syahrulQuranProvider.notifier).tetapkanPeriode(mulaiStr, selesaiStr, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Periode Syahrul Quran berhasil ditetapkan'),
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
          
          // Tanggal Mulai Picker Card
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

          // Tanggal Selesai Picker Card
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
