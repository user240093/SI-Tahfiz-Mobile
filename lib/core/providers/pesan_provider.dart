import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class PesanState {
  final List<Map<String, dynamic>> conversations;
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> children;

  PesanState({
    this.conversations = const [],
    this.messages = const [],
    this.children = const [],
  });

  PesanState copyWith({
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? children,
  }) {
    return PesanState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      children: children ?? this.children,
    );
  }
}

class PesanNotifier extends StateNotifier<AsyncValue<PesanState>> {
  PesanNotifier() : super(const AsyncValue.loading());

  Future<void> fetchPercakapanPengampu(String halaqahId) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Load all santri in halaqah having orang_tua_id
      final santriRes = await supabase
          .from('santri')
          .select('id, nama_lengkap, orang_tua_id, orang_tua(nama_lengkap)')
          .eq('halaqah_id', halaqahId)
          .not('orang_tua_id', 'is', null);

      // Load conversations for this pengampu
      final percakapanRes = await supabase
          .from('percakapan')
          .select('id, santri_id, ortu_id, pesan(id, isi, created_at, pengirim_id)')
          .eq('pengampu_id', currentUser.id);

      final santriList = List<Map<String, dynamic>>.from(santriRes);
      final percakapanList = List<Map<String, dynamic>>.from(percakapanRes);

      final List<Map<String, dynamic>> result = [];
      for (var santri in santriList) {
        final santriId = santri['id'];
        final perc = percakapanList.firstWhere(
          (p) => p['santri_id'] == santriId,
          orElse: () => {},
        );

        Map<String, dynamic>? percakapanData;
        if (perc.isNotEmpty) {
          final messages = List<Map<String, dynamic>>.from(perc['pesan'] ?? []);
          if (messages.isNotEmpty) {
            messages.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
          }
          percakapanData = {
            'id': perc['id'],
            'santri_id': perc['santri_id'],
            'ortu_id': perc['ortu_id'],
            'last_message': messages.isNotEmpty ? messages.first : null,
            'messages': messages,
          };
        }

        result.add({
          'santri': santri,
          'percakapan': percakapanData,
        });
      }

      state = AsyncValue.data(PesanState(conversations: result));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> fetchPercakapanOrtu(String ortuId) async {
    state = const AsyncValue.loading();
    try {
      final percakapanRes = await supabase
          .from('percakapan')
          .select('id, santri_id, pengampu_id, santri(nama_lengkap), profiles!pengampu_id(nama_lengkap), pesan(id, isi, created_at, pengirim_id)')
          .eq('ortu_id', ortuId);

      final santriRes = await supabase
          .from('santri')
          .select('id, nama_lengkap, halaqah_id, halaqah(pengampu_id, profiles:pengampu_id(nama_lengkap))')
          .eq('orang_tua_id', ortuId);

      final percakapanList = List<Map<String, dynamic>>.from(percakapanRes);
      final santriList = List<Map<String, dynamic>>.from(santriRes);

      final List<Map<String, dynamic>> result = [];
      for (var perc in percakapanList) {
        final messages = List<Map<String, dynamic>>.from(perc['pesan'] ?? []);
        if (messages.isNotEmpty) {
          messages.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
        }

        result.add({
          'id': perc['id'],
          'santri_id': perc['santri_id'],
          'pengampu_id': perc['pengampu_id'],
          'santri': perc['santri'],
          'pengampu': perc['profiles'],
          'last_message': messages.isNotEmpty ? messages.first : null,
          'messages': messages,
        });
      }

      state = AsyncValue.data(PesanState(
        conversations: result,
        children: santriList,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<String> getOrCreatePercakapan({
    required String santriId,
    required String pengampuId,
    required String ortuId,
  }) async {
    final existing = await supabase
        .from('percakapan')
        .select('id')
        .eq('santri_id', santriId)
        .eq('pengampu_id', pengampuId)
        .eq('ortu_id', ortuId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final newThread = await supabase
        .from('percakapan')
        .insert({
          'santri_id': santriId,
          'pengampu_id': pengampuId,
          'ortu_id': ortuId,
        })
        .select()
        .single();

    return newThread['id'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String percakapanId) async {
    try {
      final messagesRes = await supabase
          .from('pesan')
          .select('id, isi, created_at, pengirim_id')
          .eq('percakapan_id', percakapanId)
          .order('created_at', ascending: true);

      final messagesList = List<Map<String, dynamic>>.from(messagesRes);
      
      if (state is AsyncData) {
        final currentVal = (state as AsyncData<PesanState>).value;
        state = AsyncValue.data(currentVal.copyWith(messages: messagesList));
      } else {
        state = AsyncValue.data(PesanState(messages: messagesList));
      }
      return messagesList;
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
      rethrow;
    }
  }

  Future<void> sendMessage(String percakapanId, String isi) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    await supabase.from('pesan').insert({
      'percakapan_id': percakapanId,
      'pengirim_id': currentUser.id,
      'isi': isi.trim(),
    });
  }
}

final pesanProvider = StateNotifierProvider<PesanNotifier, AsyncValue<PesanState>>((ref) {
  return PesanNotifier();
});

// Legacy compatibility stubs for unused screens
final chatContactsProvider = Provider<List<dynamic>>((ref) => []);
final chatHistoryProvider = Provider.family<List<dynamic>, String>((ref, peerId) => []);
