import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? actionButton;

  const EmptyStateWidget({
    super.key,
    this.title = 'Belum ada data',
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: const Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 20),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
