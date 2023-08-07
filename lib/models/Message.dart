// ignore_for_file: file_names

class Message {
  String uidSender;
  String message;
  String uidReceiver;
  String date;

  Message(this.uidSender, this.message, this.uidReceiver, this.date);

  Map<String, dynamic> toMap() {
    return {
      'uidSender': uidSender,
      'message': message,
      'uidReceiver': uidReceiver,
      'date': date,
    };
  }
}
