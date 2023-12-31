import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class Message {
  final String content;
  final String address;
  final DateTime time;

  const Message({
    required this.content,
    required this.address,
    required this.time,
  });

  Map<String, String> toMap() {
    return {
      "content": content,
      "address": address,
      "time": time.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      content: map["content"],
      address: map["address"],
      time: DateTime.parse(map["time"] as String),
    );
  }

  factory Message.fromSMSMessage(SmsMessage message) {
    return Message(
      content: message.body!,
      address: message.address!,
      time: message.date!,
    );
  }

  factory Message.test() {
    return Message(
      content: 'yah',
      address: 'oh',
      time: DateTime.now(),
    );
  }

  bool equals(Message other) {
    return content == other.content &&
        address == other.address &&
        time == other.time;
  }
}
