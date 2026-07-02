import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ortu_provider.dart';

class AnakTabSelector extends ConsumerWidget {
  const AnakTabSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ortuState = ref.watch(ortuProvider);
    final anakList = ortuState.anakList;

    if (anakList.length <= 1) return const SizedBox.shrink(); // Hide if only one anak

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: anakList.map((anak) {
            final isSelected = anak['id'] == ortuState.selectedAnakId;
            return GestureDetector(
              onTap: () => ref.read(ortuProvider.notifier).switchAnak(anak['id']),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  anak['nama_lengkap'] ?? '',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
