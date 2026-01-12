import 'package:dartz/dartz.dart';
import '../entities/message_entity.dart';
import '../repositories/gemini_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Parámetros para SendMessageToGemini usecase
class SendMessageToGeminiParams {
  final String conversationId;
  final MessageEntity message;
  final List<MessageEntity>? history;
  final bool stream;

  SendMessageToGeminiParams({
    required this.conversationId,
    required this.message,
    this.history,
    this.stream = false,
  });
}

/// Usecase para enviar mensajes a Gemini
class SendMessageToGemini
    extends UseCaseWithParams<MessageEntity, SendMessageToGeminiParams> {
  final GeminiRepository repository;

  SendMessageToGemini(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(
      SendMessageToGeminiParams params) {
    return repository.sendMessage(
      params.conversationId,
      params.message,
      history: params.history,
      stream: params.stream,
    );
  }

  /// Método para obtener stream de mensajes
  Stream<Either<Failure, MessageEntity>> sendMessageStream(
    SendMessageToGeminiParams params,
  ) {
    return repository.sendMessageStream(
      params.conversationId,
      params.message,
      history: params.history,
    );
  }
}
