import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/pesan_provider.dart';
import '../../core/text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../chat/chat_screen.dart';

class MurobbiChatList extends ConsumerWidget {
  const MurobbiChatList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(chatContactsProvider);

    final content = contacts.isEmpty
        ? Center(child: Text('Belum ada kontak Wali Santri.', style: AppTextStyles.body))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return AppCard(
                role: 'pengampu',
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF10B981)),
                  ),
                  title: Text(contact.name, style: AppTextStyles.h5),
                  subtitle: Text('Ketuk untuk mengirim pesan', style: AppTextStyles.bodySmall),
                  trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF10B981)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(peerId: contact.id, peerName: contact.name),
                      ),
                    );
                  },
                ),
              );
            },
          );

    return Scaffold(
      appBar: buildCustomAppBar(
        context: context,
        role: 'pengampu',
        isNested: true,
        title: 'Pesan',
      ),
      body: content,
    );
  }
}
