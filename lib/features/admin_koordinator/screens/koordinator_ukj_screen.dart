import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/ukj_provider.dart';
import '../../../core/text_styles.dart';
import '../../../core/button_styles.dart';
import '../../../core/input_decoration.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_app_bar.dart';

class KoordinatorUkjScreen extends ConsumerStatefulWidget {
  const KoordinatorUkjScreen({super.key});

  @override
  ConsumerState<KoordinatorUkjScreen> createState() => _KoordinatorUkjScreenState();
}

class _KoordinatorUkjScreenState extends ConsumerState<KoordinatorUkjScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingUkj();
    });
  }

  Future<void> _loadPendingUkj() async {
    setState(() => _isLoading = true);
    try {
      _pendingList = await ref.read(ukjProvider.notifier).fetchUkjPending();
    } catch (e) {
      debugPrint('Error loading pending UKJ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showApproveDialog(Map<String, dynamic> ukj) {
    final ukjId = ukj['id'] as String;
    final santri = ukj['santri'] ?? {};
    final santriNama = santri['nama_lengkap'] ?? '';
    final juz = ukj['nomor_juz'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Approve UKJ', style: AppTextStyles.h3),
          content: Text('Setujui hasil UKJ $santriNama Juz $juz ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppTextStyles.body.copyWith(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Green
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final user = ref.read(authProvider);
                final coordId = user?.supabaseUser?.id ?? user?.id ?? '';
                try {
                  await ref.read(ukjProvider.notifier).approveUkj(ukjId, coordId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UKJ berhasil disetujui')),
                    );
                  }
                  Navigator.pop(context);
                  _loadPendingUkj();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Text('Setujui', style: AppTextStyles.h5.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(Map<String, dynamic> ukj) {
    final ukjId = ukj['id'] as String;
    final santri = ukj['santri'] ?? {};
    final santriNama = santri['nama_lengkap'] ?? '';
    final juz = ukj['nomor_juz'];

    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tolak UKJ', style: AppTextStyles.h3),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tolak hasil UKJ $santriNama Juz $juz ini?'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: AppInputDecoration.create(
                    hintText: 'Masukkan alasan penolakan',
                    labelText: 'Alasan Penolakan',
                  ),
                  style: AppTextStyles.body,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Alasan penolakan wajib diisi';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppTextStyles.body.copyWith(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), // Red
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final user = ref.read(authProvider);
                  final coordId = user?.supabaseUser?.id ?? user?.id ?? '';
                  final alasan = reasonController.text.trim();
                  try {
                    await ref.read(ukjProvider.notifier).rejectUkj(ukjId, alasan, coordId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UKJ berhasil ditolak')),
                      );
                    }
                    Navigator.pop(context);
                    _loadPendingUkj();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: Text('Tolak', style: AppTextStyles.h5.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Approval UKJ';
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'koordinator',
        isNested: true,
        title: title,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Tidak ada UKJ yang menunggu persetujuan',
                      style: AppTextStyles.body,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _pendingList.length,
                  itemBuilder: (context, index) {
                    final ukj = _pendingList[index];
                    final santri = ukj['santri'] ?? {};
                    final santriNama = santri['nama_lengkap'] ?? '';
                    final halaqah = santri['halaqah'] ?? {};
                    final halaqahNama = halaqah['nama_halaqah'] ?? 'Belum ada Halaqah';
                    final pengampu = ukj['profiles'] ?? {};
                    final pengampuNama = pengampu['nama_lengkap'] ?? 'Unknown';
                    final juz = ukj['nomor_juz'];
                    final nilai = ukj['nilai'];
                    final statusSantri = ukj['status_santri'] ?? '';

                    return AppCard(
                      role: 'koordinator',
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(santriNama, style: AppTextStyles.h4),
                          const SizedBox(height: 4),
                          Text('Halaqah: $halaqahNama', style: AppTextStyles.bodySmall),
                          Text('Pengampu: $pengampuNama', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Juz ke-$juz', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                              Text('Nilai: $nilai', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusSantri.toLowerCase() == 'lulus' ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusSantri.toLowerCase() == 'lulus' ? 'Lulus' : 'Mengulang',
                                  style: TextStyle(
                                    color: statusSantri.toLowerCase() == 'lulus' ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppButton.clean(
                                text: 'Tolak',
                                variant: AppButtonVariant.danger,
                                isSmall: true,
                                onPressed: () => _showRejectDialog(ukj),
                              ),
                              const SizedBox(width: 12),
                              AppButton.clean(
                                text: 'Setujui',
                                variant: AppButtonVariant.primary,
                                isSmall: true,
                                onPressed: () => _showApproveDialog(ukj),
                                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
