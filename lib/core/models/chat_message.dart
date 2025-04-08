import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    String? id,
    required this.text,
    this.isUser = false,
    DateTime? createdAt,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      createdAt: this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
    );
  }

  // Convert to flutter_chat_types Message for chat UI
  chat_types.TextMessage toChatUIMessage() {
    final author = chat_types.User(
      id: isUser ? 'user' : 'assistant',
      firstName: isUser ? 'You' : 'Ell-ena',
    );

    return chat_types.TextMessage(
      author: author,
      createdAt: createdAt.millisecondsSinceEpoch,
      id: id,
      text: text,
      metadata: metadata,
    );
  }
}