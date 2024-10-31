import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key});
  @override
  State<ChatMessage> createState() => _ChatMessage();
}

class _ChatMessage extends State<ChatMessage> {
  late TextEditingController _message;

  @override
  void initState() {
    super.initState();
    _message = TextEditingController();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final typedMessage = _message.text;
    if (typedMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _message.clear();
    // send to firbase firestore
    final user = FirebaseAuth.instance.currentUser;
    final userProfile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    await FirebaseFirestore.instance.collection("chats").add({
      "message": typedMessage,
      "time": Timestamp.now(),
      'userId': user.uid,
      'username': userProfile.data()!['username'],
      'imageUrl': userProfile.data()!['image_url']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _message,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: "write a message"),
            ),
          ),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
