import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class GradeNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  GradeNotifier() : super(const AsyncValue.loading()) {
    fetchSantriWithGrade();
  }

  Future<void> fetchSantriWithGrade() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('santri')
          .select('id, nama_lengkap, kelas, grade, halaqah(id, nama_halaqah)')
          .order('nama_lengkap');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> updateGrade(String santriId, String gradeBaru, String gradeLama) async {
    if (gradeBaru == gradeLama) {
      return false;
    }

    try {
      // Optimistic update
      if (state is AsyncData) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((s) {
          if (s['id'] == santriId) {
            return {...s, 'grade': gradeBaru};
          }
          return s;
        }).toList();
        state = AsyncValue.data(updatedList);
      }

      await supabase
          .from('santri')
          .update({'grade': gradeBaru})
          .eq('id', santriId);

      return true;
    } catch (e) {
      // Revert if error
      await fetchSantriWithGrade();
      return false;
    }
  }
}

final gradeProvider = StateNotifierProvider<GradeNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return GradeNotifier();
});
