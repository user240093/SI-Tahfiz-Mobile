import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

// ==========================================
// PENGAMPU TIKRAR NOTIFIER & PROVIDER
// ==========================================

class TikrarPengampuNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  TikrarPengampuNotifier() : super(const AsyncValue.loading());

  Future<void> fetchTikrarHalaqah(String halaqahId) async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('tikrar')
          .select('*, santri!inner(nama_lengkap, halaqah_id)')
          .eq('santri.halaqah_id', halaqahId)
          .neq('status', 'selesai_rumah')
          .order('created_at', ascending: false);
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  // Pengampu: wajib_sekolah → selesai_sekolah
  Future<bool> tandaiSelesaiSekolah(String tikrarId, String halaqahId) async {
    try {
      final result = await supabase
          .from('tikrar')
          .update({
            'status': 'selesai_sekolah',
            'diselesaikan_pengampu_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tikrarId)
          .eq('status', 'wajib_sekolah') // GUARD — mandatory
          .select();

      await fetchTikrarHalaqah(halaqahId);
      return result.isNotEmpty;
    } catch (e) {
      await fetchTikrarHalaqah(halaqahId);
      return false;
    }
  }

  // Pengampu: selesai_sekolah → wajib_rumah
  Future<bool> alihkanKeRumah(String tikrarId, String halaqahId) async {
    try {
      final result = await supabase
          .from('tikrar')
          .update({
            'status': 'wajib_rumah',
            'dialihkan_rumah_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tikrarId)
          .eq('status', 'selesai_sekolah') // GUARD — mandatory
          .select();

      await fetchTikrarHalaqah(halaqahId);
      return result.isNotEmpty;
    } catch (e) {
      await fetchTikrarHalaqah(halaqahId);
      return false;
    }
  }
}

final tikrarPengampuProvider = StateNotifierProvider<TikrarPengampuNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TikrarPengampuNotifier();
});

// ==========================================
// ORANG TUA TIKRAR NOTIFIER & PROVIDER
// ==========================================

class TikrarOrtuNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  TikrarOrtuNotifier() : super(const AsyncValue.loading());

  Future<void> fetchTikrarWajibRumah(String ortuId) async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('tikrar')
          .select('*, santri!inner(nama_lengkap, orang_tua_id)')
          .eq('santri.orang_tua_id', ortuId)
          .eq('status', 'wajib_rumah')
          .order('tanggal', ascending: false);
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  // Orang Tua: wajib_rumah → selesai_rumah
  Future<List<Map<String, dynamic>>> tandaiSelesaiRumah(String tikrarId, String ortuId) async {
    try {
      final result = await supabase
          .from('tikrar')
          .update({
            'status': 'selesai_rumah',
            'diselesaikan_ortu_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tikrarId)
          .eq('status', 'wajib_rumah') // GUARD — mandatory
          .select();

      await fetchTikrarWajibRumah(ortuId);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      await fetchTikrarWajibRumah(ortuId);
      return [];
    }
  }
}

final tikrarOrtuProvider = StateNotifierProvider<TikrarOrtuNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TikrarOrtuNotifier();
});

// ==========================================
// MANZIL STATUS NOTIFIER & PROVIDER (READ-ONLY)
// ==========================================

class ManzilStatusNotifier extends StateNotifier<AsyncValue<Map<String, Map<String, dynamic>>>> {
  ManzilStatusNotifier() : super(const AsyncValue.loading());

  Future<void> fetchManzilStatus(String halaqahId, String date) async {
    state = const AsyncValue.loading();
    try {
      // Step 1: Get all santri belonging to this halaqah
      final santriList = await supabase
          .from('santri')
          .select('id, nama_lengkap')
          .eq('halaqah_id', halaqahId)
          .order('nama_lengkap');

      final santriIds = List<String>.from(santriList.map((s) => s['id'] as String));

      if (santriIds.isEmpty) {
        state = const AsyncValue.data({});
        return;
      }

      // Step 2: Get manzil records for selected date
      final manzilData = await supabase
          .from('setoran')
          .select('santri_id, jumlah_baris, halaman_awal, halaman_akhir')
          .eq('tipe', 'manzil')
          .eq('tanggal', date)
          .inFilter('santri_id', santriIds);

      // Step 3: Build a map for quick lookup: santriId -> { 'nama_lengkap': name, 'setoran': record_or_null }
      final Map<String, Map<String, dynamic>> manzilMap = {};
      for (var santri in santriList) {
        final sId = santri['id'] as String;
        final name = santri['nama_lengkap'] as String;

        // Find matching setoran record
        final matches = manzilData.where((m) => m['santri_id'] == sId);
        final record = matches.isNotEmpty ? matches.first : null;

        manzilMap[sId] = {
          'nama_lengkap': name,
          'setoran': record != null ? Map<String, dynamic>.from(record) : null,
        };
      }

      state = AsyncValue.data(manzilMap);
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }
}

final manzilStatusProvider = StateNotifierProvider<ManzilStatusNotifier, AsyncValue<Map<String, Map<String, dynamic>>>>((ref) {
  return ManzilStatusNotifier();
});

// ==========================================
// GENERAL TIKRAR NOTIFIER & PROVIDER (KOORDINATOR/GENERIC VIEW)
// ==========================================

class TikrarNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  TikrarNotifier() : super(const AsyncValue.loading()) {
    fetchTikrar();
  }

  Future<void> fetchTikrar() async {
    try {
      final data = await supabase.from('tikrar').select('*, santri(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addTikrar(Map<String, dynamic> data) async {
    try {
      await supabase.from('tikrar').insert(data);
      await fetchTikrar();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTikrar(String id, Map<String, dynamic> data) async {
    try {
      await supabase.from('tikrar').update(data).eq('id', id);
      await fetchTikrar();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final tikrarProvider = StateNotifierProvider<TikrarNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TikrarNotifier();
});
