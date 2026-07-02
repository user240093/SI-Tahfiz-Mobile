import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/halaqah_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/input_decoration.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state_widget.dart';

class TuDataSantri extends ConsumerStatefulWidget {
  const TuDataSantri({super.key});

  @override
  ConsumerState<TuDataSantri> createState() => _TuDataSantriState();
}

class _TuDataSantriState extends ConsumerState<TuDataSantri> {
  String? _selectedHalaqahId;
  String _selectedGrade = 'tahfiz';

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController();
        final kelasCtrl = TextEditingController();
        
        return Consumer(
          builder: (context, ref, child) {
            final halaqahAsync = ref.watch(halaqahProvider);

            return halaqahAsync.when(
              loading: () => const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))),
              error: (err, _) => AlertDialog(content: Text('Error load halaqah: $err')),
              data: (halaqahs) {
                if (_selectedHalaqahId == null && halaqahs.isNotEmpty) {
                  _selectedHalaqahId = halaqahs[0]['id'];
                }

                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // TU border radius
                  title: Text('Tambah Data Santri Baru', style: AppTextStyles.h4),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: AppInputDecoration.create(hintText: 'Nama Lengkap', labelText: 'Nama Lengkap'),
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: kelasCtrl,
                          decoration: AppInputDecoration.create(hintText: 'Kelas (Misal: 7A)', labelText: 'Kelas'),
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedHalaqahId,
                          decoration: AppInputDecoration.create(hintText: 'Pilih Halaqah', labelText: 'Halaqah'),
                          style: AppTextStyles.body,
                          items: halaqahs.map<DropdownMenuItem<String>>((h) {
                            return DropdownMenuItem<String>(
                              value: h['id'],
                              child: Text(h['nama_halaqah'] ?? '', style: AppTextStyles.body),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedHalaqahId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedGrade,
                          decoration: AppInputDecoration.create(hintText: 'Pilih Grade', labelText: 'Grade'),
                          style: AppTextStyles.body,
                          items: [
                            DropdownMenuItem(value: 'tahsin', child: Text('Tahsin', style: AppTextStyles.body)),
                            DropdownMenuItem(value: 'takmil', child: Text('Takmil', style: AppTextStyles.body)),
                            DropdownMenuItem(value: 'tahfiz', child: Text('Tahfiz', style: AppTextStyles.body)),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedGrade = val!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    AppButton.structured(
                      text: 'Batal',
                      variant: AppButtonVariant.secondary,
                      isSmall: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                    AppButton.structured(
                      text: 'Simpan',
                      variant: AppButtonVariant.primary,
                      isSmall: true,
                      onPressed: () async {
                        if (nameCtrl.text.isNotEmpty && kelasCtrl.text.isNotEmpty && _selectedHalaqahId != null) {
                          final success = await ref.read(santriProvider.notifier).addSantri({
                            'nama_lengkap': nameCtrl.text,
                            'kelas': kelasCtrl.text,
                            'grade': _selectedGrade,
                            'halaqah_id': _selectedHalaqahId,
                          });
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final santriAsync = ref.watch(santriProvider);

    return santriAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(santriProvider)),
      data: (santriList) {
        return Padding(
          padding: const EdgeInsets.all(16), // TU: compact spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buku Induk Data Santri',
                    style: AppTextStyles.h4,
                  ),
                  AppButton.structured(
                    text: 'Tambah Santri',
                    isSmall: true,
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.person_add, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AppCard(
                  role: 'tu',
                  padding: EdgeInsets.zero,
                  child: santriList.isEmpty
                      ? Center(child: Text('Belum ada data santri.', style: AppTextStyles.body))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
                              columns: [
                                DataColumn(label: Text('ID', style: AppTextStyles.h6.copyWith(color: const Color(0xFF374151)))),
                                DataColumn(label: Text('Nama Lengkap', style: AppTextStyles.h6.copyWith(color: const Color(0xFF374151)))),
                                DataColumn(label: Text('Kelas', style: AppTextStyles.h6.copyWith(color: const Color(0xFF374151)))),
                                DataColumn(label: Text('Aksi', style: AppTextStyles.h6.copyWith(color: const Color(0xFF374151)))),
                              ],
                              rows: santriList.map((s) {
                                return DataRow(cells: [
                                  DataCell(Text(s['id'].toString().substring(0, 8), style: AppTextStyles.body)),
                                  DataCell(Text(s['nama_lengkap'] ?? '', style: AppTextStyles.body)),
                                  DataCell(Text(s['kelas'] ?? '', style: AppTextStyles.body)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                        onPressed: () {},
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () {},
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
