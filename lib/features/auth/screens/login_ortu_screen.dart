import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme.dart';

class LoginOrtuScreen extends ConsumerStatefulWidget {
  const LoginOrtuScreen({super.key});

  @override
  ConsumerState<LoginOrtuScreen> createState() => _LoginOrtuScreenState();
}

class _LoginOrtuScreenState extends ConsumerState<LoginOrtuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nomorHP = _phoneController.text.trim();
      final fakeEmail = '$nomorHP@ortu.sitahfiz';
      final supabase = Supabase.instance.client;

      // Perform sign in
      final authResponse = await supabase.auth.signInWithPassword(
        email: fakeEmail,
        password: _passwordController.text,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('User not found after sign in.');
      }

      // Query connected santri (not used for routing, but verified per spec)
      await supabase
          .from('santri')
          .select('id, nama_lengkap')
          .eq('orang_tua_id', user.id);

      // Fetch maintenance mode configuration
      final configResponse = await supabase
          .from('konfigurasi')
          .select('maintenance_mode')
          .limit(1)
          .maybeSingle();

      final isMaintenance = configResponse?['maintenance_mode'] == true;

      if (!mounted) return;

      if (isMaintenance) {
        Navigator.pushReplacementNamed(context, '/maintenance');
      } else {
        Navigator.pushReplacementNamed(context, '/ortu/beranda');
      }
    } on AuthException catch (_) {
      setState(() {
        _errorMessage = 'Nomor HP atau password salah';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      body: Row(
        children: [
          // Left side brand pane for desktop
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.roleWaliColor.withOpacity(0.8), AppTheme.roleWaliColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.family_restroom_rounded, size: 48, color: Colors.white),
                            const SizedBox(width: 16),
                            Text(
                              'SI-Tahfiz',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                        const SizedBox(height: 64),
                        Text(
                          'Portal Orang Tua & Wali',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Pantau perkembangan hafalan Al-Qur\'an Ananda secara berkala dan real-time.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Right side login pane
          Expanded(
            flex: 7,
            child: Container(
              color: AppTheme.backgroundColor,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isDesktop) ...[
                            Icon(Icons.family_restroom_rounded, size: 64, color: AppTheme.roleWaliColor)
                                .animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Masuk Wali Santri',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.textDark,
                                  fontSize: 28,
                                ),
                          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                          const SizedBox(height: 8),
                          Text(
                            'Gunakan nomor HP yang terdaftar untuk masuk',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                          const SizedBox(height: 32),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Nomor HP',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                    hintText: 'Contoh: 08123456789',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Field ini wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline_rounded),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Field ini wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ).animate().shake(),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.roleWaliColor,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Masuk'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Switch login mode
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Masuk sebagai Staf/Internal'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
