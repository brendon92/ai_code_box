import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../providers/conversation_provider.dart';
import '../repositories/chat_repository.dart';
import '../../agents/providers/agent_provider.dart';
import '../../agents/models/agent.dart';
import '../../ai/services/ai_service.dart';
import '../../ai/services/openai_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _streamingResponse;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationProvider(widget.conversationId));
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.conversationId));

    return conversationAsync.when(
      data: (conversation) {
        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Błąd')),
            body: const Center(child: Text('Konwersacja nie została znaleziona')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(conversation.title),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: messagesAsync.when(
            data: (messages) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (_streamingResponse != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && _streamingResponse != null) {
                          // Show streaming response
                          return _buildMessageBubble(
                            MessageRole.assistant,
                            _streamingResponse!,
                            isStreaming: true,
                          );
                        }
                        final message = messages[index];
                        return _buildMessageBubble(message.role, message.content);
                      },
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Napisz wiadomość...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(conversation),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _isLoading
                              ? null
                              : () => _sendMessage(conversation),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Błąd: $error'),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ładowanie...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Błąd')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageRole role, String content, {bool isStreaming = false}) {
    final isUser = role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (isStreaming)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(Conversation conversation) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _controller.clear();
    });

    try {
      // Add user message to database
      final chatRepository = ref.read(chatRepositoryProvider);
      await chatRepository.addMessage(
        conversationId: widget.conversationId,
        role: MessageRole.user,
        content: text,
      );

      // Get agent
      final agentAsync = await ref.read(agentProvider(conversation.agentId).future);
      if (agentAsync == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agent nie został znaleziony')),
          );
        }
        return;
      }

      // Get conversation history
      final messages = await chatRepository.getMessagesByConversation(widget.conversationId);

      // TODO: Get API key from secure storage
      // For now, using a placeholder - this should come from user settings
      const apiKey = 'YOUR_API_KEY_HERE'; // TODO: Get from secure storage

      if (apiKey == 'YOUR_API_KEY_HERE') {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Skonfiguruj klucz API w ustawieniach'),
            ),
          );
        }
        return;
      }

      // Initialize AI service
      final aiService = OpenAIService(apiKey: apiKey);

      // Stream response
      setState(() {
        _streamingResponse = '';
      });

      String fullResponse = '';
      await for (final chunk in aiService.sendMessage(
        agent: agentAsync,
        userMessage: text,
        conversationHistory: messages,
      )) {
        setState(() {
          _streamingResponse = fullResponse += chunk;
        });
        _scrollToBottom();
      }

      // Save assistant message to database
      await chatRepository.addMessage(
        conversationId: widget.conversationId,
        role: MessageRole.assistant,
        content: fullResponse,
      );

      // Refresh messages
      ref.invalidate(conversationMessagesProvider(widget.conversationId));

      setState(() {
        _isLoading = false;
        _streamingResponse = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _streamingResponse = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    }
  }
}

