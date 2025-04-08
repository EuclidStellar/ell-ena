import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/di/injection_container.dart';
import 'package:ellena/core/models/chat_message.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/services/ai_service.dart';
import 'package:ellena/core/services/local_storage_service.dart';
import 'package:ellena/core/services/task_service.dart';
import 'package:ellena/core/utils/logger.dart';
import 'package:ellena/features/chat/presentation/bloc/chat_event.dart';
import 'package:ellena/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LocalStorageService _storageService = sl<LocalStorageService>();
  final AIService _aiService = sl<AIService>();
  final TaskService _taskService = sl<TaskService>();
  final AppLogger _logger = AppLogger();
  
  ChatBloc() : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ProcessAiResponse>(_onProcessAiResponse);
    on<ClearChatHistory>(_onClearChatHistory);
  }
  
  Future<void> _onLoadChatHistory(LoadChatHistory event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = _storageService.getMessages();
      
      if (messages.isEmpty) {
        // Add initial assistant message if no chat history
        final initialMessage = ChatMessage(
          text: "Hi! I'm Ell-ena, your AI product manager assistant. How can I help you today?",
          isUser: false,
        );
        
        await _storageService.addMessage(initialMessage);
        emit(ChatLoaded(messages: [initialMessage]));
      } else {
        emit(ChatLoaded(messages: messages));
      }
    } catch (e) {
      _logger.error('Error loading chat history: $e');
      emit(ChatError(message: 'Failed to load chat history'));
    }
  }
  
  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        
        // Create and add user message
        final userMessage = ChatMessage(
          text: event.message,
          isUser: true,
        );
        
        await _storageService.addMessage(userMessage);
        
        // Update state to show user message and AI processing indicator
        final updatedMessages = [...currentState.messages, userMessage];
        emit(currentState.copyWith(
          messages: updatedMessages,
          isAiProcessing: true,
        ));
        
        // Process the message with AI
        add(ProcessAiResponse(event.message));
      }
    } catch (e) {
      _logger.error('Error sending message: $e');
      emit(ChatError(message: 'Failed to send message'));
    }
  }
  
  Future<void> _onProcessAiResponse(ProcessAiResponse event, Emitter<ChatState> emit) async {
    try {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        
        // Format messages for AI service
        final history = _formatChatHistoryForAi(currentState.messages.take(10).toList());
        
        // Get AI response
        final aiResponseText = await _aiService.getAIResponse(event.userMessage, history);
        
        // Create and save assistant message
        final assistantMessage = ChatMessage(
          text: aiResponseText,
          isUser: false,
        );
        
        await _storageService.addMessage(assistantMessage);
        
        // Check if this is a task creation request
        final task = await _aiService.extractTaskFromMessage(event.userMessage);
        
        if (task != null) {
          // Save the extracted task
          await _taskService.addTask(task);
          
          // Create a confirmation message
          final confirmationMessage = ChatMessage(
            text: "✅ I've created a task based on your request:\n\n**${task.title}**\n\nYou can find it in your tasks list.",
            isUser: false,
            metadata: {'taskId': task.id},
          );
          
          await _storageService.addMessage(confirmationMessage);
          
          // Update state with both messages
          final updatedMessages = [
            ...currentState.messages,
            assistantMessage,
            confirmationMessage,
          ];
          
          emit(currentState.copyWith(
            messages: updatedMessages,
            isAiProcessing: false,
          ));
          
          // Notify about task creation
          emit(TaskCreatedFromChat(task: task));
          
          // Return to chat state
          emit(currentState.copyWith(
            messages: updatedMessages,
            isAiProcessing: false,
          ));
        } else {
          // Just update with the assistant response
          final updatedMessages = [
            ...currentState.messages,
            assistantMessage,
          ];
          
          emit(currentState.copyWith(
            messages: updatedMessages,
            isAiProcessing: false,
          ));
        }
      }
    } catch (e) {
      _logger.error('Error processing AI response: $e');
      
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        
        // Create error message
        final errorMessage = ChatMessage(
          text: "Sorry, I encountered an error processing your request. Please try again.",
          isUser: false,
        );
        
        await _storageService.addMessage(errorMessage);
        
        // Update state with error message
        final updatedMessages = [...currentState.messages, errorMessage];
        emit(currentState.copyWith(
          messages: updatedMessages,
          isAiProcessing: false,
        ));
      } else {
        emit(ChatError(message: 'Failed to process AI response'));
      }
    }
  }
  
  Future<void> _onClearChatHistory(ClearChatHistory event, Emitter<ChatState> emit) async {
    try {
      final messages = _storageService.getMessages();
      
      // Clear all messages except the initial one
      if (messages.isNotEmpty) {
        final initialMessage = messages.first;
        await _storageService.saveMessages([initialMessage]);
        emit(ChatLoaded(messages: [initialMessage]));
      }
    } catch (e) {
      _logger.error('Error clearing chat history: $e');
      emit(ChatError(message: 'Failed to clear chat history'));
    }
  }
  
  List<Map<String, String>> _formatChatHistoryForAi(List<ChatMessage> messages) {
    return messages.map((message) {
      return {
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      };
    }).toList();
  }
}