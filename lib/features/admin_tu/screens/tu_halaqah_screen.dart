import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/halaqah_provider.dart';
import '../../../core/providers/akun_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';

class TuHalaqahScreen extends ConsumerStatefulWidget {
  const TuHalaqahScreen({super.key});

  @override
  ConsumerState<TuHalaqahScreen> createState() => _TuHalaqahScreenState();
}

class _TuHalaqahScreenState extends ConsumerState<TuHalaqahScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = 'Semua';

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

  void _showAddEditModal({Map<String, dynamic>? existingHalaqah}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditHalaqahForm(existingHalaqah: existingHalaqah),
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
              title: Text('Hapus Halaqah', style: AppTextStyles.h4),
              content: Text('Apakah kamu yakin ingin menghapus halaqah "$name"?'),
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
                          final error = await ref.read(halaqahProvider.notifier).deleteHalaqah(id, name);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (error == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Halaqah berhasil dihapus'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
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

  int _extractSantriCount(dynamic santriData) {
    if (santriData == null) return 0;
    if (santriData is List) {
      if (santriData.isEmpty) return 0;
      final first = santriData.first;
      if (first is Map) {
        return first['count'] ?? 0;
      }
    }
    if (santriData is Map) {
      return santriData['count'] ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final halaqahAsync = ref.watch(halaqahProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama halaqah...',
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

          // Grade Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['Semua', 'Tahsin', 'Takmil', 'Tahfiz'].map((grade) {
                final isSelected = _selectedGradeFilter == grade;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(grade),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGradeFilter = grade;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Halaqah Cards List
          Expanded(
            child: halaqahAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.refresh(halaqahProvider),
              ),
              data: (halaqahs) {
                final filteredList = halaqahs.where((h) {
                  final name = (h['nama_halaqah'] ?? '').toString().toLowerCase();
                  final matchesSearch = name.contains(_searchQuery);

                  final grade = (h['grade'] ?? '').toString().toLowerCase();
                  final matchesGrade = _selectedGradeFilter == 'Semua' ||
                      grade == _selectedGradeFilter.toLowerCase();

                  return matchesSearch && matchesGrade;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data halaqah.',
                      style: AppTextStyles.body.copyWith(color: AppTheme.textLight),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final h = filteredList[index];
                    final String id = h['id'] ?? '';
                    final String name = h['nama_halaqah'] ?? '';
                    final String grade = h['grade'] ?? '';
                    final String pengampuName = h['profiles']?['nama_lengkap'] ?? 'Belum ada pengampu';
                    final int count = _extractSantriCount(h['santri']);

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
                                  'Pengampu: $pengampuName',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textDark, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline_rounded, size: 14, color: AppTheme.textLight),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$count Santri Aktif',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            onPressed: () => _showAddEditModal(existingHalaqah: h),
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
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Tambah Halaqah'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddEditHalaqahForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingHalaqah;
  const _AddEditHalaqahForm({this.existingHalaqah});

  @override
  ConsumerState<_AddEditHalaqahForm> createState() => _AddEditHalaqahFormState();
}

class _AddEditHalaqahFormState extends ConsumerState<_AddEditHalaqahForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();

  String _selectedGrade = 'tahfiz';
  String? _selectedPengampuId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.existingHalaqah != null) {
      _nameCtrl.text = widget.existingHalaqah!['nama_halaqah'] ?? '';
      _selectedGrade = widget.existingHalaqah!['grade'] ?? 'tahfiz';
      _selectedPengampuId = widget.existingHalaqah!['pengampu_id'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Map<String, dynamic>> pengampus) async {
    if (pengampus.isEmpty) {
      setState(() {
        _errorMessage = 'Buat akun pengampu terlebih dahulu';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPengampuId == null) {
      setState(() {
        _errorMessage = 'Pilih pengampu terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final payload = {
      'nama_halaqah': _nameCtrl.text.trim(),
      'grade': _selectedGrade,
      'pengampu_id': _selectedPengampuId,
    };

    final notifier = ref.read(halaqahProvider.notifier);
    bool success = false;

    if (widget.existingHalaqah != null) {
      success = await notifier.updateHalaqah(widget.existingHalaqah!['id'], payload);
    } else {
      success = await notifier.addHalaqah(payload);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingHalaqah != null ? 'Data halaqah berhasil diperbarui' : 'Data halaqah berhasil disimpan'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Gagal menyimpan data halaqah. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingHalaqah != null;
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
                    isEdit ? 'Ubah Data Halaqah' : 'Tambah Halaqah Baru',
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

              // Nama Halaqah
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Halaqah',
                  prefixIcon: Icon(Icons.group_work_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Field nama halaqah wajib diisi';
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

              // Dropdown Pengampu
              accountsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                error: (err, _) => Text('Error load pengampu: $err', style: const TextStyle(color: AppTheme.errorColor)),
                data: (accounts) {
                  final pengampus = accounts.where((acc) => acc['role'] == 'pengampu').toList();

                  if (pengampus.isEmpty) {
                    return Text(
                      'Belum ada akun pengampu. Buat akun pengampu terlebih dahulu.',
                      style: AppTextStyles.body.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
                    );
                  }

                  // Auto select first pengampu if not set
                  if (_selectedPengampuId == null) {
                    _selectedPengampuId = pengampus.first['id'];
                  } else {
                    // Make sure existing selected ID is still in the pengampu list
                    final exists = pengampus.any((p) => p['id'] == _selectedPengampuId);
                    if (!exists) {
                      _selectedPengampuId = pengampus.first['id'];
                    }
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedPengampuId,
                    decoration: const InputDecoration(
                      labelText: 'Pengampu Penanggung Jawab',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    items: pengampus.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem<String>(
                        value: p['id'],
                        child: Text(p['nama_lengkap'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedPengampuId = val);
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
                        final accounts = accountsAsync.value ?? [];
                        final pengampus = accounts.where((acc) => acc['role'] == 'pengampu').toList();
                        _submit(pengampus);
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
