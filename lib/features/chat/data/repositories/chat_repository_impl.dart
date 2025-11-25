import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<String> sendMessage(String message, List<Message> history) {
    final newHistory = [...history, Message.user(message)];
    final models = newHistory.map((e) => ChatModel.fromEntity(e)).toList();
    
    return remoteDataSource.sendMessage(models);
  }
}
