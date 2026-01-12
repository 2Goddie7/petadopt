import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification.dart';

/// DataSource para notificaciones con Supabase Realtime
class NotificationDataSource {
  final SupabaseClient supabase;
  RealtimeChannel? _channel;

  NotificationDataSource(this.supabase);

  /// Escucha notificaciones en tiempo real
  Stream<AppNotification> listenToNotifications(String userId) {
    final controller = StreamController<AppNotification>.broadcast();

    _channel = supabase.channel('notifications:$userId');

    _channel!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        try {
          final notification = AppNotification.fromJson(payload.newRecord);
          debugPrint('📬 Notificación recibida: ${notification.message}');
          controller.add(notification);
        } catch (e) {
          debugPrint('❌ Error parseando notificación: $e');
        }
      },
    )
        .subscribe((status, [error]) {
      debugPrint('🔔 Realtime status: $status');
    });

    controller.onCancel = () {
      _channel?.unsubscribe();
    };

    return controller.stream;
  }

  /// Marca notificación como leída
  Future<void> markAsRead(String notificationId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  /// Cierra el canal
  void dispose() {
    _channel?.unsubscribe();
  }
}
