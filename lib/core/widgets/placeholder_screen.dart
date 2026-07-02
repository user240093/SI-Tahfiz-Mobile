import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import 'custom_app_bar.dart';

class PlaceholderScreen extends ConsumerWidget {
  final String routeName;
  final bool isNested;

  const PlaceholderScreen({
    super.key,
    required this.routeName,
    this.isNested = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState?.roleString ?? 'tu';

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: role,
        isNested: isNested,
        title: routeName,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 80,
                color: Color(0xFFD1D5DB),
              ),
              const SizedBox(height: 16),
              Text(
                'Halaman Sedang Dibuat',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rute: $routeName',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
