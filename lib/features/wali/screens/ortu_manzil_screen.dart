import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/ortu_provider.dart';
import '../../../core/providers/setoran_provider.dart';
import '../../../core/providers/syahrul_quran_provider.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../../../core/widgets/anak_tab_selector.dart';

final ortuSyahrulQuranProvider = StateProvider<bool>((ref) => false);

class OrtuManzilScreen extends ConsumerStatefulWidget {
  const OrtuManzilScreen({super.key});

  @override
  ConsumerState<OrtuManzilScreen> createState() => _OrtuManzilScreenState();
}

class _OrtuManzilScreenState extends ConsumerState<OrtuManzilScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isActionLoading = false;
  List<Map<String, dynamic>> _riwayatList = [];
  Map<String, dynamic>? _existingManzil;

  final _formKey = GlobalKey<FormState>();
  final _barisController = TextEditingController();
  final _awalController = TextEditingController();
  final _akhirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSyahrulQuran();
      _loadData();
    });
  }

  @override
  void dispose() {
    _barisController.dispose();
    _awalController.dispose();
    _akhirController.dispose();
    super.dispose();
  }

  Future<void> _checkSyahrulQuran() async {
    final isSyahrulQuran = await ref.read(syahrulQuranProvider.notifier).checkAktif();
    if (mounted) {
      ref.read(ortuSyahrulQuranProvider.notifier).state = isSyahrulQuran;
    }
  }

  Future<void> _loadData() async {
    final selectedAnakId = ref.read(ortuProvider).selectedAnakId;
    if (selectedAnakId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final formattedDate = _selectedDate.toIso8601String().split('T')[0];

      // 1. Fetch Existing Manzil on selected date
      final existingRes = await supabase
          .from('setoran')
          .select('*')
          .eq('santri_id', selectedAnakId)
          .eq('tipe', 'manzil')
          .eq('tanggal', formattedDate)
          .maybeSingle();

      _existingManzil = existingRes;

      if (_existingManzil != null) {
        _barisController.text = _existingManzil!['jumlah_baris'].toString();
        _awalController.text = _existingManzil!['halaman_awal'].toString();
        _akhirController.text = _existingManzil!['halaman_akhir'].toString();
      } else {
        _barisController.clear();
        _awalController.clear();
        _akhirController.clear();
      }

      // 2. Fetch Riwayat Manzil
      final riwayatRes = await ref.read(setoranProvider.notifier).fetchManzilByAnak(selectedAnakId);
      _riwayatList = riwayatRes;
    } catch (e) {
      debugPrint('Error loading manzil data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.roleWaliColor,
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
      _loadData();
    }
  }

  Future<void> _save() async {
    final selectedAnakId = ref.read(ortuProvider).selectedAnakId;
    if (selectedAnakId == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isActionLoading = true;
    });

    final currentUser = ref.read(authProvider);
    final inputOleh = currentUser?.supabaseUser?.id ?? currentUser?.id ?? '';
    final formattedDate = _selectedDate.toIso8601String().split('T')[0];

    try {
      final res = await ref.read(setoranProvider.notifier).upsertManzil(
            santriId: selectedAnakId,
            tanggal: formattedDate,
            jumlahBaris: int.parse(_barisController.text),
            halamanAwal: int.parse(_awalController.text),
            halamanAkhir: int.parse(_akhirController.text),
            inputOleh: inputOleh,
          );

      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Setoran Manzil berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadData();
      } else {
        throw Exception(res['error'] ?? 'Gagal menyimpan');
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
          _isActionLoading = false;
        });
      }
    }
  }

  void _editFromRiwayat(Map<String, dynamic> item) {
    setState(() {
      _selectedDate = DateTime.parse(item['tanggal'] as String);
      _barisController.text = item['jumlah_baris'].toString();
      _awalController.text = item['halaman_awal'].toString();
      _akhirController.text = item['halaman_akhir'].toString();
      _existingManzil = item;
    });
    // Scroll up to form
    Scrollable.ensureVisible(
      _formKey.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String? _validateRequiredInt(String? val, String fieldName) {
    if (val == null || val.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    final parsed = int.tryParse(val);
    if (parsed == null) {
      return '$fieldName harus angka';
    }
    return null;
  }

  String? _validatePositiveInt(String? val, String fieldName) {
    final check = _validateRequiredInt(val, fieldName);
    if (check != null) return check;
    final parsed = int.parse(val!);
    if (parsed <= 0) {
      return '$fieldName harus > 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final ortuState = ref.watch(ortuProvider);
    final isSyahrulQuran = ref.watch(ortuSyahrulQuranProvider);

    // Listen to changes to re-fetch manzil data for the switched kid context
    ref.listen<OrtuState>(ortuProvider, (previous, next) {
      if (previous?.selectedAnakId != next.selectedAnakId) {
        _loadData();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manzil'),
        backgroundColor: AppTheme.roleWaliColor,
        foregroundColor: Colors.white,
      ),
      body: ortuState.anakList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Tidak ada data anak yang terkait.', style: TextStyle(color: AppTheme.textLight)),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Child Selector (if > 1 kids)
                  const AnakTabSelector(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // If Syahrul Quran is active
                        if (isSyahrulQuran) ...[
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppTheme.warningColor.withOpacity(0.4)),
                            ),
                            color: AppTheme.warningColor.withOpacity(0.05),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Setoran Manzil tidak tersedia selama periode Syahrul Quran',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.warningColor.withOpacity(0.9),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(),
                          const SizedBox(height: 28),
                        ] else ...[
                          // Input Form
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _existingManzil != null ? 'Edit Manzil' : 'Input Manzil',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.roleWaliColor,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.calendar_month, color: AppTheme.roleWaliColor),
                                          onPressed: () => _selectDate(context),
                                          tooltip: 'Pilih Tanggal',
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    
                                    // Date Display
                                    Row(
                                      children: [
                                        const Text('Tanggal: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                        Text(
                                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.roleWaliColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _awalController,
                                            decoration: const InputDecoration(labelText: 'Halaman Awal'),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            validator: (val) => _validatePositiveInt(val, 'Halaman awal'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _akhirController,
                                            decoration: const InputDecoration(labelText: 'Halaman Akhir'),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            validator: (val) {
                                              final check = _validatePositiveInt(val, 'Halaman akhir');
                                              if (check != null) return check;
                                              final awal = int.tryParse(_awalController.text) ?? 0;
                                              final akhir = int.parse(val!);
                                              if (akhir < awal) {
                                                return 'Halaman akhir tidak valid';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _barisController,
                                      decoration: const InputDecoration(labelText: 'Jumlah Baris'),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Jumlah baris wajib diisi';
                                        }
                                        return _validatePositiveInt(val, 'Jumlah baris');
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.roleWaliColor,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: _isActionLoading ? null : _save,
                                      child: _isActionLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : Text(
                                              _existingManzil != null ? 'Perbarui' : 'Simpan',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(),
                          const SizedBox(height: 28),
                        ],

                        // History (Riwayat) Section
                        Text(
                          'Riwayat Manzil',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.roleWaliColor))
                            : _riwayatList.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: const Text(
                                      'Belum ada riwayat setoran Manzil.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _riwayatList.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = _riwayatList[index];
                                      final dateStr = item['tanggal'] as String? ?? '';
                                      final awal = item['halaman_awal'] ?? '';
                                      final akhir = item['halaman_akhir'] ?? '';
                                      final baris = item['jumlah_baris'] ?? '';

                                      return Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          leading: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppTheme.roleWaliColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.history_rounded, color: AppTheme.roleWaliColor),
                                          ),
                                          title: Text(
                                            'Hlm $awal - $akhir',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            'Tanggal: $dateStr | Baris: $baris',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                          ),
                                          trailing: isSyahrulQuran
                                              ? null
                                              : IconButton(
                                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.roleWaliColor),
                                                  onPressed: () => _editFromRiwayat(item),
                                                  tooltip: 'Edit Record',
                                                ),
                                        ),
                                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
                                    },
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
