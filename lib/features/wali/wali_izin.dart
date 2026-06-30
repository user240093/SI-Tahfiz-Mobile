import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class WaliIzin extends StatefulWidget {
  const WaliIzin({super.key});

  @override
  State<WaliIzin> createState() => _WaliIzinState();
}

class _WaliIzinState extends State<WaliIzin> {
  String? _selectedSantriId;
  String _reason = 'Sakit';
  final _descController = TextEditingController();

  void _submit() {
    if (_selectedSantriId != null && _descController.text.isNotEmpty) {
      Provider.of<AppProvider>(context, listen: false).addIzin(
        _selectedSantriId!,
        DateTime.now(),
        _reason,
        _descController.text,
      );
      _descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Surat izin berhasil dikirim.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    if (user == null) return const SizedBox();
    
    final santriList = provider.getSantriForWali(user.id);
    
    final List<dynamic> historyIzin = [];
    for (var s in santriList) {
      historyIzin.addAll(provider.getIzinForSantri(s.id).map((i) => {'santri': s, 'izin': i}));
    }

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
                  const Text('Buat Surat Izin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Pilih Anak'),
                    value: _selectedSantriId,
                    items: santriList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _selectedSantriId = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Alasan'),
                    value: _reason,
                    items: ['Sakit', 'Izin', 'Lainnya'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _reason = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Keterangan Tambahan'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roleWaliColor),
                    child: const Text('Kirim Surat Izin'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Riwayat Pengajuan Izin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          historyIzin.isEmpty 
            ? const Text('Belum ada riwayat izin.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historyIzin.length,
                itemBuilder: (context, index) {
                  final item = historyIzin[index];
                  final santri = item['santri'];
                  final izin = item['izin'];
                  
                  Color statusColor = Colors.orange;
                  if (izin.status == 'Approved') statusColor = Colors.green;
                  if (izin.status == 'Rejected') statusColor = Colors.red;

                  return Card(
                    child: ListTile(
                      title: Text('${santri.name} - ${izin.reason}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${izin.description}\nTgl: ${izin.date.day}/${izin.date.month}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(izin.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  );
                },
              )
        ],
      ),
    );
  }
}
