import '../../domain/entities/message.dart';

class ChatModel extends Message {
  const ChatModel({
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      content: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': content,
    };
  }

  factory ChatModel.fromEntity(Message message) {
    return ChatModel(
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
    );
  }
}
