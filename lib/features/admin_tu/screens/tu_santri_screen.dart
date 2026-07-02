import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/santri_provider.dart';
import '../../../core/providers/halaqah_provider.dart';
import '../../../core/providers/akun_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';

class TuSantriScreen extends ConsumerStatefulWidget {
  const TuSantriScreen({super.key});

  @override
  ConsumerState<TuSantriScreen> createState() => _TuSantriScreenState();
}

class _TuSantriScreenState extends ConsumerState<TuSantriScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = 'Semua';
  String _selectedHalaqahFilter = 'Semua';
  String _selectedKelasFilter = 'Semua';

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

  void _showAddEditModal({Map<String, dynamic>? existingSantri}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditSantriForm(existingSantri: existingSantri),
    );
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Hapus Santri', style: AppTextStyles.h4),
              content: Text('Apakah kamu yakin ingin menghapus santri "$name"? Seluruh riwayat setoran, tikrar, absensi, uas, dan nilai akan terhapus secara permanen.'),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() {
                            isDeleting = true;
                          });
                          final success = await ref.read(santriProvider.notifier).deleteSantri(id, name);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Data santri berhasil dihapus' : 'Gagal menghapus data santri'),
                                backgroundColor: success ? AppTheme.primaryColor : AppTheme.errorColor,
                              ),
                            );
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
    final santriAsync = ref.watch(santriProvider);
    final halaqahAsync = ref.watch(halaqahProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama santri...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Grade Filter
                DropdownButton<String>(
                  value: _selectedGradeFilter,
                  underline: const SizedBox(),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                  items: ['Semua', 'Tahsin', 'Takmil', 'Tahfiz'].map((g) {
                    return DropdownMenuItem(value: g, child: Text('Grade: $g'));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGradeFilter = val);
                  },
                ),
                const SizedBox(width: 16),

                // Halaqah Filter
                halaqahAsync.maybeWhen(
                  data: (list) {
                    final names = ['Semua'] + list.map((h) => h['nama_halaqah']?.toString() ?? '').toList();
                    // Clean names
                    final uniqueNames = names.toSet().toList();
                    
                    // Fallback if selected filter is not in list
                    if (!uniqueNames.contains(_selectedHalaqahFilter)) {
                      _selectedHalaqahFilter = 'Semua';
                    }

                    return DropdownButton<String>(
                      value: _selectedHalaqahFilter,
                      underline: const SizedBox(),
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                      items: uniqueNames.map((n) {
                        return DropdownMenuItem(value: n, child: Text(n == 'Semua' ? 'Halaqah: Semua' : n));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedHalaqahFilter = val);
                      },
                    );
                  },
                  orElse: () => const SizedBox(),
                ),
                const SizedBox(width: 16),

                // Kelas Filter
                santriAsync.maybeWhen(
                  data: (list) {
                    final kelasList = ['Semua'] + list.map((s) => s['kelas']?.toString() ?? '').toSet().toList();
                    if (!kelasList.contains(_selectedKelasFilter)) {
                      _selectedKelasFilter = 'Semua';
                    }
                    return DropdownButton<String>(
                      value: _selectedKelasFilter,
                      underline: const SizedBox(),
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                      items: kelasList.map((k) {
                        return DropdownMenuItem(value: k, child: Text(k == 'Semua' ? 'Kelas: Semua' : 'Kelas $k'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedKelasFilter = val);
                      },
                    );
                  },
                  orElse: () => const SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Santri List
          Expanded(
            child: santriAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.refresh(santriProvider),
              ),
              data: (santriList) {
                final filteredList = santriList.where((s) {
                  final name = (s['nama_lengkap'] ?? '').toString().toLowerCase();
                  final matchesSearch = name.contains(_searchQuery);
                  
                  final grade = (s['grade'] ?? '').toString().toLowerCase();
                  final matchesGrade = _selectedGradeFilter == 'Semua' ||
                      grade == _selectedGradeFilter.toLowerCase();
                  
                  final halaqahName = (s['halaqah']?['nama_halaqah'] ?? '').toString();
                  final matchesHalaqah = _selectedHalaqahFilter == 'Semua' ||
                      halaqahName == _selectedHalaqahFilter;

                  final kelas = (s['kelas'] ?? '').toString();
                  final matchesKelas = _selectedKelasFilter == 'Semua' ||
                      kelas == _selectedKelasFilter;

                  return matchesSearch && matchesGrade && matchesHalaqah && matchesKelas;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data santri yang sesuai.',
                      style: AppTextStyles.body.copyWith(color: AppTheme.textLight),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final s = filteredList[index];
                    final String id = s['id'] ?? '';
                    final String name = s['nama_lengkap'] ?? '';
                    final String kelas = s['kelas'] ?? '';
                    final String grade = s['grade'] ?? '';
                    final String halaqahName = s['halaqah']?['nama_halaqah'] ?? 'Belum ada Halaqah';
                    final String parentName = s['orang_tua']?['nama_lengkap'] ?? 'Belum ditautkan';

                    return AppCard(
                      role: 'tu',
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: AppTextStyles.h5.copyWith(color: AppTheme.textDark),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Grade Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getColorForRole(grade == 'tahfiz' ? 'kepsek' : (grade == 'takmil' ? 'koordinator' : 'tu')).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        grade.toUpperCase(),
                                        style: TextStyle(
                                          color: AppTheme.getColorForRole(grade == 'tahfiz' ? 'kepsek' : (grade == 'takmil' ? 'koordinator' : 'tu')),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kelas $kelas  •  $halaqahName',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textDark, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline_rounded, size: 14, color: AppTheme.textLight),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Orang Tua: $parentName',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            onPressed: () => _showAddEditModal(existingSantri: s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                            onPressed: () => _showDeleteDialog(id, name),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditModal(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Santri'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddEditSantriForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingSantri;
  const _AddEditSantriForm({this.existingSantri});

  @override
  ConsumerState<_AddEditSantriForm> createState() => _AddEditSantriFormState();
}

class _AddEditSantriFormState extends ConsumerState<_AddEditSantriForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _kelasCtrl = TextEditingController();

  String _selectedGrade = 'tahsin';
  String? _selectedHalaqahId;
  String? _selectedParentId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.existingSantri != null) {
      _nameCtrl.text = widget.existingSantri!['nama_lengkap'] ?? '';
      _kelasCtrl.text = widget.existingSantri!['kelas'] ?? '';
      _selectedGrade = widget.existingSantri!['grade'] ?? 'tahsin';
      _selectedHalaqahId = widget.existingSantri!['halaqah_id'];
      _selectedParentId = widget.existingSantri!['orang_tua_id'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kelasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Map<String, dynamic>> halaqahs) async {
    if (halaqahs.isEmpty) {
      setState(() {
        _errorMessage = 'Buat halaqah terlebih dahulu';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHalaqahId == null) {
      setState(() {
        _errorMessage = 'Pilih halaqah terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final payload = {
      'nama_lengkap': _nameCtrl.text.trim(),
      'kelas': _kelasCtrl.text.trim(),
      'grade': _selectedGrade,
      'halaqah_id': _selectedHalaqahId,
      'orang_tua_id': _selectedParentId,
    };

    final notifier = ref.read(santriProvider.notifier);
    bool success = false;

    if (widget.existingSantri != null) {
      success = await notifier.updateSantri(widget.existingSantri!['id'], payload);
    } else {
      success = await notifier.addSantri(payload);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingSantri != null ? 'Data santri berhasil diperbarui' : 'Data santri berhasil disimpan'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Gagal menyimpan data santri. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingSantri != null;
    final halaqahAsync = ref.watch(halaqahProvider);
    final accountsAsync = ref.watch(akunProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Ubah Data Santri' : 'Tambah Santri Baru',
                    style: AppTextStyles.h3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Nama Lengkap
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Field nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kelas
              TextFormField(
                controller: _kelasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kelas (Misal: 7A, 8B)',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Field kelas wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Grade
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  prefixIcon: Icon(Icons.grade_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'tahsin', child: Text('Tahsin')),
                  DropdownMenuItem(value: 'takmil', child: Text('Takmil')),
                  DropdownMenuItem(value: 'tahfiz', child: Text('Tahfiz')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGrade = val);
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Halaqah
              halaqahAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                error: (err, _) => Text('Error load halaqah: $err', style: const TextStyle(color: AppTheme.errorColor)),
                data: (halaqahs) {
                  if (halaqahs.isEmpty) {
                    return Text(
                      'Belum ada halaqah. Buat halaqah terlebih dahulu.',
                      style: AppTextStyles.body.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
                    );
                  }

                  // Auto select first halaqah if not set
                  if (_selectedHalaqahId == null) {
                    _selectedHalaqahId = halaqahs.first['id'];
                  } else {
                    // Make sure existing selected ID is still in the fetched list
                    final exists = halaqahs.any((h) => h['id'] == _selectedHalaqahId);
                    if (!exists) {
                      _selectedHalaqahId = halaqahs.first['id'];
                    }
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedHalaqahId,
                    decoration: const InputDecoration(
                      labelText: 'Halaqah',
                      prefixIcon: Icon(Icons.group_work_outlined),
                    ),
                    items: halaqahs.map<DropdownMenuItem<String>>((h) {
                      return DropdownMenuItem<String>(
                        value: h['id'],
                        child: Text(h['nama_halaqah'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedHalaqahId = val);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Orang Tua (Optional)
              accountsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                error: (err, _) => Text('Error load orang tua: $err', style: const TextStyle(color: AppTheme.errorColor)),
                data: (accounts) {
                  final parents = accounts.where((acc) => acc['role'] == 'orang_tua').toList();

                  // Make sure existing selected ID is still in the parents list
                  final exists = parents.any((p) => p['id'] == _selectedParentId);
                  if (!exists) {
                    _selectedParentId = null;
                  }

                  return DropdownButtonFormField<String?>(
                    value: _selectedParentId,
                    decoration: const InputDecoration(
                      labelText: 'Orang Tua / Wali (Opsional)',
                      prefixIcon: Icon(Icons.family_restroom_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Belum ditautkan'),
                      ),
                      ...parents.map<DropdownMenuItem<String?>>((p) {
                        return DropdownMenuItem<String?>(
                          value: p['id'],
                          child: Text('${p['nama_lengkap']} (${p['nomor_hp']})'),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedParentId = val);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Inline Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final halaqahs = halaqahAsync.value ?? [];
                        _submit(halaqahs);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
