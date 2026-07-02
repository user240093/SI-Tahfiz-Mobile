import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class SyahrulQuranState {
  final Map<String, dynamic>? aktivPeriode;
  final List<Map<String, dynamic>> riwayat;

  SyahrulQuranState({
    this.aktivPeriode,
    required this.riwayat,
  });
}

class SyahrulQuranNotifier extends StateNotifier<AsyncValue<SyahrulQuranState>> {
  SyahrulQuranNotifier() : super(const AsyncValue.loading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Check if there is an active period today
      final aktivPeriode = await supabase
          .from('syahrul_quran')
          .select('*')
          .lte('tanggal_mulai', today)
          .gte('tanggal_selesai', today)
          .maybeSingle();

      // Load all periods for history
      final riwayat = await supabase
          .from('syahrul_quran')
          .select('*, profiles!dibuat_oleh(nama_lengkap)')
          .order('tanggal_mulai', ascending: false);
      
      state = AsyncValue.data(SyahrulQuranState(
        aktivPeriode: aktivPeriode,
        riwayat: List<Map<String, dynamic>>.from(riwayat),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> tetapkanPeriode(String mulai, String selesai, String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Recheck if there is an active period today to prevent race condition
    final recheck = await supabase
        .from('syahrul_quran')
        .select('id')
        .lte('tanggal_mulai', today)
        .gte('tanggal_selesai', today)
        .maybeSingle();
        
    if (recheck != null) {
      throw Exception("Sudah ada periode Syahrul Quran yang aktif, akhiri periode ini terlebih dahulu");
    }

    await supabase.from('syahrul_quran').insert({
      'tanggal_mulai': mulai,
      'tanggal_selesai': selesai,
      'dibuat_oleh': userId,
    });

    await fetchAll();
  }

  Future<void> akhiriPeriode(String periodeId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await supabase.from('syahrul_quran')
        .update({'tanggal_selesai': today})
        .eq('id', periodeId);

    await fetchAll();
  }

  Future<bool> checkAktif() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final syahrul = await supabase
          .from('syahrul_quran')
          .select('id')
          .lte('tanggal_mulai', today)
          .gte('tanggal_selesai', today)
          .maybeSingle();
      return syahrul != null;
    } catch (_) {
      return false;
    }
  }
}

final syahrulQuranProvider = StateNotifierProvider<SyahrulQuranNotifier, AsyncValue<SyahrulQuranState>>((ref) {
  return SyahrulQuranNotifier();
});
