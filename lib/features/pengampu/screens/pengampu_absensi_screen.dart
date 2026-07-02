import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/absensi_provider.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../../../core/widgets/error_state_widget.dart';

class PengampuAbsensiScreen extends ConsumerStatefulWidget {
  const PengampuAbsensiScreen({super.key});

  @override
  ConsumerState<PengampuAbsensiScreen> createState() => _PengampuAbsensiScreenState();
}

class _PengampuAbsensiScreenState extends ConsumerState<PengampuAbsensiScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _loadErrorMessage = '';
  List<Map<String, dynamic>> _santriList = [];
  String? _halaqahId;

  // Track saving state per santri to show loading spinners inline
  final Map<String, bool> _isSavingMap = {};
  // Track action errors per santri for individual retries
  final Map<String, Map<String, dynamic>> _actionErrorMap = {};

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
      _hasLoadError = false;
      _loadErrorMessage = '';
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

        final santriRes = await supabase
            .from('santri')
            .select('id, nama_lengkap')
            .eq('halaqah_id', _halaqahId!)
            .order('nama_lengkap');

        _santriList = List<Map<String, dynamic>>.from(santriRes);

        final formattedDate = _selectedDate.toIso8601String().split('T')[0];
        await ref.read(absensiProvider.notifier).fetchAbsensiByDate(_halaqahId!, formattedDate);
      } else {
        _halaqahId = null;
        _santriList = [];
      }
    } catch (e) {
      debugPrint('Error loading absensi data: $e');
      setState(() {
        _hasLoadError = true;
        _loadErrorMessage = 'Gagal memuat data absensi. Silakan periksa koneksi internet Anda.';
      });
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
        _actionErrorMap.clear();
      });
      _loadData();
    }
  }

  Future<void> _changeAbsensi(String santriId, String? currentStatus, String targetStatus) async {
    if (currentStatus == targetStatus) return;

    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    setState(() {
      _isSavingMap[santriId] = true;
      _actionErrorMap.remove(santriId);
    });

    try {
      if (targetStatus == 'hadir') {
        await ref.read(absensiProvider.notifier).hapusAbsensi(santriId, dateStr);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absensi dihapus, santri ditandai hadir'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(absensiProvider.notifier).upsertAbsensi(santriId, targetStatus, dateStr);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absensi berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving absensi for santri $santriId: $e');
      if (mounted) {
        setState(() {
          _actionErrorMap[santriId] = {
            'status': targetStatus,
            'error': e.toString(),
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan absensi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () {
                _changeAbsensi(santriId, currentStatus, targetStatus);
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMap[santriId] = false;
        });
      }
    }
  }

  void _showStatusPicker(BuildContext context, Map<String, dynamic> santri, String? currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final santriId = santri['id'] as String;
        final santriNama = santri['nama_lengkap'] ?? '';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Pilih Status: $santriNama',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const Divider(),
                if (currentStatus != null)
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                    title: const Text('Hadir', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Kembalikan status ke Hadir (hapus record absensi)'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeAbsensi(santriId, currentStatus, 'hadir');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: Color(0xFF991B1B)),
                  title: const Text('Alpha', style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
                  trailing: currentStatus == 'alpha' ? const Icon(Icons.check_rounded, color: Color(0xFF991B1B)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeAbsensi(santriId, currentStatus, 'alpha');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sick_outlined, color: Color(0xFF6B21A8)),
                  title: const Text('Sakit', style: TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.bold)),
                  trailing: currentStatus == 'sakit' ? const Icon(Icons.check_rounded, color: Color(0xFF6B21A8)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeAbsensi(santriId, currentStatus, 'sakit');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_ind_outlined, color: Color(0xFF1E40AF)),
                  title: const Text('Izin', style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold)),
                  trailing: currentStatus == 'izin' ? const Icon(Icons.check_rounded, color: Color(0xFF1E40AF)) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeAbsensi(santriId, currentStatus, 'izin');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String? status) {
    if (status == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Hadir',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'alpha':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'Alpha';
        break;
      case 'sakit':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF6B21A8);
        label = 'Sakit';
        break;
      case 'izin':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        label = 'Izin';
        break;
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Hadir',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    final authState = ref.watch(authProvider);
    if (authState == null || authState.roleString != 'pengampu') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Absensi'),
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

    final formattedDate = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    final absensiMap = ref.watch(absensiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
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
          // Date Selector Header Display
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
                  'Tanggal Absensi:',
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
                : _hasLoadError
                    ? ErrorStateWidget(
                        message: _loadErrorMessage,
                        onRetry: _loadData,
                      )
                    : _santriList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_off_rounded, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada santri di halaqah Anda',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _santriList.length,
                            itemBuilder: (context, index) {
                              final santri = _santriList[index];
                              final santriId = santri['id'] as String;
                              final santriNama = santri['nama_lengkap'] ?? '';
                              final currentStatus = absensiMap[santriId];
                              final isSaving = _isSavingMap[santriId] == true;
                              final hasError = _actionErrorMap.containsKey(santriId);

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: hasError
                                      ? const BorderSide(color: AppTheme.errorColor, width: 1.5)
                                      : BorderSide.none,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: isSaving
                                      ? null
                                      : () => _showStatusPicker(context, santri, currentStatus),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppTheme.roleMurobbiColor.withOpacity(0.1),
                                          child: Text(
                                            santriNama.isNotEmpty ? santriNama[0] : '?',
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
                                                santriNama,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                              if (hasError)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    'Gagal menyimpan. Ketuk untuk mencoba lagi.',
                                                    style: TextStyle(
                                                      color: AppTheme.errorColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (isSaving)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.roleMurobbiColor,
                                            ),
                                          )
                                        else if (hasError)
                                          IconButton(
                                            icon: const Icon(Icons.refresh_rounded, color: AppTheme.errorColor),
                                            onPressed: () {
                                              final targetStatus = _actionErrorMap[santriId]?['status'] ?? 'hadir';
                                              _changeAbsensi(santriId, currentStatus, targetStatus);
                                            },
                                          )
                                        else
                                          _buildStatusBadge(currentStatus),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
