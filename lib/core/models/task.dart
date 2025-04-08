import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';


enum TaskType { todo, ticket, meetingNote }

enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isDone;
  final List<String> tags;
  final String? projectId;
  final List<String> relatedTaskIds;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.type,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.dueDate,
    this.isDone = false,
    this.tags = const [],
    this.projectId,
    this.relatedTaskIds = const [],
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    TaskType? type,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isDone,
    List<String>? tags,
    String? projectId,
    List<String>? relatedTaskIds,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isDone': isDone,
      'tags': tags,
      'projectId': projectId,
      'relatedTaskIds': relatedTaskIds,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TaskType.values[json['type']],
      priority: TaskPriority.values[json['priority']],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isDone: json['isDone'],
      tags: List<String>.from(json['tags']),
      projectId: json['projectId'],
      relatedTaskIds: List<String>.from(json['relatedTaskIds']),
    );
  }
  
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
  
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    return DateFormat('MMM dd, yyyy').format(dueDate!);
  }
  
  String get typeLabel {
    switch (type) {
      case TaskType.todo:
        return 'To-Do';
      case TaskType.ticket:
        return 'Ticket';
      case TaskType.meetingNote:
        return 'Meeting Note';
    }
  }
}