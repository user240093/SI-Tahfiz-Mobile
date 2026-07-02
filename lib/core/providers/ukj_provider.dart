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

  Future<bool> addUkj(Map<String, dynamic> data) async {
    try {
      await supabase.from('ukj').insert(data);
      await fetchUkj();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateUkjStatus(String ukjId, String newStatus) async {
    try {
      // Postgres enum values are lowercase 'pending', 'approved', 'rejected'
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
