import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class KoordinatorPengumuman extends StatefulWidget {
  const KoordinatorPengumuman({super.key});

  @override
  State<KoordinatorPengumuman> createState() => _KoordinatorPengumumanState();
}

class _KoordinatorPengumumanState extends State<KoordinatorPengumuman> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submit() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      Provider.of<AppProvider>(context, listen: false).addAnnouncement(_titleController.text, _contentController.text);
      _titleController.clear();
      _contentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengumuman berhasil di-broadcast!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final announcements = provider.allAnnouncements;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Buat Pengumuman Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Judul Pengumuman'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Isi Pengumuman'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roleKoordinatorColor),
                      onPressed: _submit,
                      child: const Text('Broadcast Sekarang'),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (MediaQuery.of(context).size.width > 800) const SizedBox(width: 24),
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final a = announcements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(a.content),
                      trailing: Text('${a.date.day}/${a.date.month}'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
