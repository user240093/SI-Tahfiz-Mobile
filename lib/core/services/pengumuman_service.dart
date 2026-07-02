import 'package:flutter/material.dart';
import '../supabase_client.dart';

class PengumumanService {
  static Future<void> checkAndShowPengumuman(
    BuildContext context,
    String userRole,
    String userId,
  ) async {
    try {
      // Step 1: fetch all announcements for this role
      final semuaPengumuman = await supabase
          .from('pengumuman')
          .select('*')
          .contains('target_role', [userRole]);

      if (semuaPengumuman.isEmpty) return;

      // Step 2: fetch already-read announcement IDs
      final sudahDibaca = await supabase
          .from('pengumuman_read')
          .select('pengumuman_id')
          .eq('user_id', userId);

      final sudahDibacaIds = (sudahDibaca as List)
          .map((r) => r['pengumuman_id'] as String)
          .toSet();

      // Step 3: filter unread
      final belumDibaca = (semuaPengumuman as List)
          .where((p) => !sudahDibacaIds.contains(p['id']))
          .toList();

      if (belumDibaca.isEmpty) return;

      // Step 4: show dialog for each unread announcement sequentially
      for (final pengumuman in belumDibaca) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              pengumuman['judul'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
            content: SingleChildScrollView(
              child: Text(
                pengumuman['isi'],
                style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  // Mark as read BEFORE closing dialog
                  try {
                    await supabase.from('pengumuman_read').insert({
                      'pengumuman_id': pengumuman['id'],
                      'user_id': userId,
                    });
                  } catch (_) {
                    // If already inserted (race condition), ignore the error
                  }
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Fail silently to prevent app block in case of network issues
      debugPrint('Error showing pengumuman: $e');
    }
  }
}
