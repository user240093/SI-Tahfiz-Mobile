import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class SantriNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  SantriNotifier() : super(const AsyncValue.loading()) {
    fetchSantri();
  }

  Future<void> fetchSantri() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('santri')
          .select('*, halaqah(nama_halaqah, pengampu_id), orang_tua(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addSantri(Map<String, dynamic> data) async {
    try {
      await supabase.from('santri').insert(data);
      await fetchSantri();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final santriProvider = StateNotifierProvider<SantriNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return SantriNotifier();
});

final santriForMurobbiProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, murobbiId) {
  return ref.watch(santriProvider).whenData((list) {
    return list.where((s) => s['halaqah']?['pengampu_id'] == murobbiId).toList();
  });
});

final santriForWaliProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, waliId) {
  return ref.watch(santriProvider).whenData((list) {
    return list.where((s) => s['orang_tua_id'] == waliId).toList();
  });
});

final santriByIdProvider = Provider.family<AsyncValue<Map<String, dynamic>?>, String>((ref, id) {
  return ref.watch(santriProvider).whenData((list) {
    try {
      return list.firstWhere((s) => s['id'] == id);
    } catch (_) {
      return null;
    }
  });
});
