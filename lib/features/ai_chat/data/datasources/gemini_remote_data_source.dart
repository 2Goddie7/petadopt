import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/ai_chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> sendMessage(String userId, String message);
  Future<List<ChatMessageModel>> getChatHistory(String userId);
  Future<void> saveChatMessage(ChatMessageModel message);
  Future<void> clearChatHistory(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabase;
  late final gemini.GenerativeModel geminiModel;

  ChatRemoteDataSourceImpl({required this.supabase}) {
    geminiModel = gemini.GenerativeModel(
      model: 'gemini-pro',
      apiKey: ApiConstants.geminiApiKey,
    );
  }

  @override
  Future<ChatMessageModel> sendMessage(String userId, String message) async {
    try {
      // Guardar mensaje del usuario
      final userMessage = ChatMessageModel.user(userId: userId, message: message);
      await saveChatMessage(userMessage);

      // Obtener historial para contexto
      final history = await getChatHistory(userId);
      
      // Crear chat con contexto
      final chat = geminiModel.startChat(
        history: history.map((msg) => gemini.Content(
          msg.role == ChatRole.user ? 'user' : 'model',
          [gemini.TextPart(msg.message)],
        )).toList(),
      );

      // Enviar mensaje a Gemini
      final response = await chat.sendMessage(gemini.Content.text(message));
      
      if (response.text == null || response.text!.isEmpty) {
        throw const ServerException('No se recibió respuesta de la IA');
      }

      // Crear y guardar respuesta del asistente
      final aiMessage = ChatMessageModel.fromGeminiResponse(
        userId: userId,
        responseText: response.text!,
      );
      await saveChatMessage(aiMessage);

      return aiMessage;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al comunicarse con la IA: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(String userId) async {
    try {
      final response = await supabase
          .from('chat_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .limit(ApiConstants.maxChatHistory);

      return (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    }
  }

  @override
  Future<void> saveChatMessage(ChatMessageModel message) async {
    try {
      await supabase
          .from('chat_history')
          .insert(message.toJsonForCreation());
    } on PostgrestException catch (e) {
      // No lanzar error si falla guardar en BD
      print('Error saving chat message: ${e.message}');
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      await supabase
          .from('chat_history')
          .delete()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    }
  }
}