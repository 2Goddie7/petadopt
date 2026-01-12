import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_ia_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatHistory() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      // Usar ChatIaBloc si está disponible, sino usar ChatBloc
      final hasChatIaBloc = _getChatIaBloc() != null;
      if (hasChatIaBloc) {
        _getChatIaBloc()!.add(
          LoadChatHistoryEvent(userId: authState.user.id),
        );
      } else {
        context.read<ChatBloc>().add(
              LoadChatHistoryEvent(userId: authState.user.id),
            );
      }
    }
  }

  ChatIaBloc? _getChatIaBloc() {
    try {
      return context.read<ChatIaBloc>();
    } catch (e) {
      return null;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasChatIaBloc = _getChatIaBloc() != null;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy),
            SizedBox(width: 8),
            Text('Chat con IA'),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    _showClearHistoryDialog();
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Limpiar historial'),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Acerca de'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: hasChatIaBloc ? _buildWithChatIaBloc() : _buildWithChatBloc(),
    );
  }

  // Construir UI con ChatIaBloc
  Widget _buildWithChatIaBloc() {
    return BlocConsumer<ChatIaBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is ChatLoaded || state is ChatSending) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatInitial) {
          return _buildWelcomeScreen();
        }

        if (state is ChatLoaded ||
            state is ChatSending ||
            (state is ChatError && state.previousMessages != null)) {
          final messages = state is ChatLoaded
              ? state.messages
              : state is ChatSending
                  ? state.messages
                  : (state as ChatError).previousMessages!;

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(message: messages[index]);
                        },
                      ),
              ),
              if (state is ChatSending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'IA está escribiendo...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ChatInputField(
                onSend: (message) {
                  context.read<ChatIaBloc>().add(
                        SendMessageEvent(message: message),
                      );
                },
                enabled: state is! ChatSending,
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  // Construir UI con ChatBloc (fallback)
  Widget _buildWithChatBloc() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is ChatLoaded || state is ChatSending) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatInitial) {
          return _buildWelcomeScreen();
        }

        if (state is ChatLoaded ||
            state is ChatSending ||
            (state is ChatError && state.previousMessages != null)) {
          final messages = state is ChatLoaded
              ? state.messages
              : state is ChatSending
                  ? state.messages
                  : (state as ChatError).previousMessages!;

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(message: messages[index]);
                        },
                      ),
              ),
              if (state is ChatSending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'IA está escribiendo...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ChatInputField(
                onSend: (message) {
                  context.read<ChatBloc>().add(
                        SendMessageEvent(message: message),
                      );
                },
                enabled: state is! ChatSending,
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy,
              size: 100,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Bienvenido al Chat con IA!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Pregúntame sobre cuidado de mascotas, adopción, alimentación y más.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadChatHistory,
              icon: const Icon(Icons.chat),
              label: const Text('Iniciar Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // Usamos Builder para tener acceso seguro al contexto del tema o definimos colores directamente
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¿En qué puedo ayudarte hoy?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '¡Hola! Soy tu asistente virtual de adopción.\nPregúntame sobre cuidados, razas o consejos para tu nueva mascota.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    final hasChatIaBloc = _getChatIaBloc() != null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar Historial'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todo el historial del chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (hasChatIaBloc) {
                _getChatIaBloc()!.add(const ClearChatHistoryEvent());
              } else {
                context.read<ChatBloc>().add(const ClearChatHistoryEvent());
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
