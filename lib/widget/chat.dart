import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No message yet"),
            );
          }
          if (chatSnapshot.hasError) {
            const Center(
              child: Text("An error has occured"),
            );
          }
          final loadedChat = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 14, right: 14),
              reverse: true,
              itemCount: loadedChat.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedChat[index].data();
                final nextChat = index + 1 < loadedChat.length
                    ? loadedChat[index + 1].data()
                    : null;
                final currentUserId = chatMessage['userId'];
                final nextUserId = nextChat != null ? nextChat['userId'] : null;
                final nextUserIsSame = nextUserId == currentUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['message'],
                      isMe: currentUserId == authenticatedUser!.uid);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['imageUrl'],
                      username: chatMessage['username'],
                      message: chatMessage['message'],
                      isMe: currentUserId == authenticatedUser!.uid);
                }
              });
        });
  }
}
