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

/// Modelo de Mensaje para la capa de datos
/// Contiene: id, role (user/assistant), content, timestamp, metadata
class MessageModel extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const MessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  /// Crea un MessageModel desde JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convierte el MessageModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Crea un MessageModel de usuario
  factory MessageModel.user({
    required String id,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id,
      role: MessageRole.user,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Crea un MessageModel del asistente
  factory MessageModel.assistant({
    required String id,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id,
      role: MessageRole.assistant,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Crea una copia del modelo con campos modificados
  MessageModel copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, metadata];
}
