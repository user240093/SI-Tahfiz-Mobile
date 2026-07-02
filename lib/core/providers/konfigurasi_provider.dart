import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class KonfigurasiNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  KonfigurasiNotifier() : super(const AsyncValue.loading()) {
    fetchKonfigurasi();
  }

  Future<void> fetchKonfigurasi() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase.from('konfigurasi').select().maybeSingle();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> updateKonfigurasi(Map<String, dynamic> data) async {
    try {
      final current = state.value;
      if (current != null && current['id'] != null) {
        await supabase.from('konfigurasi').update(data).eq('id', current['id']);
      } else {
        await supabase.from('konfigurasi').insert(data);
      }
      await fetchKonfigurasi();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final konfigurasiProvider = StateNotifierProvider<KonfigurasiNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return KonfigurasiNotifier();
});
