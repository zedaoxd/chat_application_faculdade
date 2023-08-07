import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String uidSender;
  String uidReceiver;
  String name;
  String lastMessage;
  String photoUrl;

  Chat({
    required this.uidSender,
    required this.uidReceiver,
    required this.name,
    required this.lastMessage,
    required this.photoUrl,
  });

  saveToFirebase(FirebaseFirestore db) {
    // chats/uidSender/lastMessage/uidReceiver/this
    db
        .collection("chats")
        .doc(uidSender)
        .collection("lastMessage")
        .doc(uidReceiver)
        .set(toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "uidSender": uidSender,
      "uidReceiver": uidReceiver,
      "name": name,
      "lastMessage": lastMessage,
      "photoUrl": photoUrl,
    };
    return map;
  }
}
