import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Servicio de notificaciones locales con Supabase Realtime
class LocalNotificationService {
  final NotificationRepository repository;
  final FlutterLocalNotificationsPlugin _plugin;
  StreamSubscription<AppNotification>? _subscription;
  bool _isListening = false;

  LocalNotificationService({
    required this.repository,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio
  Future<void> initialize() async {
    // Inicializar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

    // Pedir permiso en Android 13+
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    // Configuración Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    debugPrint('✅ LocalNotificationService inicializado');
  }

  /// Inicia escucha de notificaciones para el usuario
  void startListening(String userId) {
    if (_isListening) {
      stopListening();
    }

    _subscription = repository.listenToNotifications(userId).listen(
      (notification) {
        _showNotification(notification);
      },
      onError: (error) {
        debugPrint('❌ Error en stream: $error');
      },
    );

    _isListening = true;
    debugPrint('🔔 Escuchando notificaciones para: $userId');
  }

  /// Detiene la escucha
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    debugPrint('🛑 Escucha detenida');
  }

  /// Muestra notificación local
  Future<void> _showNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'petadopt_channel',
      'PetAdopt Notificaciones',
      channelDescription: 'Notificaciones de adopción',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      notification.id.hashCode,
      notification.title,
      notification.message,
      details,
    );

    debugPrint('✅ Notificación mostrada: ${notification.message}');
  }

  /// Limpia recursos
  void dispose() {
    stopListening();
    repository.dispose();
  }

  bool get isListening => _isListening;
}
