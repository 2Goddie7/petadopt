import 'package:equatable/equatable.dart';

/// Enum para los roles de los mensajes
enum MessageRole {
  user,
  assistant;

  String toJson() => name;

  factory MessageRole.fromJson(String json) {
    return MessageRole.values.firstWhere(
      (role) => role.name == json,
      orElse: () => MessageRole.user,
    );
  }
}

/// Entidad de Mensaje para la capa de dominio
/// Contiene: id, role (user/assistant), content, timestamp, metadata
class MessageEntity extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const MessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  /// Crea un MessageEntity de usuario
  factory MessageEntity.user({
    required String id,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageEntity(
      id: id,
      role: MessageRole.user,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Crea un MessageEntity del asistente
  factory MessageEntity.assistant({
    required String id,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageEntity(
      id: id,
      role: MessageRole.assistant,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Crea una copia del mensaje con campos modificados
  MessageEntity copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica si el mensaje es del usuario
  bool get isUser => role == MessageRole.user;

  /// Verifica si el mensaje es del asistente
  bool get isAssistant => role == MessageRole.assistant;

  /// Obtiene el tiempo transcurrido desde el mensaje
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, metadata];

  @override
  String toString() {
    final preview =
        content.length > 50 ? '${content.substring(0, 50)}...' : content;
    return 'MessageEntity(id: $id, role: $role, content: $preview)';
  }
}
