import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/login_email_screen.dart';
import '../../core/theme.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginEmailScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Colors.white,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.1, duration: 1500.ms, curve: Curves.easeInOut)
            .fadeIn(duration: 800.ms),
            const SizedBox(height: 32),
            Text(
              'SI-Tahfiz Mobile',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOut).fadeIn(),
            const SizedBox(height: 8),
            Text(
              'MTs TQ Jamilurrahman Yogyakarta',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOut).fadeIn(),
            const SizedBox(height: 64),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.8),
                strokeWidth: 3,
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
