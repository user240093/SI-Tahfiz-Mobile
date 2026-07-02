import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme.dart';

class LoginEmailScreen extends ConsumerStatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  ConsumerState<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends ConsumerState<LoginEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  late Future<List<Map<String, dynamic>>> _beritaFuture;

  @override
  void initState() {
    super.initState();
    _beritaFuture = _fetchBeritaLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchBeritaLogin() async {
    try {
      final response = await Supabase.instance.client
          .from('berita_login')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
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
      final supabase = Supabase.instance.client;
      
      // Perform sign in
      final authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('User not found after sign in.');
      }

      // Fetch user role
      final profileResponse = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = profileResponse['role']?.toString();

      // Fetch maintenance mode
      final configResponse = await supabase
          .from('konfigurasi')
          .select('maintenance_mode')
          .limit(1)
          .maybeSingle();

      final isMaintenance = configResponse?['maintenance_mode'] == true;

      if (!mounted) return;

      if (isMaintenance && role != 'tu') {
        Navigator.pushReplacementNamed(context, '/maintenance');
        return;
      }

      // Redirect based on role
      switch (role) {
        case 'tu':
          Navigator.pushReplacementNamed(context, '/tu/akun');
          break;
        case 'koordinator':
          Navigator.pushReplacementNamed(context, '/koordinator/beranda');
          break;
        case 'pengampu':
          Navigator.pushReplacementNamed(context, '/pengampu/beranda');
          break;
        case 'kepsek':
          Navigator.pushReplacementNamed(context, '/kepsek/dashboard');
          break;
        default:
          setState(() {
            _errorMessage = 'Role tidak dikenali oleh sistem';
          });
          await supabase.auth.signOut();
      }
    } on AuthException catch (_) {
      setState(() {
        _errorMessage = 'Email atau password salah';
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
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
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
                            const Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
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
                          'Portal Internal Madrasah',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Sistem Informasi Tahfiz & Halaqoh MTs TQ Jamilurrahman Yogyakarta.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        const SizedBox(height: 32),
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
                            Icon(Icons.menu_book_rounded, size: 64, color: AppTheme.primaryColor)
                                .animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Masuk Internal',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.textDark,
                                  fontSize: 28,
                                ),
                          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                          const SizedBox(height: 8),
                          Text(
                            'Gunakan email internal madrasah untuk masuk',
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
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
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
                              Navigator.pushReplacementNamed(context, '/login/ortu');
                            },
                            icon: const Icon(Icons.family_restroom_rounded),
                            label: const Text('Masuk sebagai Orang Tua/Wali'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.roleWaliColor,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          const Divider(),
                          const SizedBox(height: 24),
                          
                          // News Section
                          Text(
                            'Informasi & Pengumuman',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _beritaFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              final berita = snapshot.data ?? [];
                              if (berita.isEmpty) {
                                return Text(
                                  'Belum ada berita terbaru.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: berita.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = berita[index];
                                  final createdAt = item['created_at'] != null 
                                      ? DateTime.parse(item['created_at']) 
                                      : DateTime.now();
                                  
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['judul'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item['isi'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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
