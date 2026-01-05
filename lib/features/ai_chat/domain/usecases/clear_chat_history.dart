import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/ai_chat_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Limpia el historial de chat del usuario
class ClearChatHistory extends UseCaseWithParams<void, ClearChatHistoryParams> {
  final AiChatRepository repository;

  ClearChatHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(ClearChatHistoryParams params) async {
    return await repository.clearChatHistory(params.userId);
  }
}

class ClearChatHistoryParams extends Equatable {
  final String userId;

  const ClearChatHistoryParams({required this.userId});

  @override
  List<Object> get props => [userId];
}