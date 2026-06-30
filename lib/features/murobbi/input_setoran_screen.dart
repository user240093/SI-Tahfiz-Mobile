import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_provider.dart';
import '../../core/mock_data.dart';
import '../../core/theme.dart';

class InputSetoranScreen extends StatefulWidget {
  final String santriId;
  final String santriName;

  const InputSetoranScreen({super.key, required this.santriId, required this.santriName});

  @override
  State<InputSetoranScreen> createState() => _InputSetoranScreenState();
}

class _InputSetoranScreenState extends State<InputSetoranScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Sabak';
  final _surahController = TextEditingController();
  final _ayatStartController = TextEditingController();
  final _ayatEndController = TextEditingController();
  final _kesalahanController = TextEditingController(text: '0');

  final List<String> _types = ['Sabak', 'Sabki', 'Manzil'];

  @override
  void dispose() {
    _surahController.dispose();
    _ayatStartController.dispose();
    _ayatEndController.dispose();
    _kesalahanController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final newSetoran = Setoran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        santriId: widget.santriId,
        date: DateTime.now(),
        type: _selectedType,
        surah: _surahController.text,
        ayatStart: int.parse(_ayatStartController.text),
        ayatEnd: int.parse(_ayatEndController.text),
        kesalahan: int.parse(_kesalahanController.text),
      );

      final success = provider.addSetoran(newSetoran);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Setoran berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal! Entri $_selectedType untuk hari ini sudah ada.')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final historySetoran = provider.getSetoranForSantri(widget.santriId);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Setoran'),
        backgroundColor: AppTheme.roleMurobbiColor,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              decoration: BoxDecoration(
                color: AppTheme.roleMurobbiColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.santriName[0],
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.santriName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.2).fadeIn(),
            
            // Form Card
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Form Setoran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Tipe Setoran',
                              prefixIcon: Icon(Icons.category_rounded),
                            ),
                            items: _types.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedType = val!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _surahController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Surah',
                              prefixIcon: Icon(Icons.book_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ayatStartController,
                                  decoration: const InputDecoration(
                                    labelText: 'Ayat Mulai',
                                    prefixIcon: Icon(Icons.format_list_numbered_rounded),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? 'Isi' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _ayatEndController,
                                  decoration: const InputDecoration(
                                    labelText: 'Ayat Selesai',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? 'Isi' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _kesalahanController,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Kesalahan',
                              prefixIcon: Icon(Icons.warning_rounded),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Isi dengan 0 jika lancar' : null,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.roleMurobbiColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _submit,
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Simpan Setoran'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            ),
            
            // History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Histori Setoran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  historySetoran.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Text('Belum ada histori setoran.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: historySetoran.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final s = historySetoran[index];
                            Color typeColor = AppTheme.primaryColor;
                            if (s.type == 'Sabak') typeColor = Colors.blue;
                            if (s.type == 'Sabki') typeColor = Colors.orange;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.history_edu_rounded, color: typeColor),
                                ),
                                title: Text('${s.type} - ${s.surah} (${s.ayatStart}-${s.ayatEnd})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Tanggal: ${s.date.day}/${s.date.month}/${s.date.year}\nKesalahan: ${s.kesalahan}', style: TextStyle(color: Colors.grey.shade600)),
                                trailing: s.type == 'Manzil' 
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(s.isValidatedByWali ? Icons.verified_rounded : Icons.pending_rounded, 
                                             color: s.isValidatedByWali ? Colors.green : Colors.orange),
                                        Text(s.isValidatedByWali ? 'Valid' : 'Pending', 
                                             style: TextStyle(fontSize: 10, color: s.isValidatedByWali ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  : null,
                              ),
                            ).animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(begin: 0.1);
                          },
                        ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
