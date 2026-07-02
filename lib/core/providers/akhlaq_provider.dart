import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class AkhlaqNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AkhlaqNotifier() : super(const AsyncValue.loading()) {
    fetchAkhlaq();
  }

  Future<void> fetchAkhlaq() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase.from('akhlaq').select('*, santri(nama_lengkap)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> addAkhlaq(Map<String, dynamic> data) async {
    try {
      await supabase.from('akhlaq').upsert(data, onConflict: 'santri_id,semester,tahun_ajaran');
      await fetchAkhlaq();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final akhlaqProvider = StateNotifierProvider<AkhlaqNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AkhlaqNotifier();
});

final akhlaqForSantriProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, santriId) {
  return ref.watch(akhlaqProvider).whenData((list) {
    return list.where((a) => a['santri_id'] == santriId).map((a) {
      // Map to old JournalEntry structure to prevent UI breaking
      final Map<String, dynamic> mapped = Map<String, dynamic>.from(a);
      mapped['note'] = 'Sikap dan perkembangan baik di semester ${a['semester']}.';
      mapped['akhlaqScore'] = a['nilai'];
      mapped['date'] = DateTime.parse(a['updated_at'] ?? a['created_at'] ?? DateTime.now().toIso8601String());
      return mapped;
    }).toList();
  });
});
