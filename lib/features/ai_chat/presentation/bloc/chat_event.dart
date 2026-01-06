import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar historial de chat
class LoadChatHistoryEvent extends ChatEvent {
  final String userId;

  const LoadChatHistoryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Enviar mensaje al chat de IA (Gemini)
class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Limpiar historial de chat
class ClearChatHistoryEvent extends ChatEvent {
  const ClearChatHistoryEvent();
}

/// Reiniciar chat a estado inicial
class ResetChatEvent extends ChatEvent {
  const ResetChatEvent();
}
