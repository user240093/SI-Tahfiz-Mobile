import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class TtdCanvasScreen extends StatefulWidget {
  final String setoranId;

  const TtdCanvasScreen({super.key, required this.setoranId});

  @override
  State<TtdCanvasScreen> createState() => _TtdCanvasScreenState();
}

class _TtdCanvasScreenState extends State<TtdCanvasScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveSignature() async {
    if (_controller.isNotEmpty) {
      // In real app, we would export to bytes and upload to Supabase Storage
      // final Uint8List? data = await _controller.toPngBytes();
      // For mock, we just send a mock URL or string indicating signed
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.validateManzil(widget.setoranId, "MOCK_SIGNATURE_DATA_URL");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanda tangan berhasil disimpan!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Tanda tangan kosong!'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi Manzil'),
        backgroundColor: AppTheme.roleWaliColor,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Silakan tanda tangan di area bawah ini untuk memvalidasi setoran hafalan Manzil anak Anda.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _controller.clear();
                  },
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  label: const Text('Hapus', style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.roleWaliColor,
                  ),
                  onPressed: _saveSignature,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
