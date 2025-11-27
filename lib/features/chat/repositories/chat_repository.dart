import 'package:isar/isar.dart';
import 'package:ai_code_box/core/database/isar_service.dart';
import 'package:ai_code_box/features/chat/models/conversation.dart';
import 'package:ai_code_box/features/chat/models/message.dart';

class ChatRepository {
  final IsarService _isarService;

  ChatRepository(this._isarService);

  Future<Isar> get _db => _isarService.db;

  /// Gets all conversations in a space
  Future<List<Conversation>> getConversationsBySpace(int spaceId) async {
    final db = await _db;
    return await db.conversations
        .filter()
        .spaceIdEqualTo(spaceId)
        .sortByLastMessageAtDesc()
        .findAll();
  }

  /// Gets a conversation by ID
  Future<Conversation?> getConversationById(int id) async {
    final db = await _db;
    return await db.conversations.get(id);
  }

  /// Creates a new conversation
  Future<Conversation> createConversation({
    required int spaceId,
    required int agentId,
    required String title,
  }) async {
    final db = await _db;
    final conversation = Conversation()
      ..spaceId = spaceId
      ..agentId = agentId
      ..title = title
      ..createdAt = DateTime.now()
      ..lastMessageAt = DateTime.now();

    await db.writeTxn(() async {
      await db.conversations.put(conversation);
    });

    return conversation;
  }

  /// Gets all messages in a conversation
  Future<List<Message>> getMessagesByConversation(int conversationId) async {
    final db = await _db;
    return await db.messages
        .filter()
        .conversationIdEqualTo(conversationId)
        .sortByTimestamp()
        .findAll();
  }

  /// Adds a message to a conversation
  Future<Message> addMessage({
    required int conversationId,
    required MessageRole role,
    required String content,
  }) async {
    final db = await _db;
    final message = Message()
      ..conversationId = conversationId
      ..role = role
      ..content = content
      ..timestamp = DateTime.now();

    // Update conversation's lastMessageAt
    final conversation = await db.conversations.get(conversationId);
    if (conversation != null) {
      conversation.lastMessageAt = DateTime.now();
    }

    await db.writeTxn(() async {
      await db.messages.put(message);
      if (conversation != null) {
        await db.conversations.put(conversation);
      }
    });

    return message;
  }

  /// Updates a conversation
  Future<void> updateConversation(Conversation conversation) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.conversations.put(conversation);
    });
  }

  /// Deletes a conversation and all its messages
  Future<void> deleteConversation(int id) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.conversations.delete(id);
      await db.messages.filter().conversationIdEqualTo(id).deleteAll();
    });
  }
}

