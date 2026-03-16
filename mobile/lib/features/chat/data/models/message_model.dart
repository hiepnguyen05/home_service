import 'package:firebase_database/firebase_database.dart';

enum MessageType { text, image, system }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final MessageType type;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory MessageModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return MessageModel(
      id: snapshot.key ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      type: _parseMessageType(data['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': ServerValue.timestamp, // Thời gian phía server RTDB
      'type': type.name,
    };
  }

  static MessageType _parseMessageType(String? type) {
    if (type == 'image') return MessageType.image;
    if (type == 'system') return MessageType.system;
    return MessageType.text;
  }

  static MessageModel fromMap(String id, Map<dynamic, dynamic> data) {
    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      type: _parseMessageType(data['type']),
    );
  }
}
