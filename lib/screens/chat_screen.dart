import 'package:chat_app/widget/chat.dart';
import 'package:chat_app/widget/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter chat"),
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
      ),
      body: const Center(
          child: Column(
        children: [
          Expanded(
            child: Chat(),
          ),
          ChatMessage()
        ],
      )),
    );
  }
}
