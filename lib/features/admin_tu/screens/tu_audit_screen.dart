import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/audit_trail_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';

class TuAuditScreen extends ConsumerStatefulWidget {
  const TuAuditScreen({super.key});

  @override
  ConsumerState<TuAuditScreen> createState() => _TuAuditScreenState();
}

class _TuAuditScreenState extends ConsumerState<TuAuditScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'Semua';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hours:$minutes';
  }

  String _getRoleLabel(String? role) {
    if (role == null) return 'Wali Santri';
    switch (role.toLowerCase()) {
      case 'tu':
        return 'Staff TU';
      case 'koordinator':
        return 'Koordinator';
      case 'pengampu':
        return 'Murobbi';
      case 'kepsek':
        return 'Kepala Sekolah';
      default:
        return role;
    }
  }

  Color _getRoleColor(String? role) {
    if (role == null) return AppTheme.roleWaliColor;
    return AppTheme.getColorForRole(role);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
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
        _dateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchCtrl.clear();
      _selectedRole = 'Semua';
      _dateRange = null;
    });
  }

  Future<void> _confirmDeleteOldLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Data Lama', style: AppTextStyles.h4),
        content: const Text('Data audit trail lebih dari 3 bulan akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Permanen', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );

      try {
        final deletedCount = await ref.read(auditTrailProvider.notifier).deleteOldAuditTrail();
        if (mounted) {
          Navigator.pop(context); // Pop loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(deletedCount == 0
                  ? 'Tidak ada data lama yang perlu dihapus'
                  : 'Data audit trail lama berhasil dihapus ($deletedCount baris)'),
              backgroundColor: deletedCount == 0 ? AppTheme.warningColor : AppTheme.primaryColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Pop loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus data lama: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auditState = ref.watch(auditTrailProvider);

    return Scaffold(
      body: Column(
        children: [
          // Filter & Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                // Header with Hapus Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Audit Trail', style: AppTextStyles.h2),
                        const SizedBox(height: 2),
                        Text('Riwayat log aktivitas sistem.', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _confirmDeleteOldLogs,
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: Text(
                        'Hapus Data Lama',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search field
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari nama aktor...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Filters Row: Date Range + Role Dropdown
                Row(
                  children: [
                    // Date range selection
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: _selectDateRange,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _dateRange == null
                                      ? 'Pilih Tanggal'
                                      : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _dateRange == null ? Colors.grey : AppTheme.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.date_range, size: 16, color: AppTheme.primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Role filter dropdown
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            style: GoogleFonts.outfit(color: AppTheme.textDark, fontSize: 13),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              }
                            },
                            items: <String>[
                              'Semua',
                              'tu',
                              'koordinator',
                              'pengampu',
                              'kepsek',
                              'orang_tua'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value == 'Semua'
                                      ? 'Semua Aktor'
                                      : value == 'orang_tua'
                                          ? 'Wali Santri'
                                          : _getRoleLabel(value),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    // Clear filter icon
                    if (_searchQuery.isNotEmpty || _selectedRole != 'Semua' || _dateRange != null)
                      IconButton(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.filter_alt_off, color: AppTheme.errorColor),
                        tooltip: 'Reset Filter',
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Audit Log List Section
          Expanded(
            child: auditState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                    const SizedBox(height: 12),
                    Text('Gagal memuat log audit', style: AppTextStyles.h4),
                    const SizedBox(height: 6),
                    Text(err.toString(), style: AppTextStyles.bodySmall),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(auditTrailProvider.notifier).fetchAuditTrail(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (logs) {
                // Client-side filtering
                final filteredLogs = logs.where((log) {
                  final profile = log['profiles'];
                  final actorName = (profile != null && profile['nama_lengkap'] != null)
                      ? profile['nama_lengkap'].toString().toLowerCase()
                      : 'wali santri';
                  final actorRole = (profile != null && profile['role'] != null)
                      ? profile['role'].toString().toLowerCase()
                      : 'orang_tua';

                  // Search query matching actor name
                  if (_searchQuery.isNotEmpty && !actorName.contains(_searchQuery)) {
                    return false;
                  }

                  // Role filter matching
                  if (_selectedRole != 'Semua') {
                    if (actorRole != _selectedRole.toLowerCase()) {
                      return false;
                    }
                  }

                  // Date range matching
                  if (_dateRange != null) {
                    final logDate = DateTime.parse(log['created_at']);
                    final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
                    final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59);
                    if (logDate.isBefore(start) || logDate.isAfter(end)) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filteredLogs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Tidak ada log audit yang cocok dengan filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final profile = log['profiles'];
                    final actorName = (profile != null && profile['nama_lengkap'] != null)
                        ? profile['nama_lengkap'].toString()
                        : 'Wali Santri';
                    final actorRole = (profile != null && profile['role'] != null)
                        ? profile['role'].toString()
                        : 'orang_tua';
                    final activity = log['aktivitas'] ?? '';
                    final date = DateTime.parse(log['created_at']).toLocal();

                    return AppCard(
                      role: 'tu',
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: role badge + timestamp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(actorRole).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getRoleLabel(actorRole).toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getRoleColor(actorRole),
                                  ),
                                ),
                              ),
                              Text(
                                _formatDateTime(date),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Activity details
                          Text(
                            activity,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Aktor info footer
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                actorName,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
