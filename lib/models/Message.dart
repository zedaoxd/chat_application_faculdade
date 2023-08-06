// ignore_for_file: file_names

class Message {
  String uidSender;
  String message;
  String uidReceiver;

  Message(this.uidSender, this.message, this.uidReceiver);

  Map<String, dynamic> toMap() {
    return {
      'idUser': uidSender,
      'message': message,
      'receiver': uidReceiver,
    };
  }
}
