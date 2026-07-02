import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/akun_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state_widget.dart';

class TuAkunScreen extends ConsumerStatefulWidget {
  const TuAkunScreen({super.key});

  @override
  ConsumerState<TuAkunScreen> createState() => _TuAkunScreenState();
}

class _TuAkunScreenState extends ConsumerState<TuAkunScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedRoleFilter = 'Semua';
  String _searchQuery = '';

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

  void _showAddEditModal({Map<String, dynamic>? existingAkun}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditAkunForm(existingAkun: existingAkun),
    );
  }

  void _showResetPasswordModal(String userId, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResetPasswordForm(userId: userId, userName: userName),
    );
  }

  void _showDeleteDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Hapus Akun', style: AppTextStyles.h4),
              content: Text('Apakah kamu yakin ingin menghapus akun "$userName"? Tindakan ini tidak dapat dibatalkan.'),
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
                          final success = await ref.read(akunProvider.notifier).deleteAkun(
                                userId: userId,
                                namaUser: userName,
                              );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Akun berhasil dihapus' : 'Gagal menghapus akun'),
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

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'tu':
        return 'Staff TU';
      case 'koordinator':
        return 'Koordinator';
      case 'pengampu':
        return 'Pengampu';
      case 'kepsek':
        return 'Kepala Sekolah';
      case 'orang_tua':
        return 'Orang Tua';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final akunAsync = ref.watch(akunProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Akun'),
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama pengguna...',
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
          
          // Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                'Semua',
                'tu',
                'koordinator',
                'pengampu',
                'kepsek',
                'orang_tua'
              ].map((role) {
                final isSelected = _selectedRoleFilter == role;
                final label = role == 'Semua' ? 'Semua' : _getRoleLabel(role);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRoleFilter = role;
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

          // User Accounts List
          Expanded(
            child: akunAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () => ref.refresh(akunProvider),
              ),
              data: (akunList) {
                final filteredList = akunList.where((akun) {
                  final matchesSearch = (akun['nama_lengkap'] ?? '').toString().toLowerCase().contains(_searchQuery);
                  final matchesRole = _selectedRoleFilter == 'Semua' ||
                      (akun['role'] ?? '').toString().toLowerCase() == _selectedRoleFilter.toLowerCase();
                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada akun yang sesuai kriteria.',
                      style: AppTextStyles.body.copyWith(color: AppTheme.textLight),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final akun = filteredList[index];
                    final String role = akun['role'] ?? '';
                    final String id = akun['id'] ?? '';
                    final String name = akun['nama_lengkap'] ?? '';
                    final String? email = akun['email'];
                    final String? nomorHp = akun['nomor_hp'];

                    return AppCard(
                      role: 'tu',
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Role Accent indicator
                          Container(
                            width: 4,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.getColorForRole(role),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                    // Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getColorForRole(role).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getRoleLabel(role).toUpperCase(),
                                        style: TextStyle(
                                          color: AppTheme.getColorForRole(role),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      role == 'orang_tua' ? Icons.phone_android_rounded : Icons.email_outlined,
                                      size: 14,
                                      color: AppTheme.textLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (role == 'orang_tua' ? nomorHp : email) ?? '-',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.key_rounded, color: AppTheme.warningColor, size: 20),
                                tooltip: 'Reset Password',
                                onPressed: () => _showResetPasswordModal(id, name),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                tooltip: 'Edit Nama',
                                onPressed: () => _showAddEditModal(existingAkun: akun),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                                tooltip: 'Hapus Akun',
                                onPressed: () => _showDeleteDialog(id, name),
                              ),
                            ],
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
        icon: const Icon(Icons.add),
        label: const Text('Tambah Akun'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddEditAkunForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingAkun;
  const _AddEditAkunForm({this.existingAkun});

  @override
  ConsumerState<_AddEditAkunForm> createState() => _AddEditAkunFormState();
}

class _AddEditAkunFormState extends ConsumerState<_AddEditAkunForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _hpCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  String _selectedRole = 'pengampu';
  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.existingAkun != null) {
      _nameCtrl.text = widget.existingAkun!['nama_lengkap'] ?? '';
      _selectedRole = widget.existingAkun!['role'] ?? 'pengampu';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _hpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final notifier = ref.read(akunProvider.notifier);
    bool success = false;

    if (widget.existingAkun != null) {
      // Edit Mode
      success = await notifier.editAkun(
        userId: widget.existingAkun!['id'],
        role: widget.existingAkun!['role'],
        namaLengkap: _nameCtrl.text.trim(),
      );
    } else {
      // Create Mode
      success = await notifier.createAkun(
        namaLengkap: _nameCtrl.text.trim(),
        role: _selectedRole,
        email: _selectedRole == 'orang_tua' ? null : _emailCtrl.text.trim(),
        nomorHp: _selectedRole == 'orang_tua' ? _hpCtrl.text.trim() : null,
        password: _passwordCtrl.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingAkun != null ? 'Akun berhasil diperbarui' : 'Akun berhasil dibuat'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      setState(() {
        _errorMessage = widget.existingAkun != null
            ? 'Gagal memperbarui akun. Coba beberapa saat lagi.'
            : 'Gagal membuat akun. Pastikan email/no HP belum terdaftar dan format benar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingAkun != null;
    
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Ubah Data Akun' : 'Tambah Akun Baru',
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

              // Dropdown Role
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'tu', child: Text('Staff TU')),
                  DropdownMenuItem(value: 'koordinator', child: Text('Koordinator')),
                  DropdownMenuItem(value: 'pengampu', child: Text('Pengampu')),
                  DropdownMenuItem(value: 'kepsek', child: Text('Kepala Sekolah')),
                  DropdownMenuItem(value: 'orang_tua', child: Text('Orang Tua')),
                ],
                onChanged: isEdit
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _selectedRole = val;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),

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

              // Conditional Fields: Email or Phone Number (only for Create)
              if (!isEdit) ...[
                if (_selectedRole != 'orang_tua')
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Field email wajib diisi';
                      }
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!regex.hasMatch(val)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _hpCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Field nomor HP wajib diisi';
                      }
                      final numberRegex = RegExp(r'^\d+$');
                      if (!numberRegex.hasMatch(val)) {
                        return 'Nomor HP harus berupa angka';
                      }
                      if (val.trim().length < 10) {
                        return 'Nomor HP minimal 10 digit';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password Awal',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Field password wajib diisi';
                    }
                    if (val.trim().length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

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
                onPressed: _isLoading ? null : _submit,
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

class _ResetPasswordForm extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  const _ResetPasswordForm({required this.userId, required this.userName});

  @override
  ConsumerState<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<_ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(akunProvider.notifier).resetPassword(
          userId: widget.userId,
          newPassword: _passCtrl.text,
        );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil direset'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Gagal mereset password. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Reset Password: ${widget.userName}',
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Password Field
            TextFormField(
              controller: _passCtrl,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Field password wajib diisi';
                }
                if (val.trim().length < 8) {
                  return 'Password minimal 8 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
