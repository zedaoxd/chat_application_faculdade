// ignore_for_file: avoid_unnecessary_containers, prefer_final_fields

import 'package:chat_application/models/user.dart';
import 'package:chat_application/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabContacts extends StatefulWidget {
  const TabContacts({super.key});

  @override
  State<TabContacts> createState() => _TabContactsState();
}

class _TabContactsState extends State<TabContacts> {
  Future<List<UserModel>> _getUsers() async {
    List<UserModel> users = [];
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("users").get();

    for (DocumentSnapshot item in querySnapshot.docs) {
      var data = item.data();
      var dataMap = data as Map<String, dynamic>;

      if (dataMap.containsKey('email') &&
          dataMap['email'] == FirebaseAuth.instance.currentUser?.email) {
        continue;
      }

      users.add(UserModel.withId(
        item.id,
        dataMap['name'],
        dataMap['email'],
        "",
        dataMap['urlImage'],
      ));
    }

    return users;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _getUsers(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Center(
              child: Text("Erro ao carregar os dados!"),
            );
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
            return const Center(
              child: Text("Carregando..."),
            );
          case ConnectionState.done:
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                List<UserModel> users = snapshot.data!;
                UserModel user = users[index];
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.messages,
                      arguments: user,
                    );
                  },
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: user.urlImage == ""
                        ? null
                        : NetworkImage(user.urlImage!) as ImageProvider,
                    child: user.urlImage == ""
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          )
                        : null,
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }
}
