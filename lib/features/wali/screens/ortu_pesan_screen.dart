import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/ortu_provider.dart';
import '../../../core/providers/pesan_provider.dart';
import '../../../core/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/anak_tab_selector.dart';
import '../../shared/screens/chat_thread_screen.dart';

class OrtuPesanScreen extends ConsumerStatefulWidget {
  final bool isNested;
  const OrtuPesanScreen({super.key, this.isNested = true});

  @override
  ConsumerState<OrtuPesanScreen> createState() => _OrtuPesanScreenState();
}

class _OrtuPesanScreenState extends ConsumerState<OrtuPesanScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userState = ref.read(authProvider);
      final userId = userState?.supabaseUser?.id ?? userState?.id ?? '';
      await ref.read(pesanProvider.notifier).fetchPercakapanOrtu(userId);
    } catch (_) {
      // Ignored, handled by Riverpod error state
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    final ortuState = ref.watch(ortuProvider);
    final selectedAnakId = ortuState.selectedAnakId;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
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
              final conversations = pesanState.conversations;
              final children = pesanState.children;

              // Filter conversations and children by selected child
              final filteredConversations = selectedAnakId == null
                  ? conversations
                  : conversations.where((c) => c['santri_id'] == selectedAnakId).toList();

              final filteredChildren = selectedAnakId == null
                  ? children
                  : children.where((c) => c['id'] == selectedAnakId).toList();

              // If no conversations exist yet
              if (conversations.isEmpty) {
                if (children.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Belum ada data santri yang terkait dengan akun ini.'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredChildren.length,
                  itemBuilder: (context, index) {
                    final child = filteredChildren[index];
                    final namaSantri = child['nama_lengkap'] ?? '';
                    final halaqah = child['halaqah'] as Map<String, dynamic>?;
                    final pengampu = halaqah?['profiles'] as Map<String, dynamic>?;
                    final namaPengampu = pengampu?['nama_lengkap'] ?? 'Pengampu';
                    final pengampuId = halaqah?['pengampu_id'] ?? '';

                    return AppCard(
                      role: 'orang_tua',
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaSantri, style: AppTextStyles.h4),
                          const SizedBox(height: 4),
                          Text('Pengampu: $namaPengampu', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final userState = ref.read(authProvider);
                                final userId = userState?.supabaseUser?.id ?? userState?.id ?? '';
                                if (pengampuId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ID Pengampu tidak valid')),
                                  );
                                  return;
                                }

                                final threadId = await ref.read(pesanProvider.notifier).getOrCreatePercakapan(
                                  santriId: child['id'],
                                  pengampuId: pengampuId,
                                  ortuId: userId,
                                );

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatThreadScreen(
                                        santriId: child['id'],
                                        santriNama: namaSantri,
                                        ortuId: userId,
                                        percakapanId: threadId,
                                        currentRole: 'orang_tua',
                                        partnerNama: 'Pengampu: $namaPengampu',
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 16),
                              label: const Text('Mulai Percakapan', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: filteredConversations.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada percakapan untuk filter ini.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredConversations.length,
                            itemBuilder: (context, index) {
                              final c = filteredConversations[index];
                              final santri = c['santri'] as Map<String, dynamic>?;
                              final pengampu = c['pengampu'] as Map<String, dynamic>?;
                              
                              final namaSantri = santri?['nama_lengkap'] ?? '';
                              final namaPengampu = pengampu?['nama_lengkap'] ?? 'Pengampu';
                              
                              final lastMsg = c['last_message'] as Map<String, dynamic>?;
                              final lastMsgText = lastMsg?['isi'] ?? 'Belum ada pesan';
                              final timestamp = lastMsg?['created_at'] != null 
                                  ? _formatTime(lastMsg!['created_at']) 
                                  : '';

                              return AppCard(
                                role: 'orang_tua',
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
                                        'Pengampu: $namaPengampu',
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
                                    final userState = ref.read(authProvider);
                                    final userId = userState?.supabaseUser?.id ?? userState?.id ?? '';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatThreadScreen(
                                          santriId: c['santri_id'],
                                          santriNama: namaSantri,
                                          ortuId: userId,
                                          percakapanId: c['id'],
                                          currentRole: 'orang_tua',
                                          partnerNama: 'Pengampu: $namaPengampu',
                                        ),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );

    return Scaffold(
      appBar: widget.isNested
          ? null
          : buildCustomAppBar(
              context: context,
              role: 'orang_tua',
              isNested: true,
              title: 'Pesan',
            ),
      body: Column(
        children: [
          const AnakTabSelector(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
