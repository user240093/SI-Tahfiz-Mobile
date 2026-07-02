import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/konfigurasi_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';

class TuKonfigurasiScreen extends ConsumerWidget {
  const TuKonfigurasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(konfigurasiProvider);

    return Scaffold(
      body: stateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gagal memuat konfigurasi', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              Text(err.toString(), style: AppTextStyles.bodySmall),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(konfigurasiProvider.notifier).fetchKonfigurasi(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (stateData) {
          if (stateData.konfigurasi == null) {
            return const Center(child: Text('Data konfigurasi tidak tersedia.'));
          }
          return _KonfigurasiForm(stateData: stateData);
        },
      ),
    );
  }
}

class _KonfigurasiForm extends ConsumerStatefulWidget {
  final KonfigurasiState stateData;
  const _KonfigurasiForm({required this.stateData});

  @override
  ConsumerState<_KonfigurasiForm> createState() => _KonfigurasiFormState();
}

class _KonfigurasiFormState extends ConsumerState<_KonfigurasiForm> {
  // Section 1: Tanggal Semester
  DateTime? _mulaiGanjil;
  DateTime? _selesaiGanjil;
  DateTime? _mulaiGenap;
  DateTime? _selesaiGenap;

  // Section 2: Bobot Nilai
  final _setoranCtrl = TextEditingController();
  final _uasCtrl = TextEditingController();
  final _akhlaqCtrl = TextEditingController();
  final _kehadiranCtrl = TextEditingController();
  int _totalBobot = 100;

  // Section 3: Maintenance Mode
  bool _maintenanceMode = false;

  bool _isSavingDates = false;
  bool _isSavingWeights = false;

  @override
  void initState() {
    super.initState();
    _initFields();

    // Listeners for live bobot total
    _setoranCtrl.addListener(_calculateTotalBobot);
    _uasCtrl.addListener(_calculateTotalBobot);
    _akhlaqCtrl.addListener(_calculateTotalBobot);
    _kehadiranCtrl.addListener(_calculateTotalBobot);
  }

  void _initFields() {
    final config = widget.stateData.konfigurasi!;
    _mulaiGanjil = config['tanggal_mulai_ganjil'] != null
        ? DateTime.parse(config['tanggal_mulai_ganjil'])
        : null;
    _selesaiGanjil = config['tanggal_selesai_ganjil'] != null
        ? DateTime.parse(config['tanggal_selesai_ganjil'])
        : null;
    _mulaiGenap = config['tanggal_mulai_genap'] != null
        ? DateTime.parse(config['tanggal_mulai_genap'])
        : null;
    _selesaiGenap = config['tanggal_selesai_genap'] != null
        ? DateTime.parse(config['tanggal_selesai_genap'])
        : null;

    _setoranCtrl.text = (config['bobot_setoran'] ?? 0).toString();
    _uasCtrl.text = (config['bobot_uas'] ?? 0).toString();
    _akhlaqCtrl.text = (config['bobot_akhlaq'] ?? 0).toString();
    _kehadiranCtrl.text = (config['bobot_kehadiran'] ?? 0).toString();

    _maintenanceMode = config['maintenance_mode'] ?? false;
    _calculateTotalBobot();
  }

  @override
  void didUpdateWidget(covariant _KonfigurasiForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data changes in the background, refresh the maintenance mode toggle
    final newConfig = widget.stateData.konfigurasi;
    if (newConfig != null) {
      final oldConfig = oldWidget.stateData.konfigurasi;
      if (oldConfig == null || newConfig['maintenance_mode'] != oldConfig['maintenance_mode']) {
        setState(() {
          _maintenanceMode = newConfig['maintenance_mode'] ?? false;
        });
      }
    }
  }

  @override
  void dispose() {
    _setoranCtrl.dispose();
    _uasCtrl.dispose();
    _akhlaqCtrl.dispose();
    _kehadiranCtrl.dispose();
    super.dispose();
  }

  void _calculateTotalBobot() {
    final s = int.tryParse(_setoranCtrl.text) ?? 0;
    final u = int.tryParse(_uasCtrl.text) ?? 0;
    final a = int.tryParse(_akhlaqCtrl.text) ?? 0;
    final k = int.tryParse(_kehadiranCtrl.text) ?? 0;
    setState(() {
      _totalBobot = s + u + a + k;
    });
  }

