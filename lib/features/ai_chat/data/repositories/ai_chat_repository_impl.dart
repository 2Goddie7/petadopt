import 'package:dartz/dartz.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/gemini_remote_data_source.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final GeminiRemoteDataSource remoteDataSource;

  AiChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(
    String userId,
    String message,
  ) async {
    try {
      final messageModel = await remoteDataSource.sendMessage(userId, message);
      return Right(messageModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String userId) async {
    try {
      final messageModels = await remoteDataSource.getChatHistory(userId);
      final messages = messageModels.map((m) => m.toEntity()).toList();
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory(String userId) async {
    try {
      await remoteDataSource.clearChatHistory(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}