import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class HalaqahNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  HalaqahNotifier() : super(const AsyncValue.loading()) {
    fetchHalaqah();
  }

  Future<void> fetchHalaqah() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('halaqah')
          .select('*, profiles(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addHalaqah(Map<String, dynamic> data) async {
    try {
      await supabase.from('halaqah').insert(data);
      await fetchHalaqah();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final halaqahProvider = StateNotifierProvider<HalaqahNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return HalaqahNotifier();
});
