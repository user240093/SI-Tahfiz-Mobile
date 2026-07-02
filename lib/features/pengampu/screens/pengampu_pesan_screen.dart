import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pesan_provider.dart';
import '../../../core/supabase_client.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/app_card.dart';
import '../../shared/screens/chat_thread_screen.dart';

class PengampuPesanScreen extends ConsumerStatefulWidget {
  const PengampuPesanScreen({super.key});

  @override
  ConsumerState<PengampuPesanScreen> createState() => _PengampuPesanScreenState();
}

class _PengampuPesanScreenState extends ConsumerState<PengampuPesanScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingHalaqah = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingHalaqah = true;
      _error = null;
    });

    try {
      final userState = ref.read(authProvider);
      final userId = userState?.supabaseUser?.id ?? userState?.id ?? '';

      final halaqahRes = await supabase
          .from('halaqah')
          .select('id')
          .eq('pengampu_id', userId)
          .maybeSingle();

      if (halaqahRes != null) {
        final halaqahId = halaqahRes['id'] as String;
        await ref.read(pesanProvider.notifier).fetchPercakapanPengampu(halaqahId);
      } else {
        setState(() {
          _error = 'Halaqah pengampu tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data halaqah: $e';
      });
    } finally {
      setState(() {
        _isLoadingHalaqah = false;
      });
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final hour = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        return '$hour:$min';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pesanStateAsync = ref.watch(pesanProvider);

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'pengampu',
        isNested: true,
        title: 'Pesan',
      ),
      body: _isLoadingHalaqah
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: AppTextStyles.body),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : pesanStateAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gagal memuat percakapan: $err', style: AppTextStyles.body),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  data: (pesanState) {
                    final items = pesanState.conversations;
                    
                    // Filter items by search query
                    final filteredItems = items.where((item) {
                      final santri = item['santri'] as Map<String, dynamic>;
                      final namaSantri = (santri['nama_lengkap'] as String).toLowerCase();
                      return namaSantri.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari nama santri...',
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF10B981)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredItems.isEmpty
                              ? Center(
                                  child: Text(
                                    items.isEmpty
                                        ? 'Belum ada santri dengan akun orang tua'
                                        : 'Santri tidak ditemukan',
                                    style: AppTextStyles.body.copyWith(color: const Color(0xFF6B7280)),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    final santri = item['santri'] as Map<String, dynamic>;
                                    final perc = item['percakapan'] as Map<String, dynamic>?;
                                    
                                    final namaSantri = santri['nama_lengkap'] ?? '';
                                    final ortu = santri['orang_tua'] as Map<String, dynamic>?;
                                    final namaOrtu = ortu?['nama_lengkap'] ?? 'Orang Tua';
                                    
                                    final lastMsg = perc?['last_message'] as Map<String, dynamic>?;
                                    final lastMsgText = lastMsg?['isi'] ?? 'Belum ada pesan';
                                    final timestamp = lastMsg?['created_at'] != null 
                                        ? _formatTime(lastMsg!['created_at']) 
                                        : '';

                                    return AppCard(
                                      role: 'pengampu',
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.zero,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                                          child: const Icon(Icons.person, color: Color(0xFF10B981)),
                                        ),
                                        title: Text(namaSantri, style: AppTextStyles.h5),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              'Orang Tua: $namaOrtu',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              lastMsgText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.body.copyWith(
                                                fontSize: 13,
                                                color: lastMsg == null ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              timestamp,
                                              style: AppTextStyles.bodySmall.copyWith(
                                                fontSize: 11,
                                                color: const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatThreadScreen(
                                                santriId: santri['id'],
                                                santriNama: namaSantri,
                                                ortuId: santri['orang_tua_id'],
                                                percakapanId: perc?['id'],
                                                currentRole: 'pengampu',
                                                partnerNama: 'Wali: $namaOrtu',
                                              ),
                                            ),
                                          ).then((_) {
                                            // Refresh on return
                                            _loadData();
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
