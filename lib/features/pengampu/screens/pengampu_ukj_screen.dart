import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/ukj_provider.dart';
import '../../../core/supabase_client.dart';
import '../../../core/text_styles.dart';
import '../../../core/button_styles.dart';
import '../../../core/input_decoration.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PengampuUkjScreen extends ConsumerStatefulWidget {
  const PengampuUkjScreen({super.key});

  @override
  ConsumerState<PengampuUkjScreen> createState() => _PengampuUkjScreenState();
}

class _PengampuUkjScreenState extends ConsumerState<PengampuUkjScreen> {
  bool _isLoading = true;
  String? _halaqahId;
  List<Map<String, dynamic>> _ukjList = [];
  List<Map<String, dynamic>> _santriList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider);
      final userId = user?.supabaseUser?.id ?? user?.id ?? '';
      
      // Load halaqah id
      final halaqahRes = await supabase
          .from('halaqah')
          .select('id')
          .eq('pengampu_id', userId)
          .maybeSingle();

      if (halaqahRes != null) {
        _halaqahId = halaqahRes['id'] as String;

        // Load UKJ list
        _ukjList = await ref.read(ukjProvider.notifier).fetchUkjHalaqah(_halaqahId!);

        // Load Santri list
        final santriRes = await supabase
            .from('santri')
            .select('id, nama_lengkap')
            .eq('halaqah_id', _halaqahId!)
            .order('nama_lengkap');
        _santriList = List<Map<String, dynamic>>.from(santriRes);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUkjModal({Map<String, dynamic>? existingUkj}) {
    final isEdit = existingUkj != null;
    final formKey = GlobalKey<FormState>();

    String? selectedSantriId = existingUkj?['santri_id'];
    final juzController = TextEditingController(
      text: existingUkj != null ? existingUkj['nomor_juz'].toString() : '',
    );
    final nilaiController = TextEditingController(
      text: existingUkj != null ? existingUkj['nilai'].toString() : '',
    );
    String selectedStatus = existingUkj?['status_santri'] ?? 'lulus';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? 'Edit Hasil UKJ' : 'Input Hasil UKJ',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Dropdown Santri
                      if (isEdit) ...[
                        // Read-only Text for Santri Name when editing
                        TextFormField(
                          initialValue: existingUkj['santri']['nama_lengkap'],
                          decoration: AppInputDecoration.create(
                            hintText: '',
                            labelText: 'Santri',
                          ),
                          enabled: false,
                          style: AppTextStyles.body,
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          decoration: AppInputDecoration.create(
                            hintText: 'Pilih Santri',
                            labelText: 'Santri',
                          ),
                          style: AppTextStyles.body,
                          value: selectedSantriId,
                          items: _santriList.map((s) {
                            return DropdownMenuItem<String>(
                              value: s['id'].toString(),
                              child: Text(s['nama_lengkap'] ?? '', style: AppTextStyles.body),
                            );
                          }).toList(),
                          validator: (val) => val == null ? 'Santri harus dipilih' : null,
                          onChanged: (val) => setModalState(() => selectedSantriId = val),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Nomor Juz
                      TextFormField(
                        controller: juzController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: AppInputDecoration.create(
                          hintText: 'Masukkan nomor juz (1-30)',
                          labelText: 'Nomor Juz',
                        ),
                        style: AppTextStyles.body,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Nomor juz wajib diisi';
                          final valInt = int.tryParse(val);
                          if (valInt == null || valInt < 1 || valInt > 30) {
                            return 'Nomor juz tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nilai
                      TextFormField(
                        controller: nilaiController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: AppInputDecoration.create(
                          hintText: 'Masukkan nilai (0-100)',
                          labelText: 'Nilai',
                        ),
                        style: AppTextStyles.body,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Nilai wajib diisi';
                          final valInt = int.tryParse(val);
                          if (valInt == null || valInt < 0 || valInt > 100) {
                            return 'Nilai harus antara 0 dan 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Status Santri Dropdown
                      DropdownButtonFormField<String>(
                        decoration: AppInputDecoration.create(
                          hintText: 'Pilih Status Santri',
                          labelText: 'Status Santri',
                        ),
                        style: AppTextStyles.body,
                        value: selectedStatus,
                        items: [
                          DropdownMenuItem<String>(
                            value: 'lulus',
                            child: Text('Lulus', style: AppTextStyles.body),
                          ),
                          DropdownMenuItem<String>(
                            value: 'mengulang',
                            child: Text('Mengulang', style: AppTextStyles.body),
                          ),
                        ],
                        validator: (val) => val == null ? 'Status santri harus dipilih' : null,
                        onChanged: (val) => setModalState(() => selectedStatus = val!),
                      ),
                      const SizedBox(height: 24),

                      // Action Button
                      AppButton.warm(
                        text: 'Simpan',
                        onPressed: () async {
                          if (formKey.currentState!.validate() && selectedSantriId != null) {
                            final user = ref.read(authProvider);
                            final pengampuId = user?.supabaseUser?.id ?? user?.id ?? '';
                            final nomorJuz = int.parse(juzController.text);
                            final nilai = int.parse(nilaiController.text);

                            try {
                              if (isEdit) {
                                await ref.read(ukjProvider.notifier).updateUkjPending(
                                  ukjId: existingUkj['id'],
                                  nomorJuz: nomorJuz,
                                  nilai: nilai,
                                  statusSantri: selectedStatus,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('UKJ berhasil diperbarui')),
                                  );
                                }
                              } else {
                                await ref.read(ukjProvider.notifier).insertUkj(
                                  santriId: selectedSantriId!,
                                  pengampuId: pengampuId,
                                  nomorJuz: nomorJuz,
                                  nilai: nilai,
                                  statusSantri: selectedStatus,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Hasil UKJ berhasil diinput, menunggu persetujuan koordinator'),
                                    ),
                                  );
                                }
                              }
                              Navigator.pop(context);
                              _loadData();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final isLulus = status.toLowerCase() == 'lulus';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLulus ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isLulus ? 'Lulus' : 'Mengulang',
        style: TextStyle(
          color: isLulus ? const Color(0xFF065F46) : const Color(0xFF991B1B),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildApprovalBadge(String approval, String? alasan) {
    Color bg;
    Color text;
    String label;

    switch (approval.toLowerCase()) {
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        label = 'Menunggu Approval';
        break;
      case 'approved':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF065F46);
        label = 'Disetujui';
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFF991B1B);
        label = 'Ditolak';
        break;
      default:
        bg = Colors.grey.shade200;
        text = Colors.grey.shade800;
        label = approval;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        if (approval.toLowerCase() == 'rejected' && alasan != null && alasan.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Alasan: $alasan',
            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF991B1B)),
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'UKJ';
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'pengampu',
        isNested: true,
        title: title,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUkjModal(),
        backgroundColor: const Color(0xFFF59E0B), // Warm color
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Input UKJ', style: AppTextStyles.h5.copyWith(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ukjList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Belum ada riwayat UKJ di halaqah ini.',
                      style: AppTextStyles.body,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _ukjList.length,
                  itemBuilder: (context, index) {
                    final ukj = _ukjList[index];
                    final santri = ukj['santri'] ?? {};
                    final santriNama = santri['nama_lengkap'] ?? '';
                    final juz = ukj['nomor_juz'];
                    final nilai = ukj['nilai'];
                    final statusSantri = ukj['status_santri'] ?? '';
                    final statusApproval = ukj['status_approval'] ?? 'pending';
                    final alasan = ukj['alasan_penolakan'];

                    final isPending = statusApproval.toLowerCase() == 'pending';

                    return AppCard(
                      role: 'pengampu',
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(santriNama, style: AppTextStyles.h4),
                                const SizedBox(height: 8),
                                Text(
                                  'Juz $juz | Nilai: $nilai',
                                  style: AppTextStyles.body,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildStatusBadge(statusSantri),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildApprovalBadge(statusApproval, alasan)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isPending)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () => _showUkjModal(existingUkj: ukj),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
