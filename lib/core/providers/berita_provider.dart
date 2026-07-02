import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class BeritaNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  BeritaNotifier() : super(const AsyncValue.loading()) {
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase.from('berita_login').select('*').order('created_at', ascending: false);
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addBerita(Map<String, dynamic> data) async {
    try {
      await supabase.from('berita_login').insert(data);
      await fetchBerita();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBerita(String id, Map<String, dynamic> data) async {
    try {
      await supabase.from('berita_login').update(data).eq('id', id);
      await fetchBerita();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBerita(String id) async {
    try {
      await supabase.from('berita_login').delete().eq('id', id);
      await fetchBerita();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final beritaProvider = StateNotifierProvider<BeritaNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return BeritaNotifier();
});
