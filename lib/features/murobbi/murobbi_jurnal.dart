import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/santri_provider.dart';
import '../../core/providers/akhlaq_provider.dart';
import '../../core/text_styles.dart';
import '../../core/button_styles.dart';
import '../../core/input_decoration.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/error_state_widget.dart';

class MurobbiJurnal extends ConsumerStatefulWidget {
  const MurobbiJurnal({super.key});

  @override
  ConsumerState<MurobbiJurnal> createState() => _MurobbiJurnalState();
}

class _MurobbiJurnalState extends ConsumerState<MurobbiJurnal> {
  String? _selectedSantriId;
  final _noteController = TextEditingController();
  final _akhlaqController = TextEditingController();

  void _submit() {
    final user = ref.read(authProvider);
    if (user != null && _selectedSantriId != null && _akhlaqController.text.isNotEmpty) {
      ref.read(akhlaqProvider.notifier).addAkhlaq({
        'santri_id': _selectedSantriId!,
        'pengampu_id': user.supabaseUser?.id ?? user.id,
        'semester': 'ganjil',
        'tahun_ajaran': '2025/2026',
        'nilai': int.parse(_akhlaqController.text),
      });
      _noteController.clear();
      _akhlaqController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jurnal/Nilai Akhlaq berhasil disimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();
    
    final santriListAsync = ref.watch(santriForMurobbiProvider(user.id));

    final content = santriListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(santriProvider)),
      data: (santriList) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                role: 'pengampu',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Input Jurnal & Akhlaq', style: AppTextStyles.h4),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: AppInputDecoration.create(hintText: 'Pilih Santri', labelText: 'Santri'),
                      style: AppTextStyles.body,
                      value: _selectedSantriId,
                      items: santriList.map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text(s['nama_lengkap'] ?? '', style: AppTextStyles.body))).toList(),
                      onChanged: (val) => setState(() => _selectedSantriId = val),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: AppInputDecoration.create(
                        hintText: 'Catatan Evaluasi Harian (opsional)',
                        labelText: 'Catatan Evaluasi',
                      ),
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _akhlaqController,
                      keyboardType: TextInputType.number,
                      decoration: AppInputDecoration.create(
                        hintText: 'Nilai Akhlaq Harian (1-100)',
                        labelText: 'Nilai Akhlaq',
                      ),
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 20),
                    AppButton.warm(
                      text: 'Simpan Jurnal',
                      onPressed: _submit,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Histori Jurnal', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _selectedSantriId == null 
                ? Text('Pilih santri untuk melihat histori.', style: AppTextStyles.body)
                : Consumer(
                    builder: (context, ref, child) {
                      final journalsAsync = ref.watch(akhlaqForSantriProvider(_selectedSantriId!));
                      return journalsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error: $err', style: AppTextStyles.body.copyWith(color: Colors.red)),
                        data: (journals) {
                          if (journals.isEmpty) {
                            return Text('Belum ada histori jurnal untuk santri ini.', style: AppTextStyles.body);
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: journals.length,
                            itemBuilder: (context, index) {
                              final j = journals[index];
                              final date = j['date'] as DateTime;
                              return AppCard(
                                role: 'pengampu',
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  title: Text(j['note'], style: AppTextStyles.body),
                                  subtitle: Text(
                                    'Nilai Akhlaq: ${j['akhlaqScore']} | Tgl: ${date.day}/${date.month}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
            ],
          ),
        );
      },
    );

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'pengampu',
        isNested: true,
        title: 'Input Jurnal & Akhlaq',
      ),
      body: content,
    );
  }
}
