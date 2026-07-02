import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class PengumumanNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  PengumumanNotifier() : super(const AsyncValue.loading()) {
    fetchAllPengumuman();
  }

  Future<void> fetchAllPengumuman() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('pengumuman')
          .select('*, profiles(nama_lengkap)')
          .order('created_at', ascending: false);
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> insertPengumuman(String judul, String isi, List<String> targetRole) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) throw Exception('Not authenticated');

      await supabase.from('pengumuman').insert({
        'judul': judul,
        'isi': isi,
        'target_role': targetRole,
        'dibuat_oleh': myId,
      });
      await fetchAllPengumuman();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePengumuman(String id) async {
    try {
      await supabase.from('pengumuman').delete().eq('id', id);
      await fetchAllPengumuman();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String pengumumanId) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      await supabase.from('pengumuman_read').upsert({
        'pengumuman_id': pengumumanId,
        'user_id': myId,
      }, onConflict: 'pengumuman_id,user_id');
    } catch (e) {
      // Ignore or handle
    }
  }
}

final pengumumanProvider = StateNotifierProvider<PengumumanNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return PengumumanNotifier();
});

final sortedAnnouncementsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(pengumumanProvider).whenData((list) {
    final sorted = List<Map<String, dynamic>>.from(list);
    sorted.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
    return sorted;
  });
});

