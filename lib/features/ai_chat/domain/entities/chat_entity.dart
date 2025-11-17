import 'package:equatable/equatable.dart';

class ChatSessionEntity extends Equatable {
  final int? id;
  final String title;
  final DateTime lastMessageTime;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ChatSessionEntity({
    this.id,
    required this.title,
    required this.lastMessageTime,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  ChatSessionEntity copyWith({
    int? id,
    String? title,
    DateTime? lastMessageTime,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ChatSessionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    lastMessageTime,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}

class ChatMessageEntity extends Equatable {
  final int? id;
  final int sessionId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? serverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ChatMessageEntity({
    this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.serverId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  ChatMessageEntity copyWith({
    int? id,
    int? sessionId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sessionId,
    content,
    isUser,
    timestamp,
    serverId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
