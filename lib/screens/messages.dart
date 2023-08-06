// ignore_for_file: prefer_const_constructors

import 'package:chat_application/models/Message.dart';
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
  late String _uidCurrentUser;
  final _controllerMessage = TextEditingController();
  List<String> messageList = [
    "Oi, tudo bem?",
    "Tudo sim, e você?",
    "Tudo ótimo!",
    "Que bom!",
    "Então, como vai o trabalho?",
    "Está indo bem, graças a Deus!",
    "Que bom!",
    "Oi, tudo bem?",
    "Tudo sim, e você?",
    "Tudo ótimo!",
    "Que bom!",
    "Então, como vai o trabalho?",
    "Está indo bem, graças a Deus!",
    "Que bom!",
  ];

  _sendMessage() {
    String messageText = _controllerMessage.text;

    if (messageText.isEmpty) return;

    Message message = Message(
      _uidCurrentUser,
      messageText,
      widget.user.uid!,
    );

    _saveMessageToFirestore(message);
  }

  _saveMessageToFirestore(Message message) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    //Messages/uidSender/uidReceiver/uidMessage/message
    await db
        .collection("messages")
        .doc(message.uidSender)
        .collection(message.uidReceiver)
        .add(message.toMap());
  }

  _recoveryDataUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    setState(() {
      _uidCurrentUser = currentUser.uid;
    });
  }

  @override
  void initState() {
    super.initState();
    _recoveryDataUser();
  }

  @override
  Widget build(BuildContext context) {
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

    var messageListView = Expanded(
      child: ListView.builder(
        itemCount: messageList.length,
        itemBuilder: (context, index) {
          double width = MediaQuery.of(context).size.width * 0.8;

          // define colors and aligns
          Alignment align = Alignment.centerLeft;
          Color color = Colors.grey[300]!;
          if (index % 2 == 0) {
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
                  messageList[index],
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
                messageListView,
                messageBoxView,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
