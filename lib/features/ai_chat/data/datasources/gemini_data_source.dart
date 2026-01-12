import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../../../../core/error/exceptions.dart';

/// Interfaz para la datasource de Gemini
abstract class GeminiDataSource {
  /// Envía un mensaje a Gemini
  /// Si [stream] es true, retorna un Stream de fragmentos de respuesta
  /// Si [stream] es false, retorna un Future de la respuesta completa
  Future<MessageModel> sendMessage(
    String conversationId,
    MessageModel input, {
    List<MessageModel>? history,
    bool stream = false,
  });

  /// Stream de respuestas de Gemini (cuando stream=true)
  Stream<MessageModel> sendMessageStream(
    String conversationId,
    MessageModel input, {
    List<MessageModel>? history,
  });

  /// Obtiene el historial de una conversación específica
  List<MessageModel>? getConversationContext(String conversationId);

  /// Limpia el contexto de una conversación
  void clearConversationContext(String conversationId);

  /// Limpia todos los contextos
  void clearAllContexts();
}

/// Implementación de GeminiDataSource
class GeminiDataSourceImpl implements GeminiDataSource {
  late final gemini.GenerativeModel _geminiModel;
  final Map<String, List<MessageModel>> _conversationContexts = {};

  GeminiDataSourceImpl() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const ServerException(
        'GEMINI_API_KEY no está configurada en .env',
      );
    }

    _geminiModel = gemini.GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
    );
  }

  @override
  Future<MessageModel> sendMessage(
    String conversationId,
    MessageModel input, {
    List<MessageModel>? history,
    bool stream = false,
  }) async {
    try {
      // Si no hay stream, obtener la respuesta completa
      if (!stream) {
        return await _sendMessageNonStream(
          conversationId,
          input,
          history: history,
        );
      }

      // Si hay stream, retornar el resultado final después de emitir el stream
      return await _sendMessageNonStream(
        conversationId,
        input,
        history: history,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al comunicarse con Gemini: $e');
    }
  }

  @override
  Stream<MessageModel> sendMessageStream(
    String conversationId,
    MessageModel input, {
    List<MessageModel>? history,
  }) async* {
    try {
      // Reconstituir el contexto de la conversación
      final conversationHistory = history ?? [];
      _conversationContexts[conversationId] = conversationHistory;

      // Convertir histórico a formato de Gemini
      final geminiHistory = _convertToGeminiContent(conversationHistory);

      // Crear chat con historial
      final chat = _geminiModel.startChat(history: geminiHistory);

      // Emitir el mensaje del usuario como fragmento inicial
      yield input;

      // Enviar mensaje a Gemini en stream
      final response = await chat.sendMessageStream(
        gemini.Content.text(input.content),
      );

      // Acumular respuesta completa
      final StringBuffer fullContent = StringBuffer();

      // Emitir cada fragmento
      await for (final chunk in response) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          fullContent.write(chunk.text);

          // Emitir fragmento como MessageModel
          yield MessageModel.assistant(
            id: const Uuid().v4(),
            content: fullContent.toString(),
            metadata: {'isIncomplete': true, 'conversationId': conversationId},
          );
        }
      }

      // Emitir respuesta final completa
      final finalMessage = MessageModel.assistant(
        id: const Uuid().v4(),
        content: fullContent.toString(),
        metadata: {'isIncomplete': false, 'conversationId': conversationId},
      );

      yield finalMessage;

      // Guardar en contexto de conversación
      final updatedHistory = [...conversationHistory, input, finalMessage];
      _conversationContexts[conversationId] = updatedHistory;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error en stream con Gemini: $e');
    }
  }

  /// Envía mensaje sin stream
  Future<MessageModel> _sendMessageNonStream(
    String conversationId,
    MessageModel input, {
    List<MessageModel>? history,
  }) async {
    // Reconstituir el contexto de la conversación
    final conversationHistory = history ?? [];
    _conversationContexts[conversationId] = conversationHistory;

    // Convertir histórico a formato de Gemini
    final geminiHistory = _convertToGeminiContent(conversationHistory);

    // Crear chat con historial
    final chat = _geminiModel.startChat(history: geminiHistory);

    // Enviar mensaje a Gemini
    final response = await chat.sendMessage(
      gemini.Content.text(input.content),
    );

    if (response.text == null || response.text!.isEmpty) {
      throw const ServerException('No se recibió respuesta de Gemini');
    }

    // Crear mensaje de respuesta
    final aiMessage = MessageModel.assistant(
      id: const Uuid().v4(),
      content: response.text!,
      metadata: {'conversationId': conversationId},
    );

    // Guardar en contexto de conversación
    final updatedHistory = [...conversationHistory, input, aiMessage];
    _conversationContexts[conversationId] = updatedHistory;

    return aiMessage;
  }

  /// Convierte MessageModels a contenido de Gemini
  List<gemini.Content> _convertToGeminiContent(List<MessageModel> messages) {
    return messages.map((msg) {
      final role = msg.role == MessageRole.user ? 'user' : 'model';
      return gemini.Content(role, [gemini.TextPart(msg.content)]);
    }).toList();
  }

  @override
  List<MessageModel>? getConversationContext(String conversationId) {
    return _conversationContexts[conversationId];
  }

  @override
  void clearConversationContext(String conversationId) {
    _conversationContexts.remove(conversationId);
  }

  @override
  void clearAllContexts() {
    _conversationContexts.clear();
  }
}
