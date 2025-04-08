import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/constants/colors.dart';
import 'package:ellena/core/constants/text_styles.dart';
import 'package:ellena/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ellena/features/chat/presentation/bloc/chat_event.dart';
import 'package:ellena/features/chat/presentation/bloc/chat_state.dart';
import 'package:ellena/features/chat/presentation/widgets/chat_input.dart';
import 'package:ellena/features/chat/presentation/widgets/message_bubble.dart';
import 'package:ellena/features/tasks/presentation/pages/task_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return BlocProvider(
      create: (context) => ChatBloc()..add(LoadChatHistory()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Chat with Ell-ena',
                style: AppTextStyles.titleLarge,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearChatConfirmation(context),
                ),
              ],
            ),
            body: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  _scrollToBottom();
                }
                
                if (state is TaskCreatedFromChat) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "${state.task.title}" created'),
                      action: SnackBarAction(
                        label: 'View',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailPage(taskId: state.task.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatInitial || state is ChatLoading && !(state is ChatLoaded)) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is ChatError && !(state is ChatLoaded)) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(LoadChatHistory());
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is ChatLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.messages.length + (state.isAiProcessing ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.messages.length && state.isAiProcessing) {
                              // Show typing indicator at the end if AI is processing
                              return const _TypingIndicator();
                            }
                            
                            final message = state.messages[index];
                            return MessageBubble(
                              message: message,
                              onTaskTap: message.metadata != null && message.metadata!.containsKey('taskId')
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TaskDetailPage(
                                          taskId: message.metadata!['taskId'],
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            );
                          },
                        ),
                      ),
                      ChatInput(
                        onSend: (message) {
                          context.read<ChatBloc>().add(SendMessage(message));
                        },
                        isLoading: state.isAiProcessing,
                      ),
                    ],
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  void _showClearChatConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ChatBloc>().add(ClearChatHistory());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8, right: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}