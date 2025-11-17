import '../entities/chat_entity.dart';

abstract class IChatRepository {
  /// Watch all chat sessions as a stream
  Stream<List<ChatSessionEntity>> watchAllChatSessions();

  /// Watch messages for a specific session
  Stream<List<ChatMessageEntity>> watchMessagesBySession(int sessionId);

  /// Add a new chat session
  Future<int> addChatSession(ChatSessionEntity session);

  /// Update chat session
  Future<void> updateChatSession(ChatSessionEntity session);

  /// Add a message to a session
  Future<int> addMessage(ChatMessageEntity message);

  /// Delete a chat session (soft delete)
  Future<void> deleteChatSession(int id);

  /// Delete a message (soft delete)
  Future<void> deleteMessage(int id);
}
