import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;
  
  const SendMessage(this.message);
  
  @override
  List<Object> get props => [message];
}

class ProcessAiResponse extends ChatEvent {
  final String userMessage;
  
  const ProcessAiResponse(this.userMessage);
  
  @override
  List<Object> get props => [userMessage];
}

class ClearChatHistory extends ChatEvent {}