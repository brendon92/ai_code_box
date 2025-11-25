import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/send_message.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/datasources/chat_remote_data_source.dart';

// Dependency Injection
final dioProvider = Provider((ref) => Dio());

final remoteDataSourceProvider = Provider((ref) {
  return OpenAiRemoteDataSource(ref.watch(dioProvider));
});

final chatRepositoryProvider = Provider((ref) {
  return ChatRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final sendMessageUseCaseProvider = Provider((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

// State Management
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier(ref.watch(sendMessageUseCaseProvider));
});

class ChatNotifier extends StateNotifier<List<Message>> {
  final SendMessage _sendMessage;

  ChatNotifier(this._sendMessage) : super([]);

  Future<void> sendMessage(String content) async {
    // Add user message immediately
    final userMessage = Message.user(content);
    state = [...state, userMessage];

    // Add placeholder for AI response
    // In a real app, you'd handle streaming updates more gracefully
    // For now, we'll just print to console as the stream comes in
    // and append a final message when done (simplified for this demo)
    
    try {
      final stream = _sendMessage(content, state);
      String fullResponse = '';
      
      await for (final chunk in stream) {
        fullResponse += chunk;
        // Here you could update the last message state to show streaming effect
      }
      
      final aiMessage = Message.ai(fullResponse);
      state = [...state, aiMessage];
      
    } catch (e) {
      // Handle error
      state = [...state, Message.ai("Error: $e")];
    }
  }
}
