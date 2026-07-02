import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_client.dart';
import 'auth_provider.dart';

class ProfilNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Ref _ref;

  ProfilNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    state = const AsyncValue.loading();
    try {
      final userState = _ref.read(authProvider);
      if (userState == null) {
        throw Exception('User not logged in');
      }

      final uid = userState.supabaseUser?.id ?? userState.id;
      final role = userState.roleString ?? 'orang_tua';

      final Map<String, dynamic> data;
      if (role == 'orang_tua') {
        data = await supabase
            .from('orang_tua')
            .select('nama_lengkap, nomor_hp')
            .eq('id', uid)
            .single();
      } else {
        data = await supabase
            .from('profiles')
            .select('nama_lengkap, email, role')
            .eq('id', uid)
            .single();
      }

      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> updateNama(String namaBaru) async {
    try {
      final userState = _ref.read(authProvider);
      if (userState == null) throw Exception('User not logged in');

      final uid = userState.supabaseUser?.id ?? userState.id;
      final role = userState.roleString ?? 'orang_tua';

      if (role == 'orang_tua') {
        await supabase
            .from('orang_tua')
            .update({'nama_lengkap': namaBaru})
            .eq('id', uid);
      } else {
        await supabase
            .from('profiles')
            .update({'nama_lengkap': namaBaru})
            .eq('id', uid);
      }

      await fetchProfil();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> gantiPassword(String passwordLama, String passwordBaru) async {
    try {
      final userState = _ref.read(authProvider);
      if (userState == null) throw Exception('User not logged in');

      final role = userState.roleString ?? 'orang_tua';

      final userData = state.value;
      if (userData == null) throw Exception('Profile data not loaded');

      final email = role == 'orang_tua'
          ? '${userData['nomor_hp']}@ortu.sitahfiz'
          : userData['email'];

      if (email == null) throw Exception('Email or phone not found for this profile');

      // Step 1: verify old password by re-authenticating
      try {
        final verifyResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: passwordLama,
        );

        if (verifyResponse.session == null) {
          throw Exception('Password lama tidak sesuai');
        }
      } on AuthException catch (_) {
        throw Exception('Password lama tidak sesuai');
      }

      // Step 2: update password
      await supabase.auth.updateUser(
        UserAttributes(password: passwordBaru),
      );
    } catch (e) {
      rethrow;
    }
  }
}

final profilProvider = StateNotifierProvider<ProfilNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return ProfilNotifier(ref);
});
