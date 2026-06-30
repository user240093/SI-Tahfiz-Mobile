import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/mock_data.dart'; // To get Santri model

class TuDataSantri extends StatefulWidget {
  const TuDataSantri({super.key});

  @override
  State<TuDataSantri> createState() => _TuDataSantriState();
}

class _TuDataSantriState extends State<TuDataSantri> {
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController();
        final nisCtrl = TextEditingController();
        final kelasCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Tambah Data Santri Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              TextField(controller: nisCtrl, decoration: const InputDecoration(labelText: 'NIS')),
              TextField(controller: kelasCtrl, decoration: const InputDecoration(labelText: 'Kelas (Misal: 7A)')),
              const SizedBox(height: 8),
              const Text('Wali & Murobbi akan otomatis di-assign ke user dummy untuk simulasi.', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && nisCtrl.text.isNotEmpty && kelasCtrl.text.isNotEmpty) {
                  final newSantri = Santri(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nis: nisCtrl.text,
                    name: nameCtrl.text,
                    kelas: kelasCtrl.text,
                    waliId: 'u2', // Mock
                    murobbiId: 'u1', // Mock
                  );
                  Provider.of<AppProvider>(context, listen: false).addSantri(newSantri);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final santriList = provider.allSantri;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Buku Induk Data Santri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Tambah Santri'),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('NIS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: santriList.map((s) {
                    return DataRow(cells: [
                      DataCell(Text(s.nis)),
                      DataCell(Text(s.name)),
                      DataCell(Text(s.kelas)),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
