import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/setoran_provider.dart';
import '../../../core/providers/syahrul_quran_provider.dart';
import '../../../core/providers/pekan_murajaah_provider.dart';
import '../../../core/providers/target_murajaah_provider.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';

final setoranSyahrulQuranProvider = StateProvider<bool>((ref) => false);

class PengampuSetoranScreen extends ConsumerStatefulWidget {
  const PengampuSetoranScreen({super.key});

  @override
  ConsumerState<PengampuSetoranScreen> createState() => _PengampuSetoranScreenState();
}

class _PengampuSetoranScreenState extends ConsumerState<PengampuSetoranScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<Map<String, dynamic>> _santriList = [];
  List<Map<String, dynamic>> _existingSetoranList = [];
  String? _halaqahId;
  Map<String, dynamic>? _aktivPekan;
  int? _targetBarisPerHari;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _checkSyahrulQuran() async {
    final isSyahrulQuran = await ref.read(syahrulQuranProvider.notifier).checkAktif();
    ref.read(setoranSyahrulQuranProvider.notifier).state = isSyahrulQuran;
  }

  void _showSetTargetDialog() {
    final controller = TextEditingController(text: _targetBarisPerHari?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Set Target Murajaah'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Target Baris per Hari',
                hintText: 'Sesuai arahan koordinator',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Target wajib diisi';
                }
                final parsed = int.tryParse(val);
                if (parsed == null || parsed <= 0) {
                   return 'Target harus > 0';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textLight)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final val = int.parse(controller.text);
                Navigator.pop(context);
                
                try {
                  await ref.read(targetMurajaahProvider.notifier).upsertTarget(
                    _aktivPekan!['id'] as String,
                    _halaqahId!,
                    val,
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Target Murajaah berhasil disimpan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  _loadData();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan target: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.roleMurobbiColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _checkSyahrulQuran();

      final user = ref.read(authProvider);
      final userId = user?.supabaseUser?.id ?? user?.id ?? '';
      
      final halaqahRes = await supabase
          .from('halaqah')
          .select('id')
          .eq('pengampu_id', userId)
          .maybeSingle();

      if (halaqahRes != null) {
        _halaqahId = halaqahRes['id'] as String;
        
        // Check if Pekan Murajaah is active today
        _aktivPekan = await ref.read(pekanMurajaahProvider.notifier).checkAktif();
        _targetBarisPerHari = null;
        if (_aktivPekan != null) {
          final targetRes = await ref.read(targetMurajaahProvider.notifier).fetchTarget(_aktivPekan!['id'] as String, _halaqahId!);
          if (targetRes != null) {
            _targetBarisPerHari = (targetRes['target_baris_per_hari'] as num?)?.toInt();
          }
        }

        final santriRes = await supabase
            .from('santri')
            .select('id, nama_lengkap')
            .eq('halaqah_id', _halaqahId!)
            .order('nama_lengkap');
        
        _santriList = List<Map<String, dynamic>>.from(santriRes);
        
        if (_santriList.isNotEmpty) {
          final santriIds = _santriList.map((s) => s['id'] as String).toList();
          final formattedDate = _selectedDate.toIso8601String().split('T')[0];
          
          final setoranRes = await supabase
              .from('setoran')
              .select('santri_id, tipe, id, jumlah_baris, halaman_awal, halaman_akhir, jumlah_kesalahan, status')
              .eq('tanggal', formattedDate)
              .inFilter('santri_id', santriIds);
              
          _existingSetoranList = List<Map<String, dynamic>>.from(setoranRes);
        } else {
          _existingSetoranList = [];
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
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
      _loadData();
    }
  }

  void _openInputModal(Map<String, dynamic> santri) {
    final isSyahrulQuran = ref.read(setoranSyahrulQuranProvider);
    final formattedDate = _selectedDate.toIso8601String().split('T')[0];

    // Filter existing setoran for this santri
    final existingSabak = _existingSetoranList.firstWhere(
      (s) => s['santri_id'] == santri['id'] && s['tipe'] == 'sabak',
      orElse: () => <String, dynamic>{},
    );
    final existingSabki = _existingSetoranList.firstWhere(
      (s) => s['santri_id'] == santri['id'] && s['tipe'] == 'sabki',
      orElse: () => <String, dynamic>{},
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SetoranInputModal(
          santri: santri,
          selectedDate: formattedDate,
          isSyahrulQuran: isSyahrulQuran,
          existingSabak: existingSabak.isNotEmpty ? existingSabak : null,
          existingSabki: existingSabki.isNotEmpty ? existingSabki : null,
          onSaveSuccess: () {
            _loadData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState == null || authState.roleString != 'pengampu') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Setoran'),
          backgroundColor: AppTheme.roleMurobbiColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 64, color: AppTheme.errorColor.withOpacity(0.8)),
                const SizedBox(height: 16),
                Text(
                  'Akses Ditolak',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Halaman ini hanya dapat diakses oleh Pengampu (Murobbi).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textLight),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isSyahrulQuran = ref.watch(setoranSyahrulQuranProvider);
    final formattedDate = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setoran'),
        backgroundColor: AppTheme.roleMurobbiColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Syahrul Quran
          if (isSyahrulQuran)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.warningColor.withOpacity(0.15),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.warningColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Periode Syahrul Quran Aktif — Sabki & Manzil tidak dihitung',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.warningColor.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Banner Pekan Murajaah - Target Belum Ditentukan
          if (_aktivPekan != null && _targetBarisPerHari == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                border: Border(bottom: BorderSide(color: Color(0xFFF59E0B), width: 1.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pekan Murajaah Aktif — Belum ada target harian untuk halaqah ini',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showSetTargetDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Set Target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Banner Pekan Murajaah - Target Sudah Ditentukan
          if (_aktivPekan != null && _targetBarisPerHari != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                border: Border(bottom: BorderSide(color: Color(0xFF10B981), width: 1.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFF059669)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pekan Murajaah Aktif — Target: $_targetBarisPerHari baris/hari',
                      style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showSetTargetDialog(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Ubah Target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Date Selector Header Display
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal Setoran:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
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
                          style: const TextStyle(
                            color: AppTheme.roleMurobbiColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.roleMurobbiColor))
                : _santriList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_off_rounded, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada santri di halaqah Anda.',
                              style: TextStyle(color: AppTheme.textLight),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: AppTheme.roleMurobbiColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _santriList.length,
                          itemBuilder: (context, index) {
                            final santri = _santriList[index];
                            
                            // Check if has Sabak or Sabki
                            final hasSabak = _existingSetoranList.any(
                              (s) => s['santri_id'] == santri['id'] && s['tipe'] == 'sabak',
                            );
                            final hasSabki = _existingSetoranList.any(
                              (s) => s['santri_id'] == santri['id'] && s['tipe'] == 'sabki',
                            );

                            // Calculate progress bar values
                            final studentSetorans = _existingSetoranList.where((s) => s['santri_id'] == santri['id']);
                            final totalBaris = studentSetorans.fold<int>(0, (sum, s) => sum + ((s['jumlah_baris'] as num?)?.toInt() ?? 0));
                            final progress = _targetBarisPerHari != null && _targetBarisPerHari! > 0
                                ? totalBaris / _targetBarisPerHari!
                                : 0.0;
                            final cappedProgress = progress > 1.0 ? 1.0 : progress;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: () => _openInputModal(santri),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.roleMurobbiColor.withOpacity(0.1),
                                        child: Text(
                                          santri['nama_lengkap'] != null && santri['nama_lengkap'].isNotEmpty
                                              ? santri['nama_lengkap'][0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: AppTheme.roleMurobbiColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              santri['nama_lengkap'] ?? '',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                // Sabak Indicator
                                                _buildStatusBadge(
                                                  label: 'Sabak',
                                                  isActive: hasSabak,
                                                ),
                                                const SizedBox(width: 8),
                                                // Sabki Indicator (hidden if Syahrul Quran)
                                                if (!isSyahrulQuran)
                                                  _buildStatusBadge(
                                                    label: 'Sabki',
                                                    isActive: hasSabki,
                                                  ),
                                              ],
                                            ),
                                            if (_aktivPekan != null && _targetBarisPerHari != null) ...[
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(4),
                                                      child: LinearProgressIndicator(
                                                        value: cappedProgress,
                                                        backgroundColor: Colors.grey.shade200,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          totalBaris >= _targetBarisPerHari!
                                                              ? Colors.green
                                                              : AppTheme.roleMurobbiColor,
                                                        ),
                                                        minHeight: 6,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    '$totalBaris/$_targetBarisPerHari baris',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: totalBaris >= _targetBarisPerHari!
                                                          ? Colors.green.shade700
                                                          : AppTheme.textLight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.5) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: isActive ? Colors.green.shade700 : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

class _SetoranInputModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> santri;
  final String selectedDate;
  final bool isSyahrulQuran;
  final Map<String, dynamic>? existingSabak;
  final Map<String, dynamic>? existingSabki;
  final VoidCallback onSaveSuccess;

  const _SetoranInputModal({
    required this.santri,
    required this.selectedDate,
    required this.isSyahrulQuran,
    this.existingSabak,
    this.existingSabki,
    required this.onSaveSuccess,
  });

  @override
  ConsumerState<_SetoranInputModal> createState() => _SetoranInputModalState();
}

class _SetoranInputModalState extends ConsumerState<_SetoranInputModal> {
  final _formKey = GlobalKey<FormState>();

  // Switches to determine if we want to submit Sabak/Sabki
  bool _enableSabak = true;
  bool _enableSabki = false;

  // Controllers for Sabak
  final _sabakBarisController = TextEditingController();
  final _sabakAwalController = TextEditingController();
  final _sabakAkhirController = TextEditingController();
  final _sabakKesalahanController = TextEditingController(text: '0');
  String _sabakStatusPreview = 'Lulus';

  // Controllers for Sabki
  final _sabkiBarisController = TextEditingController();
  final _sabkiAwalController = TextEditingController();
  final _sabkiAkhirController = TextEditingController();
  final _sabkiKesalahanController = TextEditingController(text: '0');
  String _sabkiStatusPreview = 'Lulus';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill Sabak if existing
    if (widget.existingSabak != null) {
      _enableSabak = true;
      _sabakBarisController.text = widget.existingSabak!['jumlah_baris'].toString();
      _sabakAwalController.text = widget.existingSabak!['halaman_awal'].toString();
      _sabakAkhirController.text = widget.existingSabak!['halaman_akhir'].toString();
      _sabakKesalahanController.text = widget.existingSabak!['jumlah_kesalahan'].toString();
      _updateStatusPreview(isSabak: true);
    }

    // Pre-fill Sabki if existing
    if (widget.existingSabki != null) {
      _enableSabki = true;
      _sabkiBarisController.text = widget.existingSabki!['jumlah_baris'].toString();
      _sabkiAwalController.text = widget.existingSabki!['halaman_awal'].toString();
      _sabkiAkhirController.text = widget.existingSabki!['halaman_akhir'].toString();
      _sabkiKesalahanController.text = widget.existingSabki!['jumlah_kesalahan'].toString();
      _updateStatusPreview(isSabak: false);
    } else {
      // Default enable Sabki for input if not syahrul quran and no existing sabak
      _enableSabki = !widget.isSyahrulQuran;
    }

    // Add listeners for live status calculation
    _sabakAwalController.addListener(() => _updateStatusPreview(isSabak: true));
    _sabakAkhirController.addListener(() => _updateStatusPreview(isSabak: true));
    _sabakKesalahanController.addListener(() => _updateStatusPreview(isSabak: true));

    _sabkiAwalController.addListener(() => _updateStatusPreview(isSabak: false));
    _sabkiAkhirController.addListener(() => _updateStatusPreview(isSabak: false));
    _sabkiKesalahanController.addListener(() => _updateStatusPreview(isSabak: false));
  }

  void _updateStatusPreview({required bool isSabak}) {
    final awalCtrl = isSabak ? _sabakAwalController : _sabkiAwalController;
    final akhirCtrl = isSabak ? _sabakAkhirController : _sabkiAkhirController;
    final kesalahCtrl = isSabak ? _sabakKesalahanController : _sabkiKesalahanController;

    final awal = int.tryParse(awalCtrl.text) ?? 0;
    final akhir = int.tryParse(akhirCtrl.text) ?? 0;
    final kesalahan = int.tryParse(kesalahCtrl.text) ?? 0;

    final totalHalaman = akhir - awal + 1;
    if (totalHalaman <= 0) {
      setState(() {
        if (isSabak) {
          _sabakStatusPreview = 'Lulus';
        } else {
          _sabkiStatusPreview = 'Lulus';
        }
      });
      return;
    }

    final batas = totalHalaman * 2;
    final status = kesalahan > batas ? 'Mengulang' : 'Lulus';

    setState(() {
      if (isSabak) {
        _sabakStatusPreview = status;
      } else {
        _sabkiStatusPreview = status;
      }
    });
  }

  @override
  void dispose() {
    _sabakBarisController.dispose();
    _sabakAwalController.dispose();
    _sabakAkhirController.dispose();
    _sabakKesalahanController.dispose();

    _sabkiBarisController.dispose();
    _sabkiAwalController.dispose();
    _sabkiAkhirController.dispose();
    _sabkiKesalahanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_enableSabak && (!_enableSabki || widget.isSyahrulQuran)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih setidaknya satu tipe setoran (Sabak / Sabki) untuk disimpan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final currentUser = ref.read(authProvider);
    final currentUserId = currentUser?.supabaseUser?.id ?? '';

    try {
      // 1. Process Sabak
      if (_enableSabak) {
        final isNew = widget.existingSabak == null;
        final baris = int.parse(_sabakBarisController.text);
        final awal = int.parse(_sabakAwalController.text);
        final akhir = int.parse(_sabakAkhirController.text);
        final kesalahan = int.parse(_sabakKesalahanController.text);

        final totalHalaman = akhir - awal + 1;
        final status = kesalahan > (totalHalaman * 2) ? 'mengulang' : 'lulus';

        if (isNew) {
          final res = await ref.read(setoranProvider.notifier).insertSetoran({
            'santri_id': widget.santri['id'],
            'tipe': 'sabak',
            'tanggal': widget.selectedDate,
            'jumlah_baris': baris,
            'halaman_awal': awal,
            'halaman_akhir': akhir,
            'jumlah_kesalahan': kesalahan,
            'input_oleh': currentUserId,
          });

          if (res['success'] == false) {
            if (res['error'] == 'duplicate') {
              throw Exception('Setoran Sabak sudah ada untuk santri ini pada tanggal ini, silakan edit');
            } else {
              throw Exception(res['error'] ?? 'Gagal menyimpan Sabak');
            }
          }

          if (res['tikrarFailed'] == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Setoran Sabak disimpan. Tikrar gagal dibuat, silakan buat manual.'),
                backgroundColor: AppTheme.warningColor,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          final res = await ref.read(setoranProvider.notifier).updateSetoran(
                id: widget.existingSabak!['id'] as String,
                jumlahBaris: baris,
                halamanAwal: awal,
                halamanAkhir: akhir,
                jumlahKesalahan: kesalahan,
                status: status,
              );
          if (res['success'] == false) {
            throw Exception(res['error'] ?? 'Gagal memperbarui Sabak');
          }
        }
      }

      // 2. Process Sabki (if not Syahrul Quran)
      if (!widget.isSyahrulQuran && _enableSabki) {
        final isNew = widget.existingSabki == null;
        final baris = int.parse(_sabkiBarisController.text);
        final awal = int.parse(_sabkiAwalController.text);
        final akhir = int.parse(_sabkiAkhirController.text);
        final kesalahan = int.parse(_sabkiKesalahanController.text);

        final totalHalaman = akhir - awal + 1;
        final status = kesalahan > (totalHalaman * 2) ? 'mengulang' : 'lulus';

        if (isNew) {
          final res = await ref.read(setoranProvider.notifier).insertSetoran({
            'santri_id': widget.santri['id'],
            'tipe': 'sabki',
            'tanggal': widget.selectedDate,
            'jumlah_baris': baris,
            'halaman_awal': awal,
            'halaman_akhir': akhir,
            'jumlah_kesalahan': kesalahan,
            'input_oleh': currentUserId,
          });

          if (res['success'] == false) {
            if (res['error'] == 'duplicate') {
              throw Exception('Setoran Sabki sudah ada untuk santri ini pada tanggal ini, silakan edit');
            } else {
              throw Exception(res['error'] ?? 'Gagal menyimpan Sabki');
            }
          }

          if (res['tikrarFailed'] == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Setoran Sabki disimpan. Tikrar gagal dibuat, silakan buat manual.'),
                backgroundColor: AppTheme.warningColor,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          final res = await ref.read(setoranProvider.notifier).updateSetoran(
                id: widget.existingSabki!['id'] as String,
                jumlahBaris: baris,
                halamanAwal: awal,
                halamanAkhir: akhir,
                jumlahKesalahan: kesalahan,
                status: status,
              );
          if (res['success'] == false) {
            throw Exception(res['error'] ?? 'Gagal memperbarui Sabki');
          }
        }
      }

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setoran berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaveSuccess();
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
    final reqCheck = _validateRequiredInt(val, fieldName);
    if (reqCheck != null) return reqCheck;
    final parsed = int.parse(val!);
    if (parsed <= 0) {
      return '$fieldName harus > 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasExisting = widget.existingSabak != null || widget.existingSabki != null;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Bar & Title
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasExisting ? 'Edit Setoran' : 'Input Setoran',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.roleMurobbiColor,
                    ),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.santri['nama_lengkap'] ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 32),

              // SABAK SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Setoran Sabak',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Switch(
                    value: _enableSabak,
                    onChanged: (val) {
                      setState(() {
                        _enableSabak = val;
                      });
                    },
                    activeColor: AppTheme.roleMurobbiColor,
                  ),
                ],
              ),
              if (_enableSabak) ...[
                const SizedBox(height: 12),
                _buildFormSection(
                  barisCtrl: _sabakBarisController,
                  awalCtrl: _sabakAwalController,
                  akhirCtrl: _sabakAkhirController,
                  kesalahCtrl: _sabakKesalahanController,
                  statusPreview: _sabakStatusPreview,
                ),
              ],

              const Divider(height: 48),

              // SABKI SECTION (only show if isSyahrulQuran is false)
              if (!widget.isSyahrulQuran) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Setoran Sabki',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Switch(
                      value: _enableSabki,
                      onChanged: (val) {
                        setState(() {
                          _enableSabki = val;
                        });
                      },
                      activeColor: AppTheme.roleMurobbiColor,
                    ),
                  ],
                ),
                if (_enableSabki) ...[
                  const SizedBox(height: 12),
                  _buildFormSection(
                    barisCtrl: _sabkiBarisController,
                    awalCtrl: _sabkiAwalController,
                    akhirCtrl: _sabkiAkhirController,
                    kesalahCtrl: _sabkiKesalahanController,
                    statusPreview: _sabkiStatusPreview,
                  ),
                ],
                const Divider(height: 32),
              ],

              // Simpan Button
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.roleMurobbiColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required TextEditingController barisCtrl,
    required TextEditingController awalCtrl,
    required TextEditingController akhirCtrl,
    required TextEditingController kesalahCtrl,
    required String statusPreview,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: awalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Halaman Awal',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => _validatePositiveInt(val, 'Halaman awal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: akhirCtrl,
                decoration: const InputDecoration(
                  labelText: 'Halaman Akhir',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  final check = _validatePositiveInt(val, 'Halaman akhir');
                  if (check != null) return check;
                  final awal = int.tryParse(awalCtrl.text) ?? 0;
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: barisCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Baris',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => _validatePositiveInt(val, 'Jumlah baris'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: kesalahCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Kesalahan',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  final check = _validateRequiredInt(val, 'Jumlah kesalahan');
                  if (check != null) return check;
                  final parsed = int.parse(val!);
                  if (parsed < 0) {
                    return 'Kesalahan harus >= 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Live Status Preview Badge
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusPreview == 'Lulus' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusPreview == 'Lulus' ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Status Preview: ',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
                Text(
                  statusPreview,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusPreview == 'Lulus' ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
