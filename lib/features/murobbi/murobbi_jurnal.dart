import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class MurobbiJurnal extends StatefulWidget {
  const MurobbiJurnal({super.key});

  @override
  State<MurobbiJurnal> createState() => _MurobbiJurnalState();
}

class _MurobbiJurnalState extends State<MurobbiJurnal> {
  String? _selectedSantriId;
  final _noteController = TextEditingController();
  final _akhlaqController = TextEditingController();

  void _submit() {
    if (_selectedSantriId != null && _noteController.text.isNotEmpty && _akhlaqController.text.isNotEmpty) {
      Provider.of<AppProvider>(context, listen: false).addJournal(
        _selectedSantriId!,
        _noteController.text,
        int.parse(_akhlaqController.text),
      );
      _noteController.clear();
      _akhlaqController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurnal berhasil disimpan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    if (user == null) return const SizedBox();
    
    final santriList = provider.getSantriForMurobbi(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Input Jurnal & Akhlaq', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Pilih Santri'),
                    value: _selectedSantriId,
                    items: santriList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _selectedSantriId = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Catatan Evaluasi Harian'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _akhlaqController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nilai Akhlaq Harian (1-100)'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roleMurobbiColor),
                    child: const Text('Simpan Jurnal'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Histori Jurnal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _selectedSantriId == null 
            ? const Text('Pilih santri untuk melihat histori.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.getJournalForSantri(_selectedSantriId!).length,
                itemBuilder: (context, index) {
                  final j = provider.getJournalForSantri(_selectedSantriId!)[index];
                  return Card(
                    child: ListTile(
                      title: Text(j.note),
                      subtitle: Text('Nilai Akhlaq: ${j.akhlaqScore} | Tgl: ${j.date.day}/${j.date.month}'),
                    ),
                  );
                },
              )
        ],
      ),
    );
  }
}
