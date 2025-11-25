import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Stream<String> call(String message, List<Message> history) {
    return repository.sendMessage(message, history);
  }
}
