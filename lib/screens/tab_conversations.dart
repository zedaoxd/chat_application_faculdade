// ignore_for_file: avoid_unnecessary_containers, prefer_final_fields, prefer_const_constructors, unnecessary_null_comparison

import 'dart:async';

import 'package:chat_application/models/user.dart';
import 'package:chat_application/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabConversations extends StatefulWidget {
  const TabConversations({super.key});

  @override
  State<TabConversations> createState() => _TabConversationsState();
}

class _TabConversationsState extends State<TabConversations> {
  late String _uidCurrentUser;
  final _controller = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _addListenerChats() {
    final stream = FirebaseFirestore.instance
        .collection("chats")
        .doc(_uidCurrentUser)
        .collection("lastMessage")
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
    });

    return stream;
  }

  _loadInitialData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;
    _uidCurrentUser = currentUser!.uid;

    _addListenerChats();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
          case ConnectionState.active:
            if (snapshot.hasError) {
              return Text("Erro ao carregar os dados!");
            }

            QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;

            if (querySnapshot.docs.isEmpty) {
              return Center(
                child: Text(
                  "Você não tem nenhuma mensagem ainda :( ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return ListView.builder(
              itemCount: querySnapshot.docs.length,
              itemBuilder: (context, index) {
                List<DocumentSnapshot> chats = querySnapshot.docs.toList();
                DocumentSnapshot item = chats[index];

                String urlImage = item["photoUrl"];
                String name = item["name"];
                String lastMessage = item["lastMessage"];
                String uid = item["uidReceiver"];

                UserModel contact = UserModel.short(uid, name, urlImage);

                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.messages,
                      arguments: contact,
                    );
                  },
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        urlImage != null ? NetworkImage(urlImage) : null,
                    child: urlImage == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    lastMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                );
              },
            );
        }
      },
    );
  }
}
