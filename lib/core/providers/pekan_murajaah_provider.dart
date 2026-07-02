import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class PekanMurajaahState {
  final Map<String, dynamic>? aktivPekan;
  final List<Map<String, dynamic>> riwayat;

  PekanMurajaahState({
    this.aktivPekan,
    required this.riwayat,
  });
}

class PekanMurajaahNotifier extends StateNotifier<AsyncValue<PekanMurajaahState>> {
  PekanMurajaahNotifier() : super(const AsyncValue.loading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Check active period
      final aktivPekan = await supabase
          .from('pekan_murajaah')
          .select('*')
          .lte('tanggal_mulai', today)
          .gte('tanggal_selesai', today)
          .maybeSingle();

      // Load all periods with profiles of creator and targets
      final riwayat = await supabase
          .from('pekan_murajaah')
          .select('*, profiles!dibuat_oleh(nama_lengkap), target_murajaah(halaqah_id, target_baris_per_hari, halaqah(nama_halaqah))')
          .order('tanggal_mulai', ascending: false);

      state = AsyncValue.data(PekanMurajaahState(
        aktivPekan: aktivPekan,
        riwayat: List<Map<String, dynamic>>.from(riwayat),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> tetapkanPeriode(String mulai, String selesai, String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Recheck active period to prevent race condition
    final recheck = await supabase
        .from('pekan_murajaah')
        .select('id')
        .lte('tanggal_mulai', today)
        .gte('tanggal_selesai', today)
        .maybeSingle();

    if (recheck != null) {
      throw Exception("Sudah ada Pekan Murajaah yang aktif, akhiri periode ini terlebih dahulu");
    }

    await supabase.from('pekan_murajaah').insert({
      'tanggal_mulai': mulai,
      'tanggal_selesai': selesai,
      'dibuat_oleh': userId,
    });

    await fetchAll();
  }

  Future<void> akhiriPeriode(String pekanId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    await supabase.from('pekan_murajaah')
        .update({'tanggal_selesai': today})
        .eq('id', pekanId);

    await fetchAll();
  }

  Future<Map<String, dynamic>?> checkAktif() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final aktivPekan = await supabase
          .from('pekan_murajaah')
          .select('id, tanggal_mulai, tanggal_selesai')
          .lte('tanggal_mulai', today)
          .gte('tanggal_selesai', today)
          .maybeSingle();
      return aktivPekan;
    } catch (_) {
      return null;
    }
  }
}

final pekanMurajaahProvider = StateNotifierProvider<PekanMurajaahNotifier, AsyncValue<PekanMurajaahState>>((ref) {
  return PekanMurajaahNotifier();
});
