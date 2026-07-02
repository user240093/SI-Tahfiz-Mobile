import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class SetoranNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  SetoranNotifier() : super(const AsyncValue.loading()) {
    fetchSetoran();
  }

  Future<void> fetchSetoran() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('setoran')
          .select('*, santri(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addSetoran(Map<String, dynamic> data) async {
    return insertSetoran(data);
  }

  Future<bool> insertSetoran(Map<String, dynamic> data) async {
    try {
      final santriId = data['santri_id'] as String;
      final tipe = data['tipe'] as String;
      final tanggal = data['tanggal'] as String;
      final jumlahBaris = data['jumlah_baris'] as int;
      final halamanAwal = data['halaman_awal'] as int;
      final halamanAkhir = data['halaman_akhir'] as int;
      final jumlahKesalahan = data['jumlah_kesalahan'] as int;
      final inputOleh = data['input_oleh'] as String;

      // Calculate kesalahan limit: 2 errors per page
      final totalHalaman = halamanAkhir - halamanAwal + 1;
      final batasKesalahan = totalHalaman * 2;
      final status = jumlahKesalahan > batasKesalahan ? 'mengulang' : 'lulus';

      // Save setoran with status
      await supabase.from('setoran').insert({
        'santri_id': santriId,
        'tipe': tipe,
        'tanggal': tanggal,
        'jumlah_baris': jumlahBaris,
        'halaman_awal': halamanAwal,
        'halaman_akhir': halamanAkhir,
        'jumlah_kesalahan': jumlahKesalahan,
        'status': status,
        'input_oleh': inputOleh,
      });

      // Auto-create Tikrar if status is mengulang
      if (status == 'mengulang') {
        try {
          await supabase.from('tikrar').insert({
            'santri_id': santriId,
            'tanggal': tanggal,
            'surah': 'Hal. $halamanAwal-$halamanAkhir',
            'status': 'wajib_sekolah',
          });
        } catch (e) {
          // Tikrar insert failure must NOT cancel setoran
          // Log the error but continue — show a warning to user
          debugPrint('Failed to auto-create Tikrar: $e');
        }
      }

      await fetchSetoran();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> validateByWali(String setoranId) async {
    try {
      // If there's validation column in database, but setoran table doesn't have isValidatedByWali.
    } catch (e) {
      rethrow;
    }
  }
}

final setoranProvider = StateNotifierProvider<SetoranNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return SetoranNotifier();
});

final setoranForSantriProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, santriId) {
  return ref.watch(setoranProvider).whenData((list) {
    final filtered = list.where((s) => s['santri_id'] == santriId).toList();
    // Sort by tanggal descending
    filtered.sort((a, b) => b['tanggal'].toString().compareTo(a['tanggal'].toString()));
    return filtered;
  });
});
