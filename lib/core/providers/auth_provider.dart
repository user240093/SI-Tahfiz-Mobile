import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthState {
  final String id;
  final String name;
  final String role;
  final supabase.User? supabaseUser;
  final String? roleString;
  final supabase.Session? session;

  AuthState({
    required this.id,
    required this.name,
    required this.role,
    this.supabaseUser,
    this.roleString,
    this.session,
  });
}

class AuthNotifier extends StateNotifier<AuthState?> {
  AuthNotifier() : super(null) {
    _init();
  }

  void _init() {
    supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final user = session?.user;

      if (session == null || user == null) {
        state = null;
        return;
      }

      try {
        final client = supabase.Supabase.instance.client;
        
        // Check profiles table (internal users)
        final profileRes = await client
            .from('profiles')
            .select('nama_lengkap, role')
            .eq('id', user.id)
            .maybeSingle();

        if (profileRes != null) {
          final name = profileRes['nama_lengkap'] ?? '';
          final role = profileRes['role'] ?? '';

          String mockId = 'u1';
          String mockRole = 'Murobbi';
          if (role == 'tu') {
            mockId = 'u4';
            mockRole = 'TU';
          } else if (role == 'koordinator') {
            mockId = 'u3';
            mockRole = 'Koordinator';
          } else if (role == 'pengampu') {
            mockId = 'u1';
            mockRole = 'Murobbi';
          } else if (role == 'kepsek') {
            mockId = 'u5';
            mockRole = 'Kepala Sekolah';
          }

          state = AuthState(
            id: mockId,
            name: name,
            role: mockRole,
            supabaseUser: user,
            roleString: role,
            session: session,
          );
          return;
        }

        // Check orang_tua table (parents)
        final parentRes = await client
            .from('orang_tua')
            .select('nama_lengkap')
            .eq('id', user.id)
            .maybeSingle();

        if (parentRes != null) {
          final name = parentRes['nama_lengkap'] ?? '';
          state = AuthState(
            id: 'u2',
            name: name,
            role: 'Wali',
            supabaseUser: user,
            roleString: 'orang_tua',
            session: session,
          );
          return;
        }

        // Fallback for authenticated users who are not fully initialized in DB
        state = AuthState(
          id: 'u2',
          name: user.email ?? 'Orang Tua',
          role: 'Wali',
          supabaseUser: user,
          roleString: 'orang_tua',
          session: session,
        );
      } catch (e) {
        state = AuthState(
          id: 'u2',
          name: user.email ?? 'Orang Tua',
          role: 'Wali',
          supabaseUser: user,
          roleString: 'orang_tua',
          session: session,
        );
      }
    });
  }

  Future<void> signOut() async {
    await supabase.Supabase.instance.client.auth.signOut();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>((ref) {
  return AuthNotifier();
});

final logoutTargetProvider = StateProvider<String>((ref) => '/login');
