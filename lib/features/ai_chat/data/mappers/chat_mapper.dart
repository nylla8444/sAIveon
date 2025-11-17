import 'package:drift/drift.dart';
import '../../domain/entities/chat_entity.dart';
import '../../../../core/database/app_database.dart';

class ChatMapper {
  static ChatSessionEntity toSessionDomain(ChatSession session) {
    return ChatSessionEntity(
      id: session.id,
      title: session.title,
      lastMessageTime: session.lastMessageTime,
      serverId: session.serverId,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      isDeleted: session.isDeleted,
    );
  }

  static ChatSessionsCompanion toSessionCompanion(ChatSessionEntity entity) {
    return ChatSessionsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      title: Value(entity.title),
      lastMessageTime: Value(entity.lastMessageTime),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<ChatSessionEntity> toSessionDomainList(
    List<ChatSession> sessions,
  ) {
    return sessions.map((s) => toSessionDomain(s)).toList();
  }

  static ChatMessageEntity toMessageDomain(ChatMessage message) {
    return ChatMessageEntity(
      id: message.id,
      sessionId: message.sessionId,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
      serverId: message.serverId,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      isDeleted: message.isDeleted,
    );
  }

  static ChatMessagesCompanion toMessageCompanion(ChatMessageEntity entity) {
    return ChatMessagesCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      sessionId: Value(entity.sessionId),
      content: Value(entity.content),
      isUser: Value(entity.isUser),
      timestamp: Value(entity.timestamp),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<ChatMessageEntity> toMessageDomainList(
    List<ChatMessage> messages,
  ) {
    return messages.map((m) => toMessageDomain(m)).toList();
  }
}
