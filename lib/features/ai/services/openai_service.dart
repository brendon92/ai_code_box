import 'dart:async';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:ai_code_box/features/ai/services/ai_service.dart';
import 'package:ai_code_box/features/agents/models/agent.dart' as models;
import 'package:ai_code_box/features/chat/models/message.dart';

/// OpenAI implementation of AIService
class OpenAIService implements AIService {
  final String apiKey;
  ChatOpenAI? _chatModel;

  OpenAIService({required this.apiKey}) {
    _initializeChatModel();
  }

  void _initializeChatModel() {
    _chatModel = ChatOpenAI(
      apiKey: apiKey,
      defaultOptions: const ChatOpenAIOptions(
        temperature: 0.7,
        maxTokens: 2000,
      ),
    );
  }

  @override
  Stream<String> sendMessage({
    required models.Agent agent,
    required String userMessage,
    required List<Message> conversationHistory,
  }) async* {
    if (_chatModel == null) {
      _initializeChatModel();
    }

    // Convert conversation history to LangChain format
    final messages = <ChatMessage>[];
    
    // Add system prompt if available
    if (agent.systemPrompt.isNotEmpty) {
      messages.add(ChatMessage.system(agent.systemPrompt));
    }

    // Add conversation history
    for (final msg in conversationHistory) {
      switch (msg.role) {
        case MessageRole.user:
          messages.add(ChatMessage.humanText(msg.content));
          break;
        case MessageRole.assistant:
          messages.add(ChatMessage.ai(msg.content));
          break;
        case MessageRole.system:
          messages.add(ChatMessage.system(msg.content));
          break;
      }
    }

    // Add current user message
    messages.add(ChatMessage.humanText(userMessage));

    // Create prompt value
    final prompt = ChatPromptValue(messages);

    // Stream the response
    try {
      final stream = _chatModel!.stream(prompt);
      await for (final chunk in stream) {
        if (chunk is ChatResult) {
          final message = chunk.output;
          if (message is AIChatMessage) {
            final content = message.content;
            // Content can be String or ChatMessageContent
            if (content is String) {
              yield content;
            } else {
              // Try to extract string from content
              yield content.toString();
            }
          }
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  @override
  Future<String> sendMessageComplete({
    required models.Agent agent,
    required String userMessage,
    required List<Message> conversationHistory,
  }) async {
    if (_chatModel == null) {
      _initializeChatModel();
    }

    // Convert conversation history to LangChain format
    final messages = <ChatMessage>[];
    
    // Add system prompt if available
    if (agent.systemPrompt.isNotEmpty) {
      messages.add(ChatMessage.system(agent.systemPrompt));
    }

    // Add conversation history
    for (final msg in conversationHistory) {
      switch (msg.role) {
        case MessageRole.user:
          messages.add(ChatMessage.humanText(msg.content));
          break;
        case MessageRole.assistant:
          messages.add(ChatMessage.ai(msg.content));
          break;
        case MessageRole.system:
          messages.add(ChatMessage.system(msg.content));
          break;
      }
    }

    // Add current user message
    messages.add(ChatMessage.humanText(userMessage));

    // Create prompt value
    final prompt = ChatPromptValue(messages);

    try {
      final response = await _chatModel!.invoke(prompt);
      if (response is ChatResult) {
        final message = response.output;
        if (message is AIChatMessage) {
          final content = message.content;
          // Content can be String or ChatMessageContent
          if (content is String) {
            return content;
          } else {
            // Try to extract string from content
            return content.toString();
          }
        }
      }
      return '';
    } catch (e) {
      return 'Error: $e';
    }
  }
}

