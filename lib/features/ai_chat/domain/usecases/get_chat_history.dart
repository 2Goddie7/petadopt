import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/ai_chat_message.dart';
import '../repositories/ai_chat_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Obtiene el historial de chat del usuario
class GetChatHistory extends UseCaseWithParams<List<ChatMessage>, GetChatHistoryParams> {
  final AiChatRepository repository;

  GetChatHistory(this.repository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(GetChatHistoryParams params) async {
    return await repository.getChatHistory(params.userId);
  }
}

class GetChatHistoryParams extends Equatable {
  final String userId;

  const GetChatHistoryParams({required this.userId});

  @override
  List<Object> get props => [userId];
}