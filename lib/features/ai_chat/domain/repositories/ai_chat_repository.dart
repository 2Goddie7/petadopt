import 'package:dartz/dartz.dart';
import '../entities/ai_chat_message.dart';
import '../../../../core/error/failures.dart';

/// Contrato del repositorio de chat con IA
abstract class AiChatRepository {
  /// Envía un mensaje y obtiene la respuesta de la IA
  Future<Either<Failure, ChatMessage>> sendMessage(
    String userId,
    String message,
  );

  /// Obtiene el historial de chat del usuario
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String userId);

  /// Limpia el historial de chat del usuario
  Future<Either<Failure, void>> clearChatHistory(String userId);
}