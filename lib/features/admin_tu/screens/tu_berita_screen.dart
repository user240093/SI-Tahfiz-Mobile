import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/berita_provider.dart';
import '../../../core/theme.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/supabase_client.dart';

class TuBeritaScreen extends ConsumerWidget {
  const TuBeritaScreen({super.key});

  String _formatDate(DateTime dt) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _showAddEditModal(BuildContext context, WidgetRef ref, {Map<String, dynamic>? berita}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BeritaFormModal(berita: berita),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id, String judul) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Hapus Berita', style: AppTextStyles.h4),
              content: Text('Apakah Anda yakin ingin menghapus berita "$judul"?'),
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
                          final success = await ref.read(beritaProvider.notifier).deleteBerita(id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Berita berhasil dihapus' : 'Gagal menghapus berita'),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final beritaAsync = ref.watch(beritaProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Berita Login', style: AppTextStyles.h2),
                    const SizedBox(height: 2),
                    Text('Kelola informasi pengumuman halaman login.', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),

          // News list
          Expanded(
            child: beritaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Gagal memuat berita', style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Text(err.toString(), style: AppTextStyles.bodySmall),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(beritaProvider.notifier).fetchBerita(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (beritaList) {
                if (beritaList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Belum ada berita. Ketuk tombol + di bawah untuk menambahkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: beritaList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = beritaList[index];
                    final id = item['id'].toString();
                    final title = item['judul'] ?? '';
                    final content = item['isi'] ?? '';
                    final date = item['updated_at'] != null 
                        ? DateTime.parse(item['updated_at']) 
                        : DateTime.parse(item['created_at']);
                    final dateStr = _formatDate(date);

                    // Truncate content for preview
                    final contentPreview = content.length > 120 
                        ? '${content.substring(0, 120)}...' 
                        : content;

                    return AppCard(
                      role: 'tu',
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(title, style: AppTextStyles.h4),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 20),
                                    onPressed: () => _showAddEditModal(context, ref, berita: item),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
                                    onPressed: () => _showDeleteDialog(context, ref, id, title),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(dateStr, style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),
                          Text(
                            contentPreview,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey.shade700,
                            ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditModal(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BeritaFormModal extends ConsumerStatefulWidget {
  final Map<String, dynamic>? berita;
  const _BeritaFormModal({this.berita});

  @override
  ConsumerState<_BeritaFormModal> createState() => _BeritaFormModalState();
}

class _BeritaFormModalState extends ConsumerState<_BeritaFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.berita != null) {
      _judulCtrl.text = widget.berita!['judul'] ?? '';
      _isiCtrl.text = widget.berita!['isi'] ?? '';
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _judulCtrl.text.trim();
    final content = _isiCtrl.text.trim();

    setState(() => _isSaving = true);
    bool success = false;

    try {
      if (widget.berita == null) {
        // Create
        final currentUserId = supabase.auth.currentUser?.id;
        if (currentUserId == null) {
          throw Exception('Aktor tidak terotentikasi');
        }
        success = await ref.read(beritaProvider.notifier).addBerita({
          'judul': title,
          'isi': content,
          'dibuat_oleh': currentUserId,
        });
      } else {
        // Update
        final id = widget.berita!['id'].toString();
        success = await ref.read(beritaProvider.notifier).updateBerita(id, {
          'judul': title,
          'isi': content,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.berita == null
                ? (success ? 'Berita berhasil ditambahkan' : 'Gagal menambahkan berita')
                : (success ? 'Berita berhasil diperbarui' : 'Gagal memperbarui berita')),
            backgroundColor: success ? AppTheme.primaryColor : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.berita != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Indicator & title
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Berita Login' : 'Tambah Berita Login',
                    style: AppTextStyles.h3,
                  ),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Title Input
              Text('Judul Berita', style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _judulCtrl,
                enabled: !_isSaving,
                style: GoogleFonts.outfit(color: AppTheme.textDark),
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul berita...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Field ini wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content Input
              Text('Isi Berita', style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _isiCtrl,
                enabled: !_isSaving,
                maxLines: 8,
                style: GoogleFonts.outfit(color: AppTheme.textDark),
                decoration: const InputDecoration(
                  hintText: 'Tulis isi berita di sini (teks saja)...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Field ini wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
