import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class OrtuState {
  final List<Map<String, dynamic>> anakList;
  final String? selectedAnakId;

  OrtuState({
    this.anakList = const [],
    this.selectedAnakId,
  });

  OrtuState copyWith({
    List<Map<String, dynamic>>? anakList,
    String? selectedAnakId,
  }) {
    return OrtuState(
      anakList: anakList ?? this.anakList,
      selectedAnakId: selectedAnakId ?? this.selectedAnakId,
    );
  }
}

class OrtuNotifier extends StateNotifier<OrtuState> {
  OrtuNotifier() : super(OrtuState());

  List<Map<String, dynamic>> anakList = [];
  String? selectedAnakId;
  Map<String, dynamic>? selectedAnak;

  Future<void> loadAnakList(String ortuId) async {
    try {
      final data = await supabase
          .from('santri')
          .select('id, nama_lengkap, kelas, grade, halaqah(nama_halaqah, pengampu_id, profiles:pengampu_id(nama_lengkap))')
          .eq('orang_tua_id', ortuId)
          .order('nama_lengkap');

      anakList = List<Map<String, dynamic>>.from(data);

      // Auto-select first anak if none selected
      if (selectedAnakId == null && anakList.isNotEmpty) {
        selectedAnakId = anakList[0]['id'];
        selectedAnak = anakList[0];
      } else if (selectedAnakId != null) {
        final exists = anakList.any((a) => a['id'] == selectedAnakId);
        if (!exists && anakList.isNotEmpty) {
          selectedAnakId = anakList[0]['id'];
          selectedAnak = anakList[0];
        } else if (exists) {
          selectedAnak = anakList.firstWhere((a) => a['id'] == selectedAnakId);
        }
      }

      state = state.copyWith(anakList: anakList, selectedAnakId: selectedAnakId);
    } catch (e) {
      // Silence or handle load failure
      state = state.copyWith(anakList: [], selectedAnakId: null);
    }
  }

  void switchAnak(String anakId) {
    if (anakList.isNotEmpty) {
      selectedAnakId = anakId;
      selectedAnak = anakList.firstWhere((a) => a['id'] == anakId, orElse: () => anakList[0]);
      state = state.copyWith(selectedAnakId: anakId);
    }
  }
}

final ortuProvider = StateNotifierProvider<OrtuNotifier, OrtuState>((ref) {
  return OrtuNotifier();
});
