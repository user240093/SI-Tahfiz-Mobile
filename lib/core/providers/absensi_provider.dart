import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

// State: Map<String, String> absensiMap (santriId -> status, only for absent santri)
class AbsensiNotifier extends StateNotifier<Map<String, String>> {
  AbsensiNotifier() : super({});

  Future<void> fetchAbsensiByDate(String halaqahId, String date) async {
    try {
      final santriData = await supabase
          .from('santri')
          .select('id')
          .eq('halaqah_id', halaqahId);

      final santriIds = (santriData as List).map((s) => s['id'] as String).toList();
      if (santriIds.isEmpty) {
        state = {};
        return;
      }

      final existingAbsensi = await supabase
          .from('absensi')
          .select('santri_id, status')
          .eq('tanggal', date)
          .inFilter('santri_id', santriIds);

      final map = <String, String>{};
      for (var item in existingAbsensi) {
        map[item['santri_id'] as String] = item['status'] as String;
      }
      state = map;
    } catch (e) {
      debugPrint('Error fetchAbsensiByDate: $e');
      rethrow;
    }
  }

  void updateLocal(String santriId, String status) {
    state = {...state, santriId: status};
  }

  void removeLocal(String santriId) {
    final map = Map<String, String>.from(state);
    map.remove(santriId);
    state = map;
  }

  Future<void> upsertAbsensi(String santriId, String status, String date) async {
    // 1. Save absensi to DB
    await supabase.from('absensi').upsert({
      'santri_id': santriId,
      'tanggal': date,
      'status': status,
    }, onConflict: 'santri_id,tanggal');

    // 2. Refresh local state immediately
    updateLocal(santriId, status);

    // 3. If status is alpha, send realtime notification to orang tua
    if (status == 'alpha') {
      try {
        final santri = await supabase
            .from('santri')
            .select('orang_tua_id, nama_lengkap')
            .eq('id', santriId)
            .single();

        final orangTuaId = santri['orang_tua_id'];
        final namaLengkap = santri['nama_lengkap'] ?? '';

        if (orangTuaId != null) {
          await supabase
              .channel('notif-ortu-$orangTuaId')
              .sendBroadcastMessage(
                event: 'alpha_notification',
                payload: {
                  'santri_nama': namaLengkap,
                  'tanggal': date,
                  'message': '$namaLengkap tidak hadir (Alpha) hari ini',
                },
              );
        }
      } catch (notifError) {
        // Notification failure is silent — absensi already saved
        // Do NOT show error to user for notification failure
        // Only log internally
        debugPrint('Alpha notification failed: $notifError');
      }
    }
  }

  Future<void> hapusAbsensi(String santriId, String date) async {
    await supabase
        .from('absensi')
        .delete()
        .eq('santri_id', santriId)
        .eq('tanggal', date);

    removeLocal(santriId);
  }
}

// Daily absensi provider for selected date
final absensiProvider = StateNotifierProvider<AbsensiNotifier, Map<String, String>>((ref) {
  return AbsensiNotifier();
});

// Backward compatibility provider: fetches all absensi records
class AllAbsensiNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AllAbsensiNotifier() : super(const AsyncValue.loading()) {
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
}

final allAbsensiProvider = StateNotifierProvider<AllAbsensiNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AllAbsensiNotifier();
});

final absensiForSantriProvider = Provider.family<AsyncValue<List<Map<String, dynamic>>>, String>((ref, santriId) {
  return ref.watch(allAbsensiProvider).whenData((list) {
    return list.where((a) => a['santri_id'] == santriId).toList();
  });
});

