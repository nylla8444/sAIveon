import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/database/app_database.dart';
import '../mappers/notification_mapper.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final AppDatabase _database;

  NotificationRepositoryImpl(this._database);

  @override
  Stream<List<NotificationEntity>> watchAllNotifications() {
    return _database.watchAllNotifications().map(
      NotificationMapper.toDomainList,
    );
  }

  @override
  Future<int> addNotification(NotificationEntity notification) async {
    final companion = NotificationMapper.toCompanion(notification);
    return await _database.insertNotification(companion);
  }

  @override
  Future<void> markAsRead(int id) async {
    await _database.markNotificationAsRead(id);
  }

  @override
  Future<void> deleteNotification(int id) async {
    await _database.softDeleteNotification(id);
  }
}
