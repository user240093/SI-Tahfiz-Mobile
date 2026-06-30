import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class TuSppManager extends StatefulWidget {
  const TuSppManager({super.key});

  @override
  State<TuSppManager> createState() => _TuSppManagerState();
}

class _TuSppManagerState extends State<TuSppManager> {
  String? _selectedSantriId;
  String _monthYear = '06-2026'; // Mock default
  final _amountController = TextEditingController(text: '250000');

  void _submit() {
    if (_selectedSantriId != null && _amountController.text.isNotEmpty) {
      Provider.of<AppProvider>(context, listen: false).addSppPayment(
        _selectedSantriId!,
        _monthYear,
        double.parse(_amountController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran SPP berhasil dicatat.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final santriList = provider.allSantri;
    final sppList = provider.allSpp;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Input Pembayaran SPP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Pilih Santri'),
                      value: _selectedSantriId,
                      items: santriList.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.kelas})'))).toList(),
                      onChanged: (val) => setState(() => _selectedSantriId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Bulan - Tahun'),
                      value: _monthYear,
                      items: ['05-2026', '06-2026', '07-2026'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _monthYear = val!),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nominal Pembayaran (Rp)', prefixText: 'Rp '),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roleTuColor),
                      onPressed: _submit,
                      child: const Text('Catat Pembayaran'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (MediaQuery.of(context).size.width > 800)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Histori Transaksi SPP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sppList.length,
                      itemBuilder: (context, index) {
                        final spp = sppList[index];
                        final santri = provider.getSantriById(spp.santriId);
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: const Icon(Icons.check, color: Colors.green)),
                            title: Text('${santri?.name ?? 'Unknown'} - Bulan ${spp.monthYear}'),
                            subtitle: Text('Rp ${spp.amount} | Tgl: ${spp.paidDate.day}/${spp.paidDate.month}/${spp.paidDate.year}'),
                            trailing: Text('Ref: ${spp.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
