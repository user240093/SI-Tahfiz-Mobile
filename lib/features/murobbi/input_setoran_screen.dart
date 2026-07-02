import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/setoran_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/error_state_widget.dart';

class InputSetoranScreen extends ConsumerStatefulWidget {
  final String santriId;
  final String santriName;

  const InputSetoranScreen({super.key, required this.santriId, required this.santriName});

  @override
  ConsumerState<InputSetoranScreen> createState() => _InputSetoranScreenState();
}

class _InputSetoranScreenState extends ConsumerState<InputSetoranScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Sabak';
  String _selectedStatus = 'Lulus';
  
  final _halamanAwalController = TextEditingController();
  final _halamanAkhirController = TextEditingController();
  final _jumlahBarisController = TextEditingController();
  final _kesalahanController = TextEditingController(text: '0');

  final List<String> _types = ['Sabak', 'Sabki', 'Manzil'];
  final List<String> _statuses = ['Lulus', 'Mengulang'];

  @override
  void dispose() {
    _halamanAwalController.dispose();
    _halamanAkhirController.dispose();
    _jumlahBarisController.dispose();
    _kesalahanController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authProvider);
      final myId = user?.supabaseUser?.id ?? user?.id;
      if (myId == null) return;

      final success = await ref.read(setoranProvider.notifier).insertSetoran({
        'santri_id': widget.santriId,
        'tipe': _selectedType.toLowerCase(),
        'tanggal': DateTime.now().toIso8601String().substring(0, 10),
        'jumlah_baris': int.parse(_jumlahBarisController.text),
        'halaman_awal': int.parse(_halamanAwalController.text),
        'halaman_akhir': int.parse(_halamanAkhirController.text),
        'jumlah_kesalahan': int.parse(_kesalahanController.text),
        'status': _selectedStatus.toLowerCase(),
        'input_oleh': myId,
      });

      if (!mounted) return;

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
    final historySetoranAsync = ref.watch(setoranForSantriProvider(widget.santriId));
    
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
                      widget.santriName.isNotEmpty ? widget.santriName[0] : '?',
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _halamanAwalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Halaman Awal',
                                    prefixIcon: Icon(Icons.menu_book_rounded),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? 'Isi' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _halamanAkhirController,
                                  decoration: const InputDecoration(
                                    labelText: 'Halaman Akhir',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? 'Isi' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jumlahBarisController,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Baris',
                              prefixIcon: Icon(Icons.format_line_spacing_rounded),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _kesalahanController,
                                  decoration: const InputDecoration(
                                    labelText: 'Jumlah Kesalahan',
                                    prefixIcon: Icon(Icons.warning_rounded),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? 'Isi dengan 0 jika lancar' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                  ),
                                  items: _statuses.map((status) {
                                    return DropdownMenuItem(value: status, child: Text(status));
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedStatus = val!;
                                    });
                                  },
                                ),
                              ),
                            ],
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
                  historySetoranAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => ErrorStateWidget(message: e.toString(), onRetry: () => ref.refresh(setoranProvider)),
                    data: (historySetoran) {
                      return historySetoran.isEmpty
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
                                final type = s['tipe']?.toString().toUpperCase() ?? '';
                                Color typeColor = AppTheme.primaryColor;
                                if (type == 'SABAK') typeColor = Colors.blue;
                                if (type == 'SABKI') typeColor = Colors.orange;

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
                                    title: Text('$type - Hlm ${s['halaman_awal']} s/d ${s['halaman_akhir']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Tanggal: ${s['tanggal']}\nKesalahan: ${s['jumlah_kesalahan']} | Baris: ${s['jumlah_baris']}', style: TextStyle(color: Colors.grey.shade600)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (s['status'] == 'lulus' ? Colors.green : Colors.red).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        s['status']?.toString().toUpperCase() ?? '',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: s['status'] == 'lulus' ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(begin: 0.1);
                              },
                            );
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
