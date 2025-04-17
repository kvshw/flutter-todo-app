import 'package:get/get.dart';

/// Represents a single task in the todo list
class Task {
  /// Unique identifier for the task
  final String id;

  /// Title of the task
  final String title;

  /// Optional description of the task
  final String description;

  /// Whether the task is completed
  final bool isCompleted;

  /// When the task was created
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    // Validate title is not empty
    if (title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }
  }

  /// Creates a new task with a generated ID and current timestamp
  factory Task.create({
    required String title,
    String description = '',
  }) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
    );
  }

  /// Creates a Task instance from a JSON map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Converts the Task instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  /// Creates a copy of the task with optional property changes
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, completed: $isCompleted)';
}
