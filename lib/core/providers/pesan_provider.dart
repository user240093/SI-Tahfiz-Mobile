import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';
import 'auth_provider.dart';
import 'santri_provider.dart';

class PesanNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  PesanNotifier() : super(const AsyncValue.loading()) {
    fetchPesan();
  }

  Future<void> fetchPesan() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('pesan')
          .select('*, percakapan(*)');
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      // Try to find a conversation between myId and receiverId
      final existingRes = await supabase
          .from('percakapan')
          .select()
          .or('and(pengampu_id.eq.$myId,ortu_id.eq.$receiverId),and(pengampu_id.eq.$receiverId,ortu_id.eq.$myId)')
          .maybeSingle();

      String percakapanId;
      if (existingRes != null) {
        percakapanId = existingRes['id'];
      } else {
        // Query a santri ID for this conversation
        final santriRes = await supabase
            .from('santri')
            .select('id')
            .or('orang_tua_id.eq.$receiverId,orang_tua_id.eq.$myId')
            .limit(1);

        String? santriId;
        if (santriRes.isNotEmpty) {
          santriId = santriRes[0]['id'];
        } else {
          final anySantri = await supabase.from('santri').select('id').limit(1).maybeSingle();
          santriId = anySantri?['id'];
        }

        if (santriId == null) {
          throw Exception('Santri not found');
        }

        final newPercakapan = await supabase.from('percakapan').insert({
          'santri_id': santriId,
          'pengampu_id': myId == senderId ? receiverId : senderId, // Wait, one of them is pengampu
          'ortu_id': myId == senderId ? senderId : receiverId,
        }).select('id').single();
        percakapanId = newPercakapan['id'];
      }

      await supabase.from('pesan').insert({
        'percakapan_id': percakapanId,
        'pengirim_id': myId,
        'isi': text,
      });

      await fetchPesan();
    } catch (e) {
      rethrow;
    }
  }
}

final pesanProvider = StateNotifierProvider<PesanNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return PesanNotifier();
});

final chatHistoryProvider = Provider.family<List<dynamic>, String>((ref, peerId) {
  final myId = supabase.auth.currentUser?.id;
  final pesanAsync = ref.watch(pesanProvider);
  if (myId == null || pesanAsync is! AsyncData) return [];

  final list = pesanAsync.value ?? [];
  final filtered = list.where((p) {
    final pc = p['percakapan'];
    if (pc == null) return false;
    final pengampuId = pc['pengampu_id'];
    final ortuId = pc['ortu_id'];
    return (pengampuId == myId && ortuId == peerId) || (pengampuId == peerId && ortuId == myId);
  }).map((p) {
    // Return objects matching the structure the UI expects
    return _ChatMessageCompatibility(
      id: p['id'].toString(),
      senderId: p['pengirim_id'].toString(),
      receiverId: p['pengirim_id'].toString() == myId ? peerId : myId,
      text: p['isi'].toString(),
      timestamp: DateTime.parse(p['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }).toList();

  // Sort chronologically
  filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return filtered;
});

final chatContactsProvider = Provider<List<dynamic>>((ref) {
  final myId = supabase.auth.currentUser?.id;
  final santriAsync = ref.watch(santriProvider);
  final authState = ref.watch(authProvider);
  if (myId == null || santriAsync is! AsyncData || authState == null) return [];

  final santriList = santriAsync.value ?? [];
  final role = authState.roleString;
  final List<dynamic> contacts = [];
  final Set<String> contactIds = {};

  if (role == 'pengampu') {
    for (var s in santriList) {
      final halaqah = s['halaqah'];
      if (halaqah != null && halaqah['pengampu_id'] == myId) {
        final ortu = s['orang_tua'];
        final ortuId = s['orang_tua_id'];
        if (ortu != null && ortuId != null && !contactIds.contains(ortuId)) {
          contactIds.add(ortuId);
          contacts.add(_UserCompatibility(
            id: ortuId,
            name: ortu['nama_lengkap'] ?? 'Orang Tua',
            role: 'Wali',
          ));
        }
      }
    }
  } else if (role == 'orang_tua') {
    for (var s in santriList) {
      if (s['orang_tua_id'] == myId) {
        final halaqah = s['halaqah'];
        if (halaqah != null) {
          final pengampuId = halaqah['pengampu_id'];
          final pengampuName = halaqah['profiles']?['nama_lengkap'] ?? 'Ustadz';
          if (pengampuId != null && !contactIds.contains(pengampuId)) {
            contactIds.add(pengampuId);
            contacts.add(_UserCompatibility(
              id: pengampuId,
              name: pengampuName,
              role: 'Murobbi',
            ));
          }
        }
      }
    }
  }

  return contacts;
});

class _ChatMessageCompatibility {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  _ChatMessageCompatibility({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });
}

class _UserCompatibility {
  final String id;
  final String name;
  final String role;

  _UserCompatibility({
    required this.id,
    required this.name,
    required this.role,
  });
}
