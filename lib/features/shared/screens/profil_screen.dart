import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profil_provider.dart';
import '../../../core/text_styles.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  String? _passwordLamaError;
  bool _isPasswordSaving = false;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Nama Lengkap", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return "Nama tidak boleh kosong";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                try {
                  await ref.read(profilProvider.notifier).updateNama(controller.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nama berhasil diperbarui"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal memperbarui nama: $e"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleGantiPassword() async {
    setState(() {
      _passwordLamaError = null;
    });

    final pwdLama = _passwordLamaController.text;
    final pwdBaru = _passwordBaruController.text;
    final konfirmasi = _konfirmasiController.text;

    // Check if all fields are empty
    if (pwdLama.isEmpty && pwdBaru.isEmpty && konfirmasi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak ada perubahan yang disimpan"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Client-side validations
    if (pwdLama.isEmpty) {
      setState(() {
        _passwordLamaError = "Password lama wajib diisi";
      });
      return;
    }

    if (pwdBaru.isEmpty || pwdBaru.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password minimal 8 karakter"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (pwdBaru != konfirmasi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi password tidak sesuai"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPasswordSaving = true;
    });

    try {
      await ref.read(profilProvider.notifier).gantiPassword(pwdLama, pwdBaru);
      
      _passwordLamaController.clear();
      _passwordBaruController.clear();
      _konfirmasiController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password berhasil diperbarui"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      if (errorMsg.contains("Password lama tidak sesuai")) {
        setState(() {
          _passwordLamaError = "Password lama tidak sesuai";
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal memperbarui password: $errorMsg"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPasswordSaving = false;
        });
      }
    }
  }

  Future<void> _handleLogout(String role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Konfirmasi Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Keluar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final isOrtu = role == 'orang_tua';
      ref.read(logoutTargetProvider.notifier).state = isOrtu ? '/login/ortu' : '/login';
      await ref.read(authProvider.notifier).signOut();
    }
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;
    switch (role) {
      case 'tu':
        color = Colors.blue;
        label = "Staff TU";
        break;
      case 'koordinator':
        color = Colors.amber;
        label = "Koordinator";
        break;
      case 'pengampu':
        color = Colors.teal;
        label = "Pengampu";
        break;
      case 'kepsek':
        color = Colors.indigo;
        label = "Kepala Sekolah";
        break;
      case 'orang_tua':
        color = const Color(0xFF10B981);
        label = "Wali Santri";
        break;
      default:
        color = Colors.grey;
        label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    if (userState == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final role = userState.roleString ?? 'orang_tua';
    final profileAsync = ref.watch(profilProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text("Error: $err", style: AppTextStyles.body.copyWith(color: Colors.red)),
        ),
        data: (profile) {
          final nama = profile['nama_lengkap'] ?? '';
          final email = profile['email'];
          final nomorHp = profile['nomor_hp'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar & Name Card
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF10B981),
                        child: Text(
                          _getInitials(nama),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        nama,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 8),
                      _buildRoleBadge(role),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Card: Informasi Akun
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Informasi Akun", style: AppTextStyles.h4),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Color(0xFF10B981)),
                              onPressed: () => _showEditNameDialog(context, nama),
                              tooltip: "Edit Nama",
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Nama Lengkap info
                        Text("Nama Lengkap", style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(nama, style: AppTextStyles.body),
                        const SizedBox(height: 16),

                        // Email or Nomor HP info
                        if (role != 'orang_tua' && email != null) ...[
                          Text("Email", style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(email, style: AppTextStyles.body),
                          const SizedBox(height: 16),
                        ],
                        if (role == 'orang_tua' && nomorHp != null) ...[
                          Text("Nomor HP", style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(nomorHp, style: AppTextStyles.body),
                          const SizedBox(height: 16),
                        ],

                        Text("Role", style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          role == 'orang_tua' ? 'Wali Santri' : role.toUpperCase(),
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Card: Ganti Password
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Ganti Password", style: AppTextStyles.h4),
                          const Divider(),
                          const SizedBox(height: 12),
                          
                          // Password Lama
                          TextFormField(
                            controller: _passwordLamaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password Lama",
                              errorText: _passwordLamaError,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Baru
                          TextFormField(
                            controller: _passwordBaruController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password Baru",
                              border: OutlineInputBorder(),
                              helperText: "Minimal 8 karakter",
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Konfirmasi Password Baru
                          TextFormField(
                            controller: _konfirmasiController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Konfirmasi Password Baru",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _isPasswordSaving ? null : _handleGantiPassword,
                            child: _isPasswordSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text("Ganti Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Button: Keluar
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _handleLogout(role),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
