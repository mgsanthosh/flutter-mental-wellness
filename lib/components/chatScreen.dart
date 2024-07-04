import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatProps;

  ChatScreen({required this.chatProps});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  Set<String> _messageKeys = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    DatabaseReference chatRef = _dbRef.child('chat/' + widget.chatProps['chatLink']);
    chatRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> chatData = event.snapshot.value as Map;
        List<Map<String, dynamic>> messages = [];
        Set<String> messageKeys = {};

        chatData.forEach((key, value) {
          if (!_messageKeys.contains(key)) {
            messages.add(Map<String, dynamic>.from(value));
            messageKeys.add(key);
          }
        });

        setState(() {
          _messages.addAll(messages);
          _messageKeys.addAll(messageKeys);
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    DatabaseReference chatRef = _dbRef.child('chat/' + widget.chatProps['chatLink']);
    String messageId = chatRef.push().key!;
    chatRef.child(messageId).set({
      'senderId': widget.chatProps['userDetails']['userId'],
      'message': _messageController.text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.chatProps['expertDetails']['firstName']}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isCurrentUser = message['senderId'] == widget.chatProps['userDetails']['userId'];
                return Align(
                  alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['message'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
