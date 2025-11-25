import '../entities/message.dart';

abstract class ChatRepository {
  /// Sends a message to the AI provider and returns the response stream.
  Stream<String> sendMessage(String message, List<Message> history);
}
