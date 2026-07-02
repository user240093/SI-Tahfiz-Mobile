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

  Future<List<Map<String, dynamic>>> fetchSetoranByDate(String halaqahId, String date) async {
    try {
      // First get the list of santri IDs in this halaqah
      final santriRes = await supabase
          .from('santri')
          .select('id')
          .eq('halaqah_id', halaqahId);
      final santriIds = List<String>.from(santriRes.map((s) => s['id'] as String));
      if (santriIds.isEmpty) return [];

      final data = await supabase
          .from('setoran')
          .select('santri_id, tipe, id, jumlah_baris, halaman_awal, halaman_akhir, jumlah_kesalahan, status')
          .eq('tanggal', date)
          .inFilter('santri_id', santriIds);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetchSetoranByDate: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchManzilByAnak(String anakId) async {
    try {
      final data = await supabase
          .from('setoran')
          .select('*')
          .eq('santri_id', anakId)
          .eq('tipe', 'manzil')
          .order('tanggal', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetchManzilByAnak: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> insertSetoran(Map<String, dynamic> data) async {
    try {
      final santriId = data['santri_id'] as String;
      final tipe = data['tipe'] as String;
      final tanggal = data['tanggal'] as String;
      final jumlahBaris = data['jumlah_baris'] as int;
      final halamanAwal = data['halaman_awal'] as int;
      final halamanAkhir = data['halaman_akhir'] as int;
      final jumlahKesalahan = data['jumlah_kesalahan'] as int;
      final inputOleh = data['input_oleh'] as String;

      // Calculate status
      final totalHalaman = halamanAkhir - halamanAwal + 1;
      final batasKesalahan = totalHalaman * 2;
      final status = jumlahKesalahan > batasKesalahan ? 'mengulang' : 'lulus';

      // Check duplicate (only for new setoran, not edit)
      final existing = await supabase
          .from('setoran')
          .select('id')
          .eq('santri_id', santriId)
          .eq('tipe', tipe)
          .eq('tanggal', tanggal)
          .maybeSingle();
      if (existing != null) {
        return {
          'success': false,
          'error': 'duplicate',
        };
      }

      // Insert Setoran
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

      bool tikrarFailed = false;
      if (status == 'mengulang') {
        try {
          await supabase.from('tikrar').insert({
            'santri_id': santriId,
            'tanggal': tanggal,
            'surah': 'Hal. $halamanAwal-$halamanAkhir',
            'status': 'wajib_sekolah',
          });
        } catch (tikrarError) {
          debugPrint('Failed to auto-create Tikrar: $tikrarError');
          tikrarFailed = true;
        }
      }

      await fetchSetoran();
      return {
        'success': true,
        'tikrarFailed': tikrarFailed,
      };
    } catch (e) {
      debugPrint('Error inserting setoran: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateSetoran({
    required String id,
    required int jumlahBaris,
    required int halamanAwal,
    required int halamanAkhir,
    required int jumlahKesalahan,
    required String status,
  }) async {
    try {
      await supabase.from('setoran').update({
        'jumlah_baris': jumlahBaris,
        'halaman_awal': halamanAwal,
        'halaman_akhir': halamanAkhir,
        'jumlah_kesalahan': jumlahKesalahan,
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      await fetchSetoran();
      return {
        'success': true,
      };
    } catch (e) {
      debugPrint('Error updating setoran: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> upsertManzil({
    required String santriId,
    required String tanggal,
    required int jumlahBaris,
    required int halamanAwal,
    required int halamanAkhir,
    required String inputOleh,
  }) async {
    try {
      await supabase.from('setoran').upsert({
        'santri_id': santriId,
        'tipe': 'manzil',
        'tanggal': tanggal,
        'jumlah_baris': jumlahBaris,
        'halaman_awal': halamanAwal,
        'halaman_akhir': halamanAkhir,
        'jumlah_kesalahan': 0, // Manzil does not have kesalahan concept
        'status': 'lulus', // Manzil is always lulus
        'input_oleh': inputOleh,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'santri_id,tipe,tanggal');
      await fetchSetoran();
      return {
        'success': true,
      };
    } catch (e) {
      debugPrint('Error upserting manzil: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
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
