// ignore_for_file: avoid_unnecessary_containers, prefer_final_fields

import 'package:chat_application/models/chat.dart';
import 'package:flutter/material.dart';

class TabConversations extends StatefulWidget {
  const TabConversations({super.key});

  @override
  State<TabConversations> createState() => _TabConversationsState();
}

class _TabConversationsState extends State<TabConversations> {
  List<Chat> _chats = [
    Chat(
        name: "Jose Luis",
        lastMessage: "Me indica uma serie?",
        photoUrl:
            "https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-23b39.appspot.com/o/profile%2Fperfil2.jpg?alt=media&token=c06242e6-dccf-4d75-bc34-ace2034c5495"),
    Chat(
        name: "Maria Clara",
        lastMessage: "Olá, tudo bem?",
        photoUrl:
            "https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-23b39.appspot.com/o/profile%2Fperfil1.jpg?alt=media&token=64fb5312-41a4-4305-9c62-4d871bf59ae3"),
    Chat(
        name: "Bianca",
        lastMessage: "Foi massa d+",
        photoUrl:
            "https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-23b39.appspot.com/o/profile%2Fperfil3.jpg?alt=media&token=eee21f4b-1440-4322-8e9a-9736f9a2295b"),
    Chat(
        name: "Marcos",
        lastMessage: "Eai cara!",
        photoUrl:
            "https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-23b39.appspot.com/o/profile%2Fperfil4.jpg?alt=media&token=2f4641fc-9311-4a0e-b38e-7e1dc43c1300"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          Chat chat = _chats[index];

          return ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(chat.photoUrl),
            ),
            title: Text(
              chat.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              chat.lastMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        });
  }
}
