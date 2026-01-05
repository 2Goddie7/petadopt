import 'package:equatable/equatable.dart';

/// Entidad de Mensaje de Chat
class ChatMessage extends Equatable {
  final String id;
  final String userId;
  final ChatRole role;
  final String message;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.message,
    required this.createdAt,
  });

  /// Crea una copia con campos modificados
  ChatMessage copyWith({
    String? id,
    String? userId,
    ChatRole? role,
    String? message,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Verifica si el mensaje es del usuario
  bool get isUser => role == ChatRole.user;

  /// Verifica si el mensaje es del asistente (IA)
  bool get isAssistant => role == ChatRole.assistant;

  /// Verifica si el mensaje es del sistema
  bool get isSystem => role == ChatRole.system;

  /// Obtiene el tiempo transcurrido desde el mensaje
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Hace ${minutes}m';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Hace ${hours}h';
    } else {
      final days = difference.inDays;
      return 'Hace ${days}d';
    }
  }

  /// Formatea la hora del mensaje
  String get timeDisplay {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Verifica si el mensaje es reciente (menos de 1 minuto)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inSeconds < 60;
  }

  @override
  List<Object> get props => [id, userId, role, message, createdAt];

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...)';
  }
}

/// Enum del rol del mensaje
enum ChatRole {
  user,
  assistant,
  system;

  /// Convierte a String para JSON
  String toJson() {
    switch (this) {
      case ChatRole.user:
        return 'user';
      case ChatRole.assistant:
        return 'assistant';
      case ChatRole.system:
        return 'system';
    }
  }

  /// Crea desde String de JSON
  static ChatRole fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'user':
        return ChatRole.user;
      case 'assistant':
        return ChatRole.assistant;
      case 'system':
        return ChatRole.system;
      default:
        throw ArgumentError('Invalid ChatRole: $json');
    }
  }
}