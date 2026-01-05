import 'package:equatable/equatable.dart';

/// Entidad de Mensaje de Chat en el dominio
/// Representa un mensaje en la conversación con la IA (Gemini)
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

  /// Crea una copia del mensaje con campos modificados
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
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Hace ${minutes}m';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Hace ${hours}h';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Hace ${days}d';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Obtiene la hora del mensaje en formato legible
  String get timeDisplay {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Verifica si el mensaje es reciente (menos de 1 minuto)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inMinutes < 1;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        role,
        message,
        createdAt,
      ];

  @override
  bool get stringify => true;
}

/// Rol del mensaje en el chat
enum ChatRole {
  user,
  assistant,
  system;

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

  static ChatRole fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'user':
      case 'usuario':
        return ChatRole.user;
      case 'assistant':
      case 'asistente':
      case 'ai':
        return ChatRole.assistant;
      case 'system':
      case 'sistema':
        return ChatRole.system;
      default:
        throw ArgumentError('Invalid chat role: $value');
    }
  }

  String get displayName {
    switch (this) {
      case ChatRole.user:
        return 'Usuario';
      case ChatRole.assistant:
        return 'Asistente';
      case ChatRole.system:
        return 'Sistema';
    }
  }
}