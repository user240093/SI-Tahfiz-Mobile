import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/pesan_provider.dart';
import '../../../core/supabase_client.dart';
import '../../../core/text_styles.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  final String santriId;
  final String santriNama;
  final String? ortuId; // Can be null if opening from parent with children without thread yet
  final String? percakapanId;
  final String currentRole; // 'pengampu' or 'orang_tua'
  final String partnerNama;

  const ChatThreadScreen({
    super.key,
    required this.santriId,
    required this.santriNama,
    this.ortuId,
    this.percakapanId,
    required this.currentRole,
    required this.partnerNama,
  });

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  
  String? _activePercakapanId;
  RealtimeChannel? _messageChannel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to update send button state (disabled/enabled)
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _unsubscribeFromMessages();
    super.dispose();
  }

  void _unsubscribeFromMessages() {
    if (_messageChannel != null) {
      _messageChannel!.unsubscribe();
      _messageChannel = null;
    }
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userState = ref.read(authProvider);
      final myId = userState?.supabaseUser?.id ?? userState?.id ?? '';
      
      // Determine the pengampu and ortu IDs
      String pengampuId;
      String ortuId;
      
      if (widget.currentRole == 'pengampu') {
        pengampuId = myId;
        ortuId = widget.ortuId ?? '';
      } else {
        ortuId = myId;
        // Fetch pengampu_id from halaqah of this santri
        final santriRes = await supabase
            .from('santri')
            .select('halaqah(pengampu_id)')
            .eq('id', widget.santriId)
            .maybeSingle();
            
        if (santriRes == null || santriRes['halaqah'] == null) {
          throw Exception('Data pengampu untuk santri tidak ditemukan');
        }
        pengampuId = santriRes['halaqah']['pengampu_id'] as String;
      }

      // Step 1: get or create percakapan
      if (widget.percakapanId != null) {
        _activePercakapanId = widget.percakapanId;
      } else {
        _activePercakapanId = await ref.read(pesanProvider.notifier).getOrCreatePercakapan(
          santriId: widget.santriId,
          pengampuId: pengampuId,
          ortuId: ortuId,
        );
      }

      // Step 2: fetch message history
      final history = await ref.read(pesanProvider.notifier).fetchMessages(_activePercakapanId!);
      
      setState(() {
        _messages.clear();
        _messages.addAll(history);
        _isLoading = false;
      });

      _scrollToBottom();

      // Step 3: subscribe to realtime
      _subscribeToMessages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuka percakapan: $e';
        _isLoading = false;
      });
    }
  }

  void _subscribeToMessages() {
    if (_activePercakapanId == null) return;
    
    _unsubscribeFromMessages();

    _messageChannel = supabase
        .channel('percakapan-$_activePercakapanId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'pesan',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'percakapan_id',
            value: _activePercakapanId!,
          ),
          callback: (payload) {
            final newMessage = payload.newRecord;
            if (!_messages.any((m) => m['id'] == newMessage['id'])) {
              setState(() {
                _messages.add(newMessage);
              });
              _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final isi = _messageController.text;
    if (isi.trim().isEmpty || _activePercakapanId == null) return;

    _messageController.clear();
    
    try {
      await ref.read(pesanProvider.notifier).sendMessage(_activePercakapanId!, isi);
      // Realtime subscription will handle adding message to the list
    } catch (e) {
      // Restore message text on failure
      _messageController.text = isi;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesan gagal terkirim, coba lagi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final myId = userState?.supabaseUser?.id ?? userState?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.santriNama,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.partnerNama,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: AppTextStyles.body),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeChat,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Chat Messages List
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Text(
                                'Belum ada pesan. Mulai obrolan sekarang.',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                final isOwn = msg['pengirim_id'] == myId;
                                final timestamp = _formatTime(msg['created_at']);

                                return Align(
                                  alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isOwn ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
                                            borderRadius: isOwn
                                                ? const BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.zero,
                                                  )
                                                : const BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.zero,
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                          ),
                                          child: Text(
                                            msg['isi'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isOwn ? Colors.white : const Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            timestamp,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Bottom Input Area
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _messageController,
                                minLines: 1,
                                maxLines: 5,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                                decoration: InputDecoration(
                                  hintText: 'Tulis pesan...',
                                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Send Button
                            GestureDetector(
                              onTap: _messageController.text.trim().isEmpty ? null : _sendMessage,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: _messageController.text.trim().isEmpty
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: _messageController.text.trim().isEmpty
                                      ? const Color(0xFF9CA3AF)
                                      : Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
