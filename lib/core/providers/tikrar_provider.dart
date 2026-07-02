import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class TikrarNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  TikrarNotifier() : super(const AsyncValue.loading()) {
    fetchTikrar();
  }

  Future<void> fetchTikrar() async {
    state = const AsyncValue.loading();
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

  // Fetch all active tikrar for a halaqah (pengampu view)
  // Active means status != 'selesai_rumah'
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

  // Fetch tikrar wajib_rumah for orang tua
  Future<void> fetchTikrarAnak(String ortuId) async {
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

  // Pengampu: wajib_sekolah → selesai_sekolah
  Future<void> tandaiSelesaiSekolah(String tikrarId) async {
    await supabase
        .from('tikrar')
        .update({
          'status': 'selesai_sekolah',
          'diselesaikan_pengampu_at': DateTime.now().toIso8601String(),
        })
        .eq('id', tikrarId)
        .eq('status', 'wajib_sekolah'); // GUARD — must always be here
  }

  // Pengampu: selesai_sekolah → wajib_rumah
  Future<void> alihkanKeRumah(String tikrarId) async {
    await supabase
        .from('tikrar')
        .update({
          'status': 'wajib_rumah',
          'dialihkan_rumah_at': DateTime.now().toIso8601String(),
        })
        .eq('id', tikrarId)
        .eq('status', 'selesai_sekolah'); // GUARD
  }

  // Orang Tua: wajib_rumah → selesai_rumah
  Future<void> tandaiSelesaiRumah(String tikrarId, String currentOrtuId) async {
    final result = await supabase
        .from('tikrar')
        .update({
          'status': 'selesai_rumah',
          'diselesaikan_ortu_at': DateTime.now().toIso8601String(),
        })
        .eq('id', tikrarId)
        .eq('status', 'wajib_rumah') // GUARD
        .select();

    // If result is empty, guard was not met — refresh data
    if (result.isEmpty) {
      await fetchTikrarAnak(currentOrtuId);
    }
  }
}

final tikrarProvider = StateNotifierProvider<TikrarNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TikrarNotifier();
});
