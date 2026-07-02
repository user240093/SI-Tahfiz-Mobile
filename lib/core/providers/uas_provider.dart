import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';
import 'akhlaq_provider.dart';
import 'setoran_provider.dart';
import 'absensi_provider.dart';

class UasNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  UasNotifier() : super(const AsyncValue.loading()) {
    fetchUas();
  }

  Future<void> fetchUas() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase.from('uas').select('*, uas_detail(*), santri(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addUas(Map<String, dynamic> uasData, List<Map<String, dynamic>> details) async {
    try {
      final res = await supabase.from('uas').upsert(uasData).select('id').single();
      final uasId = res['id'];
      
      final detailsWithId = details.map((d) {
        final newMap = Map<String, dynamic>.from(d);
        newMap['uas_id'] = uasId;
        return newMap;
      }).toList();

      if (detailsWithId.isNotEmpty) {
        await supabase.from('uas_detail').upsert(detailsWithId);
      }
      await fetchUas();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final uasProvider = StateNotifierProvider<UasNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return UasNotifier();
});

final nilaiForSantriProvider = Provider.family<AsyncValue<Map<String, dynamic>?>, String>((ref, santriId) {
  final uasAsync = ref.watch(uasProvider);
  final akhlaqAsync = ref.watch(akhlaqProvider);
  final setoranAsync = ref.watch(setoranProvider);
  final absensiAsync = ref.watch(absensiProvider);

  if (uasAsync is AsyncData && akhlaqAsync is AsyncData && setoranAsync is AsyncData && absensiAsync is AsyncData) {
    final uasList = uasAsync.value ?? [];
    final akhlaqList = akhlaqAsync.value ?? [];
    final setoranList = setoranAsync.value ?? [];
    final absensiList = absensiAsync.value ?? [];

    final uas = uasList.firstWhere((u) => u['santri_id'] == santriId, orElse: () => {});
    final double uasScore = uas.isNotEmpty ? (double.tryParse(uas['nilai_akhir']?.toString() ?? '0') ?? 0.0) : 0.0;

    final akhlaq = akhlaqList.firstWhere((a) => a['santri_id'] == santriId, orElse: () => {});
    final double akhlaqScore = akhlaq.isNotEmpty ? (double.tryParse(akhlaq['nilai']?.toString() ?? '0') ?? 0.0) : 0.0;

    final santriSetorans = setoranList.where((s) => s['santri_id'] == santriId).toList();
    double setoranScore = 100.0;
    if (santriSetorans.isNotEmpty) {
      final lulusCount = santriSetorans.where((s) => s['status'] == 'lulus').length;
      setoranScore = (lulusCount / santriSetorans.length) * 100.0;
    }

    final santriAbsensi = absensiList.where((a) => a['santri_id'] == santriId).toList();
    double kehadiranScore = 100.0;
    if (santriAbsensi.isNotEmpty) {
      final presentCount = santriAbsensi.where((a) => a['status'] != 'alpha').length;
      kehadiranScore = (presentCount / santriAbsensi.length) * 100.0;
    }

    final double setoranPercent = setoranScore * 0.40;
    final double uasPercent = uasScore * 0.40;
    final double akhlaqPercent = akhlaqScore * 0.10;
    final double kehadiranPercent = kehadiranScore * 0.10;
    final double totalNilai = setoranPercent + uasPercent + akhlaqPercent + kehadiranPercent;

    return AsyncValue.data({
      'setoranPercent': setoranPercent,
      'uasPercent': uasPercent,
      'akhlaqPercent': akhlaqPercent,
      'kehadiranPercent': kehadiranPercent,
      'totalNilai': totalNilai,
    });
  }

  return const AsyncValue.loading();
});
