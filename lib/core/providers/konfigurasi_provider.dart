import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class KonfigurasiState {
  final Map<String, dynamic>? konfigurasi;
  final List<Map<String, dynamic>> hariLibur;

  KonfigurasiState({
    required this.konfigurasi,
    required this.hariLibur,
  });
}

class KonfigurasiNotifier extends StateNotifier<AsyncValue<KonfigurasiState>> {
  KonfigurasiNotifier() : super(const AsyncValue.loading()) {
    fetchKonfigurasi();
  }

  Future<void> fetchKonfigurasi() async {
    try {
      final config = await supabase.from('konfigurasi').select().maybeSingle();
      final holidays = await supabase.from('hari_libur').select().order('tanggal', ascending: true);
      state = AsyncValue.data(KonfigurasiState(
        konfigurasi: config,
        hariLibur: List<Map<String, dynamic>>.from(holidays),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> updateTanggalSemester(Map<String, dynamic> data) async {
    final current = state.value?.konfigurasi;
    if (current == null) throw Exception('Konfigurasi tidak ditemukan');
    await supabase.from('konfigurasi').update(data).eq('id', current['id']);
    await fetchKonfigurasi();
  }

  Future<void> updateBobotNilai(Map<String, dynamic> data) async {
    final current = state.value?.konfigurasi;
    if (current == null) throw Exception('Konfigurasi tidak ditemukan');
    await supabase.from('konfigurasi').update(data).eq('id', current['id']);
    await fetchKonfigurasi();
  }

  Future<void> updateMaintenanceMode(bool value) async {
    final current = state.value?.konfigurasi;
    if (current == null) throw Exception('Konfigurasi tidak ditemukan');
    await supabase.from('konfigurasi').update({
      'maintenance_mode': value,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', current['id']);
    await fetchKonfigurasi();
  }

  Future<void> updateFiturAkhlaq(bool value) async {
    final current = state.value?.konfigurasi;
    if (current == null) throw Exception('Konfigurasi tidak ditemukan');
    await supabase.from('konfigurasi').update({
      'fitur_akhlaq_aktif': value,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', current['id']);
    await fetchKonfigurasi();
  }

  Future<void> addHariLibur(String tanggal, String keterangan) async {
    await supabase.from('hari_libur').insert({
      'tanggal': tanggal,
      'keterangan': keterangan,
    });
    await fetchKonfigurasi();
  }

  Future<void> deleteHariLibur(String id) async {
    await supabase.from('hari_libur').delete().eq('id', id);
    await fetchKonfigurasi();
  }
}

final konfigurasiProvider = StateNotifierProvider<KonfigurasiNotifier, AsyncValue<KonfigurasiState>>((ref) {
  return KonfigurasiNotifier();
});

final semesterTahunAjaranProvider = Provider<Map<String, String>>((ref) {
  final configState = ref.watch(konfigurasiProvider);
  return configState.maybeWhen(
    data: (state) {
      final config = state.konfigurasi;
      if (config == null) return {'semester': 'ganjil', 'tahun_ajaran': '2025/2026'};
      
      final now = DateTime.now();
      final dateStr = now.toIso8601String().substring(0, 10);
      
      final ganjilMulai = config['tanggal_mulai_ganjil'] as String?;
      final ganjilSelesai = config['tanggal_selesai_ganjil'] as String?;
      final genapMulai = config['tanggal_mulai_genap'] as String?;
      final genapSelesai = config['tanggal_selesai_genap'] as String?;

      if (ganjilMulai != null && ganjilSelesai != null) {
        if (dateStr.compareTo(ganjilMulai) >= 0 && dateStr.compareTo(ganjilSelesai) <= 0) {
          final year = DateTime.parse(ganjilMulai).year;
          return {'semester': 'ganjil', 'tahun_ajaran': '$year/${year + 1}'};
        }
      }

      if (genapMulai != null && genapSelesai != null) {
        if (dateStr.compareTo(genapMulai) >= 0 && dateStr.compareTo(genapSelesai) <= 0) {
          final year = DateTime.parse(genapMulai).year - 1;
          return {'semester': 'genap', 'tahun_ajaran': '$year/${year + 1}'};
        }
      }

      // Fallback
      if (ganjilMulai != null) {
        final gMulaiDate = DateTime.parse(ganjilMulai);
        if (now.isBefore(gMulaiDate)) {
          return {'semester': 'genap', 'tahun_ajaran': '${gMulaiDate.year - 1}/${gMulaiDate.year}'};
        } else {
          return {'semester': 'ganjil', 'tahun_ajaran': '${gMulaiDate.year}/${gMulaiDate.year + 1}'};
        }
      }
      return {'semester': 'ganjil', 'tahun_ajaran': '2025/2026'};
    },
    orElse: () => {'semester': 'ganjil', 'tahun_ajaran': '2025/2026'},
  );
});
