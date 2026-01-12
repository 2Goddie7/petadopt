import '../../data/datasources/notification_datasource.dart';
import '../entities/notification.dart';

/// Repository para notificaciones
class NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepository(this.dataSource);

  /// Escucha notificaciones en tiempo real
  Stream<AppNotification> listenToNotifications(String userId) {
    return dataSource.listenToNotifications(userId);
  }

  /// Marca como leída
  Future<void> markAsRead(String notificationId) {
    return dataSource.markAsRead(notificationId);
  }

  /// Dispose
  void dispose() {
    dataSource.dispose();
  }
}
