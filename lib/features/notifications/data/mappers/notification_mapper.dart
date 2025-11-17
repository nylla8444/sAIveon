import 'package:drift/drift.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../core/database/app_database.dart' as db;

class NotificationMapper {
  static NotificationEntity toDomain(db.Notification notification) {
    return NotificationEntity(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      timestamp: notification.timestamp,
      isRead: notification.isRead,
      type: notification.type,
      serverId: notification.serverId,
      createdAt: notification.createdAt,
      updatedAt: notification.updatedAt,
      isDeleted: notification.isDeleted,
    );
  }

  static db.NotificationsCompanion toCompanion(NotificationEntity entity) {
    return db.NotificationsCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      title: Value(entity.title),
      message: Value(entity.message),
      timestamp: Value(entity.timestamp),
      isRead: Value(entity.isRead),
      type: Value(entity.type),
      serverId: Value(entity.serverId),
      createdAt: entity.createdAt != null
          ? Value(entity.createdAt!)
          : Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: Value(entity.isDeleted),
    );
  }

  static List<NotificationEntity> toDomainList(
    List<db.Notification> notifications,
  ) {
    return notifications.map((n) => toDomain(n)).toList();
  }
}
