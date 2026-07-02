import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class AbsensiNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AbsensiNotifier() : super(const AsyncValue.loading()) {
    fetchAbsensi();
  }

  Future<void> fetchAbsensi() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase.from('absensi').select('*, santri(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> markAbsensi(Map<String, dynamic> data) async {
    try {
      await supabase.from('absensi').upsert(data);
      await fetchAbsensi();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final absensiProvider = StateNotifierProvider<AbsensiNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AbsensiNotifier();
});

final absensiForSantriProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, santriId) {
  return ref.watch(absensiProvider).whenData((list) {
    return list.where((a) => a['santri_id'] == santriId).toList();
  });
});
