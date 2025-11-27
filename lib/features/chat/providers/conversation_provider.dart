import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_code_box/core/database/isar_service.dart';
import 'package:ai_code_box/features/chat/models/conversation.dart';
import 'package:ai_code_box/features/chat/models/message.dart';
import 'package:ai_code_box/features/chat/repositories/chat_repository.dart';
import 'package:ai_code_box/features/spaces/providers/space_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return ChatRepository(isarService);
});

final spaceConversationsProvider = FutureProvider.family<List<Conversation>, int>((ref, spaceId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getConversationsBySpace(spaceId);
});

final conversationProvider = FutureProvider.family<Conversation?, int>((ref, conversationId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getConversationById(conversationId);
});

final conversationMessagesProvider = FutureProvider.family<List<Message>, int>((ref, conversationId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getMessagesByConversation(conversationId);
});

