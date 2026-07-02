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
    String labelText;

    switch (cleanStatus) {
      case 'wajib_sekolah':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        labelText = 'Wajib Sekolah';
        break;
      case 'selesai_sekolah':
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        labelText = 'Selesai Sekolah';
        break;
      case 'wajib_rumah':
        bg = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        labelText = 'Wajib Rumah';
        break;
      case 'selesai_rumah':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        labelText = 'Selesai Rumah';
        break;
      case 'lulus':
      case 'selesai':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        labelText = 'Selesai';
        break;
      case 'pending':
      case 'menunggu':
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        labelText = 'Pending';
        break;
      case 'ditolak':
      case 'error':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        labelText = 'Ditolak';
        break;
      case 'izin':
        bg = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        labelText = 'Izin';
        break;
      case 'sakit':
        bg = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF6B21A8);
        labelText = 'Sakit';
        break;
      case 'alpha':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        labelText = 'Alpha';
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        labelText = status.replaceAll('_', ' ');
        if (labelText.isNotEmpty) {
          labelText = labelText[0].toUpperCase() + labelText.substring(1);
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999), // Pill badge
      ),
      child: Text(
        labelText,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
