import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/chat_mapper.dart';

class ChatRepositoryImpl implements IChatRepository {
  final AppDatabase _database;

  ChatRepositoryImpl(this._database);

  @override
  Stream<List<ChatSessionEntity>> watchAllChatSessions() {
    return _database.watchAllChatSessions().map(ChatMapper.toSessionDomainList);
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessagesBySession(int sessionId) {
    return _database
        .watchMessagesBySession(sessionId)
        .map(ChatMapper.toMessageDomainList);
  }

  @override
  Future<int> addChatSession(ChatSessionEntity session) async {
    final companion = ChatMapper.toSessionCompanion(session);
    return await _database.insertChatSession(companion);
  }

  @override
  Future<void> updateChatSession(ChatSessionEntity session) async {
    final companion = ChatMapper.toSessionCompanion(session);
    await _database.updateChatSession(companion);
  }

  @override
  Future<int> addMessage(ChatMessageEntity message) async {
    final companion = ChatMapper.toMessageCompanion(message);
    return await _database.insertChatMessage(companion);
  }

  @override
  Future<void> deleteChatSession(int id) async {
    await _database.softDeleteChatSession(id);
  }

  @override
  Future<void> deleteMessage(int id) async {
    await _database.softDeleteChatMessage(id);
  }
}
