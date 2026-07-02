import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class RouteGuard extends ConsumerStatefulWidget {
  final Widget child;
  const RouteGuard({super.key, required this.child});

  @override
  ConsumerState<RouteGuard> createState() => _RouteGuardState();
}

class _RouteGuardState extends ConsumerState<RouteGuard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndMaintenance();
  }

  Future<void> _checkAuthAndMaintenance() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session == null) {
        _redirectToLogin();
        return;
      }

      // Check maintenance mode in DB
      final configRes = await supabase
          .from('konfigurasi')
          .select('maintenance_mode')
          .limit(1)
          .maybeSingle();

      final isMaintenance = configRes?['maintenance_mode'] == true;

      // Get user role. First check Riverpod, then DB if not present
      final authState = ref.read(authProvider);
      String? role = authState?.roleString;

      if (role == null) {
        // Fetch from profiles
        final profileRes = await supabase
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        role = profileRes?['role']?.toString();

        if (role == null) {
          // Check if parent (orang_tua)
          final parentRes = await supabase
              .from('orang_tua')
              .select('id')
              .eq('id', session.user.id)
              .maybeSingle();
          if (parentRes != null) {
            role = 'orang_tua';
          }
        }
      }

      if (isMaintenance && role != 'tu') {
        _redirectToMaintenance();
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  void _redirectToMaintenance() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/maintenance');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return widget.child;
  }
}
