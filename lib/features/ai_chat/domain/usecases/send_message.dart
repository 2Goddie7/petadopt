import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/ai_chat_message.dart';
import '../repositories/ai_chat_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Envía un mensaje al chat de IA
class SendMessage extends UseCaseWithParams<ChatMessage, SendMessageParams> {
  final AiChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) async {
    return await repository.sendMessage(params.userId, params.message);
  }
}

class SendMessageParams extends Equatable {
  final String userId;
  final String message;

  const SendMessageParams({
    required this.userId,
    required this.message,
  });

  @override
  List<Object> get props => [userId, message];
}