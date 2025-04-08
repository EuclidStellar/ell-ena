import 'package:equatable/equatable.dart';
import 'package:ellena/core/models/chat_message.dart';
import 'package:ellena/core/models/task.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isAiProcessing;
  
  const ChatLoaded({
    required this.messages,
    this.isAiProcessing = false,
  });
  
  @override
  List<Object?> get props => [messages, isAiProcessing];
  
  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isAiProcessing,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isAiProcessing: isAiProcessing ?? this.isAiProcessing,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  
  const ChatError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class TaskCreatedFromChat extends ChatState {
  final Task task;
  
  const TaskCreatedFromChat({required this.task});
  
  @override
  List<Object> get props => [task];
}