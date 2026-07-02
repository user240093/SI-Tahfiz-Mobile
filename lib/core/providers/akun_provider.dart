import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class AkunNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AkunNotifier() : super(const AsyncValue.loading()) {
    fetchAkun();
  }

  Future<void> fetchAkun() async {
    state = const AsyncValue.loading();
    try {
      final profilesData = await supabase.from('profiles').select('*');
      final parentsData = await supabase.from('orang_tua').select('*');

      final List<Map<String, dynamic>> merged = [];
      
      for (var p in profilesData) {
        merged.add({
          'id': p['id'],
          'nama_lengkap': p['nama_lengkap'],
          'role': p['role'],
          'email': p['email'],
          'nomor_hp': null,
          'created_at': p['created_at'],
        });
      }

      for (var o in parentsData) {
        merged.add({
          'id': o['id'],
          'nama_lengkap': o['nama_lengkap'],
          'role': 'orang_tua',
          'email': null,
          'nomor_hp': o['nomor_hp'],
          'created_at': o['created_at'],
        });
      }

      // Sort alphabetically by nama_lengkap
      merged.sort((a, b) {
        final aName = (a['nama_lengkap'] ?? '').toString().toLowerCase();
        final bName = (b['nama_lengkap'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });

      state = AsyncValue.data(merged);
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<bool> createAkun({
    required String namaLengkap,
    required String role,
    String? email,
    String? nomorHp,
    required String password,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'create-user',
        body: {
          'nama_lengkap': namaLengkap,
          'role': role,
          if (email != null && email.isNotEmpty) 'email': email,
          if (nomorHp != null && nomorHp.isNotEmpty) 'nomor_hp': nomorHp,
          'password': password,
        },
      );

      if (response.status == 200) {
        await fetchAkun();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editAkun({
    required String userId,
    required String role,
    required String namaLengkap,
  }) async {
    try {
      final table = role == 'orang_tua' ? 'orang_tua' : 'profiles';
      await supabase.from(table).update({
        'nama_lengkap': namaLengkap,
      }).eq('id', userId);

      await fetchAkun();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'reset-password',
        body: {
          'user_id': userId,
          'new_password': newPassword,
        },
      );
      return response.status == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAkun({
    required String userId,
    required String namaUser,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'delete-user',
        body: {
          'user_id': userId,
          'nama_user': namaUser,
        },
      );
      if (response.status == 200) {
        await fetchAkun();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final akunProvider = StateNotifierProvider<AkunNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AkunNotifier();
});
