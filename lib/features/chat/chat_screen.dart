import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_provider.dart';
import '../../core/theme.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatScreen({super.key, required this.peerId, required this.peerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      Provider.of<AppProvider>(context, listen: false).sendMessage(widget.peerId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final messages = provider.getChatHistory(widget.peerId);
    final myId = provider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == myId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : null,
                        bottomLeft: !isMe ? const Radius.circular(0) : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
