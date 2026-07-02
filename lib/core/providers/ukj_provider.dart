import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class UkjNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  UkjNotifier() : super(const AsyncValue.loading()) {
    fetchUkj();
  }

  Future<void> fetchUkj() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase.from('ukj').select('*, santri(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<List<Map<String, dynamic>>> fetchUkjHalaqah(String halaqahId) async {
    try {
      final data = await supabase
          .from('ukj')
          .select('*, santri!inner(nama_lengkap, halaqah_id)')
          .eq('santri.halaqah_id', halaqahId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUkjPending() async {
    try {
      final data = await supabase
          .from('ukj')
          .select('*, santri(nama_lengkap, halaqah(nama_halaqah)), profiles!pengampu_id(nama_lengkap)')
          .eq('status_approval', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertUkj({
    required String santriId,
    required String pengampuId,
    required int nomorJuz,
    required int nilai,
    required String statusSantri,
  }) async {
    try {
      await supabase.from('ukj').insert({
        'santri_id': santriId,
        'pengampu_id': pengampuId,
        'nomor_juz': nomorJuz,
        'nilai': nilai,
        'status_santri': statusSantri.toLowerCase(),
        'status_approval': 'pending',
      });
      await fetchUkj();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUkjPending({
    required String ukjId,
    required int nomorJuz,
    required int nilai,
    required String statusSantri,
  }) async {
    try {
      await supabase
          .from('ukj')
          .update({
            'nomor_juz': nomorJuz,
            'nilai': nilai,
            'status_santri': statusSantri.toLowerCase(),
          })
          .eq('id', ukjId)
          .eq('status_approval', 'pending'); // GUARD
      await fetchUkj();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveUkj(String ukjId, String koordinatorId) async {
    try {
      final ukjData = await supabase
          .from('ukj')
          .select('nomor_juz, santri(nama_lengkap)')
          .eq('id', ukjId)
          .single();
      final santriNama = ukjData['santri']['nama_lengkap'] as String;
      final nomorJuz = ukjData['nomor_juz'] as int;

      await supabase
          .from('ukj')
          .update({
            'status_approval': 'approved',
            'approved_by': koordinatorId,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ukjId)
          .eq('status_approval', 'pending'); // GUARD

      await supabase.from('audit_trail').insert({
        'user_id': koordinatorId,
        'aktivitas': 'Approve UKJ: $santriNama Juz $nomorJuz',
      });

      await fetchUkj();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectUkj(String ukjId, String alasan, String koordinatorId) async {
    try {
      final ukjData = await supabase
          .from('ukj')
          .select('nomor_juz, santri(nama_lengkap)')
          .eq('id', ukjId)
          .single();
      final santriNama = ukjData['santri']['nama_lengkap'] as String;
      final nomorJuz = ukjData['nomor_juz'] as int;

      await supabase
          .from('ukj')
          .update({
            'status_approval': 'rejected',
            'alasan_penolakan': alasan,
            'approved_by': koordinatorId,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ukjId)
          .eq('status_approval', 'pending'); // GUARD

      await supabase.from('audit_trail').insert({
        'user_id': koordinatorId,
        'aktivitas': 'Reject UKJ: $santriNama Juz $nomorJuz',
      });

      await fetchUkj();
    } catch (e) {
      rethrow;
    }
  }

  // Backward compatibility method
  Future<void> updateUkjStatus(String ukjId, String newStatus) async {
    try {
      await supabase
          .from('ukj')
          .update({'status_approval': newStatus.toLowerCase()})
          .eq('id', ukjId);
      await fetchUkj();
    } catch (e) {
      rethrow;
    }
  }
}

final ukjProvider = StateNotifierProvider<UkjNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return UkjNotifier();
});
