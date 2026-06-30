import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class KoordinatorTikrar extends StatelessWidget {
  const KoordinatorTikrar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allSantri = provider.allSantri;
    final tikrarSantri = allSantri.where((s) => provider.isSantriInTikrar(s.id)).toList();

    return tikrarSantri.isEmpty
        ? const Center(child: Text('Alhamdulillah, tidak ada santri di program Tikrar saat ini.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: tikrarSantri.length,
            itemBuilder: (context, index) {
              final santri = tikrarSantri[index];
              return Card(
                color: AppTheme.warningColor.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.warning_rounded, color: AppTheme.warningColor),
                  title: Text(santri.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Kelas ${santri.kelas} - Tingkat kesalahan hafalan tinggi.'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Santri ditandai telah lulus dari program Tikrar (Simulasi).')));
                    },
                    child: const Text('Luluskan Tikrar'),
                  ),
                ),
              );
            },
          );
  }
}
