import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/grade_provider.dart';
import '../../../core/providers/halaqah_provider.dart';
import '../../../core/text_styles.dart';

class KoordinatorGradeScreen extends ConsumerStatefulWidget {
  const KoordinatorGradeScreen({super.key});

  @override
  ConsumerState<KoordinatorGradeScreen> createState() => _KoordinatorGradeScreenState();
}

class _KoordinatorGradeScreenState extends ConsumerState<KoordinatorGradeScreen> {
  String? _selectedHalaqahId;
  String? _selectedGrade; // null or "tahsin" | "takmil" | "tahfiz"
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditGradeDialog(BuildContext context, Map<String, dynamic> santri) {
    final santriId = santri['id'] as String;
    final namaSantri = santri['nama_lengkap'] ?? '';
    final currentGrade = (santri['grade'] as String? ?? '').toLowerCase();

    String selectedGrade = currentGrade;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                "Ubah Grade — $namaSantri",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grade saat ini: ${currentGrade.isNotEmpty ? currentGrade[0].toUpperCase() + currentGrade.substring(1) : '-'}",
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text("Tahsin"),
                    value: "tahsin",
                    groupValue: selectedGrade,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedGrade = val!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Takmil"),
                    value: "takmil",
                    groupValue: selectedGrade,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedGrade = val!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Tahfiz"),
                    value: "tahfiz",
                    groupValue: selectedGrade,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedGrade = val!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (selectedGrade == currentGrade) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Grade tidak berubah"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                      return;
                    }

                    final success = await ref.read(gradeProvider.notifier).updateGrade(
                      santriId,
                      selectedGrade,
                      currentGrade,
                    );

                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Grade santri berhasil diperbarui"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Gagal memperbarui grade"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGradeBadge(String? grade) {
    final cleanGrade = (grade ?? '').toLowerCase();
    Color bgColor;
    Color textColor;
    String label;

    switch (cleanGrade) {
      case 'tahsin':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        label = 'Tahsin';
        break;
      case 'takmil':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        label = 'Takmil';
        break;
      case 'tahfiz':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        label = 'Tahfiz';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = grade ?? '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final santriListAsync = ref.watch(gradeProvider);
    final halaqahListAsync = ref.watch(halaqahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Grade Santri"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Halaqah Dropdown
                    Expanded(
                      child: halaqahListAsync.when(
                        loading: () => const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Halaqah"),
                          items: const [DropdownMenuItem(value: null, child: Text("Semua Halaqah"))],
                          onChanged: (_) {},
                        ),
                        data: (halaqahs) {
                          return DropdownButtonFormField<String>(
                            value: _selectedHalaqahId,
                            decoration: InputDecoration(
                              labelText: "Halaqah",
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Semua Halaqah"),
                              ),
                              ...halaqahs.map((h) => DropdownMenuItem(
                                    value: h['id'] as String,
                                    child: Text(h['nama_halaqah'] ?? ''),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedHalaqahId = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Grade Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: InputDecoration(
                          labelText: "Grade",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text("Semua")),
                          DropdownMenuItem(value: "tahsin", child: Text("Tahsin")),
                          DropdownMenuItem(value: "takmil", child: Text("Takmil")),
                          DropdownMenuItem(value: "tahfiz", child: Text("Tahfiz")),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedGrade = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari nama santri...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List section
          Expanded(
            child: santriListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text("Error: $err", style: AppTextStyles.body.copyWith(color: Colors.red)),
              ),
              data: (santriList) {
                // Apply client-side filters
                final filteredList = santriList.where((s) {
                  // Halaqah filter
                  if (_selectedHalaqahId != null) {
                    final halaqah = s['halaqah'] as Map<String, dynamic>?;
                    if (halaqah == null || halaqah['id'] != _selectedHalaqahId) {
                      return false;
                    }
                  }
                  // Grade filter
                  if (_selectedGrade != null) {
                    final grade = (s['grade'] as String? ?? '').toLowerCase();
                    if (grade != _selectedGrade) {
                      return false;
                    }
                  }
                  // Search query filter (case-insensitive)
                  if (_searchQuery.isNotEmpty) {
                    final nama = (s['nama_lengkap'] as String? ?? '').toLowerCase();
                    if (!nama.contains(_searchQuery.toLowerCase())) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada santri yang cocok dengan filter",
                      style: AppTextStyles.body.copyWith(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final s = filteredList[index];
                    final halaqah = s['halaqah'] as Map<String, dynamic>?;
                    final halaqahNama = halaqah?['nama_halaqah'] ?? 'Tanpa Halaqah';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['nama_lengkap'] ?? '',
                                    style: AppTextStyles.h4,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Kelas: ${s['kelas'] ?? '-'}",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    "Halaqah: $halaqahNama",
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildGradeBadge(s['grade'] as String?),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                                foregroundColor: const Color(0xFF10B981),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _showEditGradeDialog(context, s),
                              child: const Text("Ubah Grade", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
