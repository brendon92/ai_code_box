import 'package:ai_code_box/features/agents/models/agent.dart' as models;
import 'package:ai_code_box/features/chat/models/message.dart';

/// Abstract interface for AI services
abstract class AIService {
  /// Sends a message to the AI and returns a stream of the response
  Stream<String> sendMessage({
    required models.Agent agent,
    required String userMessage,
    required List<Message> conversationHistory,
  });

  /// Sends a message and returns the complete response (non-streaming)
  Future<String> sendMessageComplete({
    required models.Agent agent,
    required String userMessage,
    required List<Message> conversationHistory,
  });
}

