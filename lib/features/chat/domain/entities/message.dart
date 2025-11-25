class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory Message.user(String content) {
    return Message(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory Message.ai(String content) {
    return Message(
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
