import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class TargetMurajaahNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  TargetMurajaahNotifier() : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> fetchTarget(String pekanId, String halaqahId) async {
    try {
      final data = await supabase
          .from('target_murajaah')
          .select('id, target_baris_per_hari')
          .eq('pekan_murajaah_id', pekanId)
          .eq('halaqah_id', halaqahId)
          .maybeSingle();
      state = AsyncValue.data(data);
      return data;
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
      rethrow;
    }
  }

  Future<void> upsertTarget(String pekanId, String halaqahId, int target) async {
    try {
      await supabase.from('target_murajaah').upsert({
        'pekan_murajaah_id': pekanId,
        'halaqah_id': halaqahId,
        'target_baris_per_hari': target,
      }, onConflict: 'pekan_murajaah_id,halaqah_id');
      
      // Refresh state
      await fetchTarget(pekanId, halaqahId);
    } catch (e) {
      rethrow;
    }
  }
}

final targetMurajaahProvider = StateNotifierProvider<TargetMurajaahNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return TargetMurajaahNotifier();
});
