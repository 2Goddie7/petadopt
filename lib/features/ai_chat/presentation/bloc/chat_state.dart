import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatSending extends ChatState {
  final List<ChatMessage> messages;
  final String pendingMessage;

  const ChatSending({
    required this.messages,
    required this.pendingMessage,
  });

  @override
  List<Object?> get props => [messages, pendingMessage];
}

class MessageSent extends ChatState {
  final List<ChatMessage> messages;

  const MessageSent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  final List<ChatMessage>? previousMessages;

  const ChatError({
    required this.message,
    this.previousMessages,
  });

  @override
  List<Object?> get props => [message, previousMessages];
}
