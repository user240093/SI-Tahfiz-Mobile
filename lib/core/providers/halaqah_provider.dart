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
          .select('*, profiles(nama_lengkap), santri(count)')
          .order('nama_halaqah');
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

  Future<bool> updateHalaqah(String id, Map<String, dynamic> data) async {
    try {
      await supabase.from('halaqah').update(data).eq('id', id);
      await fetchHalaqah();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteHalaqah(String id, String namaHalaqah) async {
    try {
      // Check if there are active santri in the halaqah
      final res = await supabase
          .from('santri')
          .select('id')
          .eq('halaqah_id', id);
      
      if (res.isNotEmpty) {
        return 'Halaqah tidak dapat dihapus karena masih memiliki santri aktif';
      }

      await supabase.from('halaqah').delete().eq('id', id);

      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        await supabase.from('audit_trail').insert({
          'user_id': currentUserId,
          'aktivitas': 'Hapus halaqah: $namaHalaqah',
        });
      }

      await fetchHalaqah();
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }
}

final halaqahProvider = StateNotifierProvider<HalaqahNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return HalaqahNotifier();
});
