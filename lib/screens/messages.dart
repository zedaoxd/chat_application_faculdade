// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'dart:async';

import 'package:chat_application/models/Message.dart';
import 'package:chat_application/models/chat.dart';
import 'package:chat_application/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  UserModel user;
  Messages(this.user, {super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late String _uidCurrentUser;
  late String _urlImageCurrentUser;
  late String _nameCurrentUser;
  final _controllerMessage = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  final ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot> _addListenerMessages() {
    final stream = db
        .collection("messages")
        .doc(_uidCurrentUser)
        .collection(widget.user.uid!)
        .orderBy("date", descending: false)
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
      Timer(
          Duration(seconds: 1),
          () => _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent));
    });

    return stream;
  }

  _sendMessage() {
    String messageText = _controllerMessage.text;

    if (messageText.isEmpty) return;

    Message message = Message(
      _uidCurrentUser,
      messageText,
      widget.user.uid!,
      Timestamp.now().toString(),
    );

    _saveMessageToFirestore(message);

    // clear text
    _controllerMessage.clear();
  }

  _saveMessageToFirestore(Message message) async {
    //Messages/uidSender/uidReceiver/uidMessage/message
    await db
        .collection("messages")
        .doc(message.uidSender)
        .collection(message.uidReceiver)
        .add(message.toMap());

    //Messages/uidReceiver/uidSender/uidMessage/message
    await db
        .collection("messages")
        .doc(message.uidReceiver)
        .collection(message.uidSender)
        .add(message.toMap());

    // save chat
    _saveChat(message);
  }

  _saveChat(Message message) {
    // sender chat
    Chat senderChat = Chat(
      lastMessage: message.message,
      name: widget.user.name,
      photoUrl: widget.user.urlImage!,
      uidReceiver: widget.user.uid!,
      uidSender: _uidCurrentUser,
    );

    senderChat.saveToFirebase(db);

    // receiver chat
    Chat receiverChat = Chat(
      lastMessage: message.message,
      name: _nameCurrentUser,
      photoUrl: _urlImageCurrentUser,
      uidReceiver: _uidCurrentUser,
      uidSender: widget.user.uid!,
    );

    receiverChat.saveToFirebase(db);
  }

  _recoveryDataUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    setState(() {
      _uidCurrentUser = currentUser.uid;
    });

    DocumentSnapshot snapshot =
        await db.collection("users").doc(_uidCurrentUser).get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    setState(() {
      _urlImageCurrentUser = data["urlImage"];
      _nameCurrentUser = data["name"];
    });
  }

  @override
  void initState() {
    super.initState();
    _recoveryDataUser();
    _addListenerMessages();
  }

  @override
  Widget build(BuildContext context) {
    var stream = StreamBuilder(
      stream: _controller.stream,
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
          case ConnectionState.done:
          case ConnectionState.active:
            QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;

            if (snapshot.hasError) {
              return Expanded(child: Text("Erro ao carregar os dados!"));
            }

            return Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: querySnapshot.docs.length,
                itemBuilder: (context, index) {
                  List<DocumentSnapshot> messages = querySnapshot.docs.toList();
                  DocumentSnapshot item = messages[index];

                  double width = MediaQuery.of(context).size.width * 0.8;

                  // define colors and aligns
                  Alignment align = Alignment.centerLeft;
                  Color color = Colors.grey[300]!;
                  if (_uidCurrentUser == item["uidSender"]) {
                    align = Alignment.centerRight;
                    color = Colors.blue[300]!;
                  }

                  return Align(
                    alignment: align,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Container(
                        width: width,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item["message"],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
        }
      },
    );

    var messageBoxView = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllerMessage,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                hintText: "Digite uma mensagem...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          FloatingActionButton(
            mini: true,
            onPressed: _sendMessage,
            child: Icon(Icons.send),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            maxRadius: 20,
            backgroundColor: Colors.grey,
            backgroundImage: widget.user.urlImage == ""
                ? null
                : NetworkImage(widget.user.urlImage!) as ImageProvider,
            child: widget.user.urlImage == ""
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  )
                : null,
          ),
          SizedBox(
            width: 8,
          ),
          Text(widget.user.name),
        ]),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white38,
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                stream,
                messageBoxView,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
