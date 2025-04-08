import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<String> tags;

  Project({
    String? id,
    required this.name,
    this.description = '',
    DateTime? createdAt,
    this.tags = const [],
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? name,
    String? description,
    List<String>? tags,
  }) {
    return Project(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags']),
    );
  }
}