  String _formatDateString(DateTime? dt) {
    if (dt == null) return 'Pilih Tanggal';
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    DateTime initialDate = DateTime.now();
    if (field == 'mulaiGanjil' && _mulaiGanjil != null) initialDate = _mulaiGanjil!;
    if (field == 'selesaiGanjil' && _selesaiGanjil != null) initialDate = _selesaiGanjil!;
    if (field == 'mulaiGenap' && _mulaiGenap != null) initialDate = _mulaiGenap!;
    if (field == 'selesaiGenap' && _selesaiGenap != null) initialDate = _selesaiGenap!;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
        if (field == 'mulaiGanjil') _mulaiGanjil = picked;
        if (field == 'selesaiGanjil') _selesaiGanjil = picked;
        if (field == 'mulaiGenap') _mulaiGenap = picked;
        if (field == 'selesaiGenap') _selesaiGenap = picked;
      });
    }
  }

  Future<void> _saveTanggalSemester() async {
    if (_mulaiGanjil == null ||
        _selesaiGanjil == null ||
        _mulaiGenap == null ||
        _selesaiGenap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field tanggal wajib diisi'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selesaiGanjil!.isBefore(_mulaiGanjil!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh lebih awal dari tanggal mulai'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selesaiGenap!.isBefore(_mulaiGenap!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh lebih awal dari tanggal mulai'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSavingDates = true);
    try {
      await ref.read(konfigurasiProvider.notifier).updateTanggalSemester({
        'tanggal_mulai_ganjil': _mulaiGanjil!.toIso8601String().substring(0, 10),
        'tanggal_selesai_ganjil': _selesaiGanjil!.toIso8601String().substring(0, 10),
        'tanggal_mulai_genap': _mulaiGenap!.toIso8601String().substring(0, 10),
        'tanggal_selesai_genap': _selesaiGenap!.toIso8601String().substring(0, 10),
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfigurasi tanggal semester berhasil disimpan'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingDates = false);
    }
  }

  Future<void> _saveBobotNilai() async {
    final s = int.tryParse(_setoranCtrl.text);
    final u = int.tryParse(_uasCtrl.text);
    final a = int.tryParse(_akhlaqCtrl.text);
    final k = int.tryParse(_kehadiranCtrl.text);

    if (s == null || u == null || a == null || k == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field bobot wajib diisi'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (s < 0 || u < 0 || a < 0 || k < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bobot tidak valid (tidak boleh negatif)'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_totalBobot != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total bobot harus 100%'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSavingWeights = true);
    try {
      await ref.read(konfigurasiProvider.notifier).updateBobotNilai({
        'bobot_setoran': s,
        'bobot_uas': u,
        'bobot_akhlaq': a,
        'bobot_kehadiran': k,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfigurasi bobot nilai berhasil disimpan'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingWeights = false);
    }
  }

  Future<void> _toggleMaintenance(bool newValue) async {
    final message = newValue
        ? 'Seluruh pengguna selain TU akan diarahkan ke halaman maintenance. Lanjutkan?'
        : 'Maintenance mode akan dinonaktifkan. Pengguna dapat kembali mengakses sistem. Lanjutkan?';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Maintenance Mode', style: AppTextStyles.h4),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya, ${newValue ? "Aktifkan" : "Nonaktifkan"}',
                style: TextStyle(color: newValue ? AppTheme.errorColor : AppTheme.primaryColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(konfigurasiProvider.notifier).updateMaintenanceMode(newValue);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maintenance mode ${newValue ? "aktif" : "nonaktif"}'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah maintenance mode: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        setState(() {
          _maintenanceMode = !newValue; // revert toggle
        });
      }
    } else {
      setState(() {
        _maintenanceMode = !newValue; // revert toggle
      });
    }
  }

  void _showAddHolidayModal() {
    DateTime? chosenDate;
    final ketCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Tambah Hari Libur', style: AppTextStyles.h4),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: isSaving
                        ? null
                        : () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppTheme.primaryColor,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                chosenDate = picked;
                              });
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chosenDate == null ? 'Pilih Tanggal' : _formatDateString(chosenDate),
                            style: TextStyle(
                              color: chosenDate == null ? Colors.grey : AppTheme.textDark,
                            ),
                          ),
                          const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Keterangan / Nama Hari Libur', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextField(
                    controller: ketCtrl,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      hintText: 'Misal: Idul Fitri, Libur Semester',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (chosenDate == null || ketCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tanggal dan keterangan wajib diisi'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          try {
                            final dateStr = chosenDate!.toIso8601String().substring(0, 10);
                            await ref.read(konfigurasiProvider.notifier).addHariLibur(
                                  dateStr,
                                  ketCtrl.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hari libur berhasil ditambahkan'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            }
                          } catch (e) {
                            String errorMsg = 'Gagal menambahkan hari libur';
                            if (e.toString().contains('23505')) {
                              errorMsg = 'Tanggal ini sudah terdaftar sebagai hari libur';
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          } finally {
                            setModalState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteHolidayDialog(String id, String dateStr, String desc) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Hapus Hari Libur', style: AppTextStyles.h4),
              content: Text('Apakah Anda yakin ingin menghapus hari libur "$desc" pada tanggal $dateStr?'),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await ref.read(konfigurasiProvider.notifier).deleteHariLibur(id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hari libur berhasil dihapus'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus: $e'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => isDeleting = false);
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text('Konfigurasi Sistem', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Kelola konfigurasi semester, bobot nilai, mode pemeliharaan, dan hari libur sekolah.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),

          // SECTION 1: Tanggal Semester
          _buildSectionHeader('Tanggal Semester'),
          AppCard(
            role: 'tu',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semester Ganjil', style: AppTextStyles.h5),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Mulai', style: AppTextStyles.label),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectDate(context, 'mulaiGanjil'),
                            child: _buildDateDisplay(_mulaiGanjil),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Selesai', style: AppTextStyles.label),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectDate(context, 'selesaiGanjil'),
                            child: _buildDateDisplay(_selesaiGanjil),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Semester Genap', style: AppTextStyles.h5),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Mulai', style: AppTextStyles.label),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectDate(context, 'mulaiGenap'),
                            child: _buildDateDisplay(_mulaiGenap),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Selesai', style: AppTextStyles.label),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectDate(context, 'selesaiGenap'),
                            child: _buildDateDisplay(_selesaiGenap),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSavingDates ? null : _saveTanggalSemester,
                    child: _isSavingDates
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan Konfigurasi Tanggal'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: Bobot Nilai Akhir
          _buildSectionHeader('Bobot Nilai Akhir (%)'),
          AppCard(
            role: 'tu',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberInput('Setoran Harian', _setoranCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberInput('UAS', _uasCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberInput('Akhlaq', _akhlaqCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberInput('Kehadiran', _kehadiranCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: $_totalBobot% (harus 100%)',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _totalBobot == 100 ? Colors.green.shade700 : AppTheme.errorColor,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isSavingWeights ? null : _saveBobotNilai,
                      child: _isSavingWeights
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan Bobot'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 3: Maintenance Mode
          _buildSectionHeader('Maintenance Mode'),
          AppCard(
            role: 'tu',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _maintenanceMode ? 'Aktif' : 'Tidak Aktif',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _maintenanceMode ? AppTheme.errorColor : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mengarahkan non-TU ke halaman pemeliharaan.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                Switch(
                  value: _maintenanceMode,
                  onChanged: (val) {
                    setState(() {
                      _maintenanceMode = val;
                    });
                    _toggleMaintenance(val);
                  },
                  activeColor: AppTheme.errorColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 4: Hari Libur
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Hari Libur Sekolah'),
              TextButton.icon(
                onPressed: _showAddHolidayModal,
                icon: const Icon(Icons.add, color: AppTheme.primaryColor),
                label: const Text('Tambah Hari Libur', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (widget.stateData.hariLibur.isEmpty)
            AppCard(
              role: 'tu',
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Belum ada hari libur terdaftar.', style: TextStyle(color: Colors.grey)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stateData.hariLibur.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.stateData.hariLibur[index];
                final id = item['id'].toString();
                final date = DateTime.parse(item['tanggal']);
                final dateStr = _formatDateString(date);
                final desc = item['keterangan'].toString();

                return AppCard(
                  role: 'tu',
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(desc, style: AppTextStyles.h5),
                            const SizedBox(height: 2),
                            Text(dateStr, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteHolidayDialog(id, dateStr, desc),
                        icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildDateDisplay(DateTime? dt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _formatDateString(dt),
              style: TextStyle(
                color: dt == null ? Colors.grey : AppTheme.textDark,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '0',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
