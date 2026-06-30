import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import 'input_setoran_screen.dart';

class MurobbiHome extends StatelessWidget {
  const MurobbiHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    if (user == null) return const SizedBox();

    final santriList = provider.getSantriForMurobbi(user.id);

    return santriList.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.group_off_rounded, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), Text('Belum ada santri binaan.', style: TextStyle(color: Colors.grey.shade600))]))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: santriList.length,
            itemBuilder: (context, index) {
              final santri = santriList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => InputSetoranScreen(santriId: santri.id, santriName: santri.name)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.roleMurobbiColor.withOpacity(0.1),
                          child: Text(santri.name[0], style: const TextStyle(color: AppTheme.roleMurobbiColor, fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(santri.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Text('Kelas ${santri.kelas}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                                  const SizedBox(width: 8),
                                  Text('NIS: ${santri.nis}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.roleMurobbiColor, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20))
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
            },
          );
  }
}
