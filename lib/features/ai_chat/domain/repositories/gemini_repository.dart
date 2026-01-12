import 'package:dartz/dartz.dart';
import '../entities/message_entity.dart';
import '../../../../core/error/failures.dart';

/// Contrato del repositorio de Gemini
abstract class GeminiRepository {
  /// Envía un mensaje a Gemini
  /// [conversationId] - ID único de la conversación
  /// [input] - Mensaje de entrada del usuario
  /// [history] - Historial de mensajes para contexto
  /// [stream] - Si true, retorna Stream de fragmentos
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    MessageEntity input, {
    List<MessageEntity>? history,
    bool stream = false,
  });

  /// Stream de respuestas de Gemini
  /// Emite fragmentos de la respuesta conforme se reciben
  Stream<Either<Failure, MessageEntity>> sendMessageStream(
    String conversationId,
    MessageEntity input, {
    List<MessageEntity>? history,
  });

  /// Limpia el contexto de una conversación
  void clearConversationContext(String conversationId);

  /// Limpia todos los contextos
  void clearAllContexts();
}
