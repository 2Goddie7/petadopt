import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/send_message_to_gemini.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/ai_chat_message.dart';

/// BLoC mejorado para chat con Gemini
class ChatIaBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageToGemini sendMessageToGemini;

  String? _currentConversationId;
  final List<MessageEntity> _messageHistory = [];

  ChatIaBloc({
    required this.sendMessageToGemini,
  }) : super(ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatHistoryEvent>(_onClearChatHistory);
    on<ResetChatEvent>(_onResetChat);
  }

  /// Carga el historial de chat
  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Generar ID de conversación basado en userId
    _currentConversationId =
        'conv_${event.userId}_${DateTime.now().millisecondsSinceEpoch}';
    _messageHistory.clear();

    emit(const ChatLoaded(messages: []));
  }

  /// Envía un mensaje a Gemini
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentConversationId == null) {
      emit(const ChatError(message: 'Conversación no iniciada'));
      return;
    }

    // Obtener mensajes actuales
    final currentMessages = _convertToLegacyMessages(_messageHistory);

    // Mostrar estado "enviando"
    emit(ChatSending(
      messages: currentMessages,
      pendingMessage: event.message,
    ));

    // Crear mensaje del usuario
    final userMessage = MessageEntity.user(
      id: const Uuid().v4(),
      content: event.message,
    );

    _messageHistory.add(userMessage);

    // Crear parámetros del usecase
    final params = SendMessageToGeminiParams(
      conversationId: _currentConversationId!,
      message: userMessage,
      history: _messageHistory.length > 1
          ? _messageHistory.sublist(0, _messageHistory.length - 1)
          : null,
      stream: false,
    );

    // Llamar al usecase
    final result = await sendMessageToGemini(params);

    result.fold(
      (failure) {
        // Error al enviar
        emit(ChatError(
          message: failure.message,
          previousMessages: currentMessages,
        ));
      },
      (aiResponse) {
        // Agregar respuesta del asistente
        _messageHistory.add(aiResponse);

        // Emitir estado actualizado
        emit(ChatLoaded(
          messages: _convertToLegacyMessages(_messageHistory),
        ));
      },
    );
  }

  /// Limpia el historial de chat
  Future<void> _onClearChatHistory(
    ClearChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    _messageHistory.clear();
    emit(const ChatLoaded(messages: []));
  }

  /// Reinicia el chat
  Future<void> _onResetChat(
    ResetChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    _currentConversationId = null;
    _messageHistory.clear();
    emit(ChatInitial());
  }

  /// Convierte MessageEntity a ChatMessage (para compatibilidad con UI)
  List<ChatMessage> _convertToLegacyMessages(List<MessageEntity> messages) {
    return messages.map((msg) {
      final role = msg.isUser ? ChatRole.user : ChatRole.assistant;
      return ChatMessage(
        id: msg.id,
        userId: _currentConversationId ?? '',
        role: role,
        message: msg.content,
        createdAt: msg.timestamp,
      );
    }).toList();
  }

  /// Obtiene el historial actual
  List<MessageEntity> get messageHistory => List.unmodifiable(_messageHistory);

  /// Obtiene el ID de conversación actual
  String? get currentConversationId => _currentConversationId;
}
