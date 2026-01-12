import 'package:dartz/dartz.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/gemini_repository.dart';
import '../datasources/gemini_data_source.dart';
import '../models/message_model.dart' as model;
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

/// Implementación del repositorio Gemini
class GeminiRepositoryImpl implements GeminiRepository {
  final GeminiDataSource remoteDataSource;

  GeminiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    MessageEntity input, {
    List<MessageEntity>? history,
    bool stream = false,
  }) async {
    try {
      // Convertir entidades a modelos
      final inputModel = _entityToModel(input);
      final historyModels = history?.map(_entityToModel).toList();

      // Llamar a la datasource
      final messageModel = await remoteDataSource.sendMessage(
        conversationId,
        inputModel,
        history: historyModels,
        stream: stream,
      );

      // Convertir modelo a entidad
      return Right(_modelToEntity(messageModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, MessageEntity>> sendMessageStream(
    String conversationId,
    MessageEntity input, {
    List<MessageEntity>? history,
  }) async* {
    try {
      // Convertir entidades a modelos
      final inputModel = _entityToModel(input);
      final historyModels = history?.map(_entityToModel).toList();

      // Llamar a la datasource en stream
      final stream = remoteDataSource.sendMessageStream(
        conversationId,
        inputModel,
        history: historyModels,
      );

      // Emitir cada fragmento convertido a entidad
      await for (final messageModel in stream) {
        yield Right(_modelToEntity(messageModel));
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message, e.code));
    } catch (e) {
      yield Left(UnknownFailure(e.toString()));
    }
  }

  @override
  void clearConversationContext(String conversationId) {
    remoteDataSource.clearConversationContext(conversationId);
  }

  @override
  void clearAllContexts() {
    remoteDataSource.clearAllContexts();
  }

  /// Convierte MessageEntity a MessageModel
  model.MessageModel _entityToModel(MessageEntity entity) {
    final role = entity.role == MessageRole.user
        ? model.MessageRole.user
        : model.MessageRole.assistant;
    return model.MessageModel(
      id: entity.id,
      role: role,
      content: entity.content,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
    );
  }

  /// Convierte MessageModel a MessageEntity
  MessageEntity _modelToEntity(model.MessageModel m) {
    final role = m.role == model.MessageRole.user
        ? MessageRole.user
        : MessageRole.assistant;
    return MessageEntity(
      id: m.id,
      role: role,
      content: m.content,
      timestamp: m.timestamp,
      metadata: m.metadata,
    );
  }
}
