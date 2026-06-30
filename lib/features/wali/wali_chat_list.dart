import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';
import '../chat/chat_screen.dart';

class WaliChatList extends StatelessWidget {
  const WaliChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final contacts = provider.getChatContacts();

    return contacts.isEmpty
        ? const Center(child: Text('Belum ada kontak Murobbi.'))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.roleWaliColor.withOpacity(0.1), child: const Icon(Icons.person, color: AppTheme.roleWaliColor)),
                  title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Murobbi Anak Anda'),
                  trailing: const Icon(Icons.chat_bubble_outline),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => 
                      ChatScreen(peerId: contact.id, peerName: contact.name)
                    ));
                  },
                ),
              );
            },
          );
  }
}
