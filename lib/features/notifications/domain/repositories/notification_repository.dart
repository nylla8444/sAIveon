import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  /// Watch all notifications as a stream
  Stream<List<NotificationEntity>> watchAllNotifications();

  /// Add a new notification
  Future<int> addNotification(NotificationEntity notification);

  /// Mark notification as read
  Future<void> markAsRead(int id);

  /// Delete a notification (soft delete)
  Future<void> deleteNotification(int id);
}
