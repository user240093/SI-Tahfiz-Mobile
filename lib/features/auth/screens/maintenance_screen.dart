import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade700,
              Colors.orange.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.1, duration: 1500.ms, curve: Curves.easeInOut)
                .fadeIn(duration: 800.ms),
                const SizedBox(height: 32),
                Text(
                  'Pemeliharaan Sistem',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOut).fadeIn(),
                const SizedBox(height: 16),
                Text(
                  'Sistem Informasi SI-Tahfiz saat ini sedang dalam pemeliharaan berkala untuk meningkatkan layanan kami. Silakan coba beberapa saat lagi.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOut).fadeIn(),
                const SizedBox(height: 48),
                CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.8),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
