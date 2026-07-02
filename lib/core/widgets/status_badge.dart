import 'package:flutter/material.dart';
import '../text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toLowerCase();

    Color bg;
    Color textColor;

    switch (cleanStatus) {
      case 'lulus':
      case 'selesai':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'pending':
      case 'menunggu':
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'ditolak':
      case 'error':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      case 'izin':
        bg = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        break;
      case 'sakit':
        bg = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF6B21A8);
        break;
      case 'alpha':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999), // Pill badge
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
