import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/akhlaq_provider.dart';
import '../../../core/providers/konfigurasi_provider.dart';
import '../../../core/supabase_client.dart';
import '../../../core/text_styles.dart';
import '../../../core/button_styles.dart';
import '../../../core/input_decoration.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PengampuAkhlaqScreen extends ConsumerStatefulWidget {
  const PengampuAkhlaqScreen({super.key});

  @override
  ConsumerState<PengampuAkhlaqScreen> createState() => _PengampuAkhlaqScreenState();
}

class _PengampuAkhlaqScreenState extends ConsumerState<PengampuAkhlaqScreen> {
  bool _isLoading = true;
  String? _halaqahId;
  String _semester = 'ganjil';
  String _tahunAjaran = '2025/2026';
  List<Map<String, dynamic>> _santriList = [];
  Map<String, Map<String, dynamic>> _akhlaqMap = {}; // santriId -> akhlaq record

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFiturAndLoad();
    });
  }

  Future<void> _checkFiturAndLoad() async {
    setState(() => _isLoading = true);
    try {
      // Step 1: Check fiturs status
      final configRes = await supabase
          .from('konfigurasi')
          .select('fitur_akhlaq_aktif')
          .maybeSingle();

      final active = configRes?['fitur_akhlaq_aktif'] ?? false;
      if (!active) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/pengampu/beranda');
        }
        return;
      }

      // Step 2: Load data
      final user = ref.read(authProvider);
      final userId = user?.supabaseUser?.id ?? user?.id ?? '';

      // Get semester and tahun ajaran from configuration provider
      final semTahun = ref.read(semesterTahunAjaranProvider);
      _semester = semTahun['semester'] ?? 'ganjil';
      _tahunAjaran = semTahun['tahun_ajaran'] ?? '2025/2026';

      // Load halaqah
      final halaqahRes = await supabase
          .from('halaqah')
          .select('id')
          .eq('pengampu_id', userId)
          .maybeSingle();

      if (halaqahRes != null) {
        _halaqahId = halaqahRes['id'] as String;

        // Load all santri in halaqah
        final santriRes = await supabase
            .from('santri')
            .select('id, nama_lengkap')
            .eq('halaqah_id', _halaqahId!)
            .order('nama_lengkap');
        _santriList = List<Map<String, dynamic>>.from(santriRes);

        // Load akhlaq list
        final akhlaqList = await ref.read(akhlaqProvider.notifier).fetchAkhlaqByHalaqah(_halaqahId!, _semester, _tahunAjaran);
        
        _akhlaqMap = {};
        for (var akhlaq in akhlaqList) {
          final sId = akhlaq['santri_id'] as String;
          _akhlaqMap[sId] = akhlaq;
        }
      }
    } catch (e) {
      debugPrint('Error in _checkFiturAndLoad: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAkhlaqDialog(Map<String, dynamic> santri) {
    final santriId = santri['id'] as String;
    final santriNama = santri['nama_lengkap'] ?? '';
    final existingAkhlaq = _akhlaqMap[santriId];

    final formKey = GlobalKey<FormState>();
    final valueController = TextEditingController(
      text: existingAkhlaq != null ? existingAkhlaq['nilai'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Nilai Akhlaq — $santriNama', style: AppTextStyles.h3),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Semester: ${_semester.toUpperCase()} | TA: $_tahunAjaran',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: AppInputDecoration.create(
                    hintText: 'Masukkan nilai (0-100)',
                    labelText: 'Nilai Akhlaq',
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
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final val = int.parse(valueController.text);
                  try {
                    await ref.read(akhlaqProvider.notifier).upsertAkhlaq(
                          santriId,
                          val,
                          _semester,
                          _tahunAjaran,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nilai akhlaq berhasil disimpan')),
                      );
                    }
                    Navigator.pop(context);
                    _checkFiturAndLoad();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: Text('Simpan', style: AppTextStyles.h5.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Nilai Akhlaq';
    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'pengampu',
        isNested: true,
        title: title,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _santriList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Tidak ada santri di halaqah ini.',
                      style: AppTextStyles.body,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _santriList.length,
                  itemBuilder: (context, index) {
                    final santri = _santriList[index];
                    final santriId = santri['id'] as String;
                    final santriNama = santri['nama_lengkap'] ?? '';

                    final akhlaq = _akhlaqMap[santriId];

                    Widget statusWidget;
                    String btnText;

                    if (akhlaq == null) {
                      statusWidget = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Belum diinput',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                      btnText = 'Input';
                    } else {
                      statusWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                            ),
                            child: Text(
                              'Nilai: ${akhlaq['nilai']}',
                              style: const TextStyle(
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                      btnText = 'Edit';
                    }

                    return AppCard(
                      role: 'pengampu',
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(santriNama, style: AppTextStyles.h4),
                                const SizedBox(height: 8),
                                statusWidget,
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () => _showAkhlaqDialog(santri),
                            child: Text(
                              btnText,
                              style: AppTextStyles.body.copyWith(
                                color: const Color(0xFFF59E0B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
