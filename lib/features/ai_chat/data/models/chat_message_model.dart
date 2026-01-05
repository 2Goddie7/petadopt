import '../../domain/entities/ai_chat_message.dart';

/// Modelo de Mensaje de Chat para la capa de datos
/// Extiende la entidad ChatMessage y agrega serialización JSON
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.message,
    required super.createdAt,
  });

  /// Crea un ChatMessageModel desde JSON (Supabase)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: ChatRole.fromJson(json['role'] as String),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el ChatMessageModel a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role.toJson(),
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crea un ChatMessageModel desde una entidad ChatMessage
  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      userId: message.userId,
      role: message.role,
      message: message.message,
      createdAt: message.createdAt,
    );
  }

  /// Convierte el ChatMessageModel a una entidad ChatMessage
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      userId: userId,
      role: role,
      message: message,
      createdAt: createdAt,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  ChatMessageModel copyWith({
    String? id,
    String? userId,
    ChatRole? role,
    String? message,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Crea un ChatMessageModel vacío/inicial
  factory ChatMessageModel.empty() {
    return ChatMessageModel(
      id: '',
      userId: '',
      role: ChatRole.user,
      message: '',
      createdAt: DateTime.now(),
    );
  }

  /// Crea un ChatMessageModel para creación (sin ID)
  Map<String, dynamic> toJsonForCreation() {
    return {
      'user_id': userId,
      'role': role.toJson(),
      'message': message,
    };
  }

  /// Crea un ChatMessageModel desde Gemini API response
  factory ChatMessageModel.fromGeminiResponse({
    required String userId,
    required String responseText,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      role: ChatRole.assistant,
      message: responseText,
      createdAt: DateTime.now(),
    );
  }

  /// Crea un ChatMessageModel de usuario
  factory ChatMessageModel.user({
    required String userId,
    required String message,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      role: ChatRole.user,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  /// Crea un ChatMessageModel de sistema
  factory ChatMessageModel.system({
    required String userId,
    required String message,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      role: ChatRole.system,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  /// Convierte a formato para Gemini API
  Map<String, dynamic> toGeminiFormat() {
    return {
      'role': role == ChatRole.user ? 'user' : 'model',
      'parts': [
        {'text': message}
      ],
    };
  }

  /// Crea lista de mensajes en formato Gemini
  static List<Map<String, dynamic>> toGeminiHistory(
      List<ChatMessageModel> messages) {
    return messages
        .where((msg) => msg.role != ChatRole.system)
        .map((msg) => msg.toGeminiFormat())
        .toList();
  }
}