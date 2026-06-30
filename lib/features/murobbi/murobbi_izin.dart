import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class MurobbiIzin extends StatelessWidget {
  const MurobbiIzin({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    if (user == null) return const SizedBox();

    final santriList = provider.getSantriForMurobbi(user.id);
    
    // Get all izin records for santri binaan
    final List<dynamic> mySantriIzin = [];
    for (var s in santriList) {
      final records = provider.getIzinForSantri(s.id);
      for (var r in records) {
        mySantriIzin.add({'santri': s, 'izin': r});
      }
    }

    return mySantriIzin.isEmpty
        ? const Center(child: Text('Tidak ada riwayat izin dari santri binaan Anda.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: mySantriIzin.length,
            itemBuilder: (context, index) {
              final item = mySantriIzin[index];
              final santri = item['santri'];
              final izin = item['izin'];
              
              Color statusColor = Colors.orange;
              if (izin.status == 'Approved') statusColor = Colors.green;
              if (izin.status == 'Rejected') statusColor = Colors.red;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), child: Icon(Icons.mark_email_read, color: statusColor)),
                  title: Text('${santri.name} - ${izin.reason}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${izin.description}\nTgl: ${izin.date.day}/${izin.date.month} | Status: ${izin.status}'),
                  isThreeLine: true,
                ),
              );
            },
          );
  }
}
