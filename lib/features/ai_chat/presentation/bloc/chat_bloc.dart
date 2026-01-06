import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/clear_chat_history.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage sendMessage;
  final GetChatHistory getChatHistory;
  final ClearChatHistory clearChatHistory;
  
  String? _currentUserId;

  ChatBloc({
    required this.sendMessage,
    required this.getChatHistory,
    required this.clearChatHistory,
  }) : super(ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatHistoryEvent>(_onClearChatHistory);
    on<ResetChatEvent>(_onResetChat);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    _currentUserId = event.userId;
    
    final result = await getChatHistory(
      GetChatHistoryParams(userId: event.userId),
    );
    
    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(ChatLoaded(messages: messages)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentUserId == null) {
      emit(const ChatError(message: 'Usuario no identificado'));
      return;
    }

    // Obtener mensajes actuales
    final currentState = state;
    final List<ChatMessage> currentMessages = currentState is ChatLoaded
        ? currentState.messages
        : currentState is ChatSending
            ? currentState.messages
            : [];

    emit(ChatSending(
      messages: currentMessages,
      pendingMessage: event.message,
    ));
    
    final result = await sendMessage(
      SendMessageParams(
        userId: _currentUserId!,
        message: event.message,
      ),
    );
    
    result.fold(
      (failure) => emit(ChatError(
        message: failure.message,
        previousMessages: currentMessages,
      )),
      (aiResponse) {
        // El repositorio devuelve la respuesta de la IA
        // Recargar historial completo para obtener ambos mensajes
        add(LoadChatHistoryEvent(userId: _currentUserId!));
      },
    );
  }

  Future<void> _onClearChatHistory(
    ClearChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentUserId == null) {
      emit(const ChatError(message: 'Usuario no identificado'));
      return;
    }

    emit(ChatLoading());
    
    final result = await clearChatHistory(
      ClearChatHistoryParams(userId: _currentUserId!),
    );
    
    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(const ChatLoaded(messages: [])),
    );
  }

  Future<void> _onResetChat(
    ResetChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    _currentUserId = null;
    emit(ChatInitial());
  }
}
