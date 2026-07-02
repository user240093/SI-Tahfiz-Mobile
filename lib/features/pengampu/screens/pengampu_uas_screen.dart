import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/uas_provider.dart';
import '../../../core/providers/konfigurasi_provider.dart';
import '../../../core/supabase_client.dart';
import '../../../core/text_styles.dart';
import '../../../core/button_styles.dart';
import '../../../core/input_decoration.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PengampuUasScreen extends ConsumerStatefulWidget {
  const PengampuUasScreen({super.key});

  @override
  ConsumerState<PengampuUasScreen> createState() => _PengampuUasScreenState();
}

class _PengampuUasScreenState extends ConsumerState<PengampuUasScreen> {
  bool _isLoading = true;
  String? _halaqahId;
  String _semester = 'ganjil';
  String _tahunAjaran = '2025/2026';
  List<Map<String, dynamic>> _santriList = [];
  Map<String, Map<String, dynamic>> _uasMap = {}; // santriId -> uas record

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

      // Get current semester and tahun ajaran from configuration provider
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

        // Load uas list
        final uasList = await ref.read(uasProvider.notifier).fetchUasByHalaqah(_halaqahId!, _semester, _tahunAjaran);
        
        _uasMap = {};
        for (var uas in uasList) {
          final sId = uas['santri_id'] as String;
          _uasMap[sId] = uas;
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUasModal(Map<String, dynamic> santri) {
    final santriId = santri['id'] as String;
    final santriNama = santri['nama_lengkap'] ?? '';
    final existingUas = _uasMap[santriId];
    
    // Initialize list of juz inputs
    List<Map<String, dynamic>> juzList = [];
    if (existingUas != null && existingUas['uas_detail'] != null) {
      final details = existingUas['uas_detail'] as List;
      for (var det in details) {
        juzList.add({
          'nomor_juz': det['nomor_juz'],
          'nilai': det['nilai'],
        });
      }
    }

    // Default: 3 rows if none exist
    if (juzList.isEmpty) {
      juzList = [
        {'nomor_juz': null, 'nilai': null},
        {'nomor_juz': null, 'nilai': null},
        {'nomor_juz': null, 'nilai': null},
      ];
    }

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Live calculation preview
            double? average;
            bool isAllFilled = true;
            int filledCount = 0;
            double sum = 0;

            for (var j in juzList) {
              if (j['nilai'] != null) {
                sum += j['nilai'];
                filledCount++;
              } else {
                isAllFilled = false;
              }
            }
            if (filledCount > 0) {
              average = (sum / filledCount * 10).round() / 10;
            }

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
                        'Nilai UAS — $santriNama',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semester: ${_semester.toUpperCase()} | TA: $_tahunAjaran',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),

                      // List of juz input rows
                      ...List.generate(juzList.length, (index) {
                        final item = juzList[index];
                        final numController = TextEditingController(
                          text: item['nomor_juz'] != null ? item['nomor_juz'].toString() : '',
                        );
                        final valController = TextEditingController(
                          text: item['nilai'] != null ? item['nilai'].toString() : '',
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Juz Label & Number field
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: numController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: AppInputDecoration.create(
                                    hintText: 'Juz (1-30)',
                                    labelText: 'Juz ke-${index + 1}',
                                  ),
                                  style: AppTextStyles.body,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Wajib';
                                    final valInt = int.tryParse(val);
                                    if (valInt == null || valInt < 1 || valInt > 30) {
                                      return '1-30';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    juzList[index]['nomor_juz'] = parsed;
                                    setModalState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Nilai field
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: valController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: AppInputDecoration.create(
                                    hintText: 'Nilai (0-100)',
                                    labelText: 'Nilai',
                                  ),
                                  style: AppTextStyles.body,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Wajib';
                                    final valInt = int.tryParse(val);
                                    if (valInt == null || valInt < 0 || valInt > 100) {
                                      return '0-100';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    juzList[index]['nilai'] = parsed;
                                    setModalState(() {});
                                  },
                                ),
                              ),

                              // Delete button (minimum 1 row)
                              if (juzList.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      juzList.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                      // Add Juz Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              juzList.add({'nomor_juz': null, 'nilai': null});
                            });
                          },
                          icon: const Icon(Icons.add, color: Color(0xFF10B981)),
                          label: Text('Tambah Juz', style: AppTextStyles.body.copyWith(color: const Color(0xFF10B981))),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Live Calculation Preview
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nilai Akhir UAS:',
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isAllFilled && average != null
                                  ? average.toString()
                                  : 'Belum lengkap',
                              style: AppTextStyles.h4.copyWith(
                                color: isAllFilled && average != null
                                    ? const Color(0xFF10B981)
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      AppButton.warm(
                        text: 'Simpan',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            // Validation: Check duplicate nomor_juz
                            final juzNumbers = juzList.map((j) => j['nomor_juz']).toList();
                            final uniqueJuzs = juzNumbers.toSet();
                            if (uniqueJuzs.length != juzNumbers.length) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nomor juz tidak boleh ada yang duplikat'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              await ref.read(uasProvider.notifier).upsertUas(
                                    santriId,
                                    juzList,
                                    _semester,
                                    _tahunAjaran,
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nilai UAS berhasil disimpan')),
                                );
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

  @override
  Widget build(BuildContext context) {
    final title = 'UAS';
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

                    final uas = _uasMap[santriId];

                    Widget statusWidget;
                    String btnText;

                    if (uas == null) {
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
                      btnText = 'Input UAS';
                    } else if (uas['nilai_akhir'] == null) {
                      statusWidget = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                        ),
                        child: const Text(
                          'Belum lengkap',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                      btnText = 'Edit UAS';
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
                              'Nilai Akhir: ${uas['nilai_akhir']}',
                              style: const TextStyle(
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                      btnText = 'Edit UAS';
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
                            onPressed: () => _showUasModal(santri),
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
