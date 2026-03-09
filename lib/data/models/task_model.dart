// lib/data/models/task_model.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

/// Data Transfer Object — maps between JSON and domain entities.
/// Kept separate from [TaskEntity] so that API schema changes
/// don't bleed into the domain layer.
class TaskModel extends Equatable {
  final int id;
  final String title;
  final String body;
  final bool completed;
  final int userId;

  const TaskModel({
    required this.id,
    required this.title,
    required this.body,
    required this.completed,
    required this.userId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int? ?? 0,
      // JSONPlaceholder todos use 'title' — body falls back to a generated description
      title: json['title'] as String? ?? 'Untitled Task',
      body: json['body'] as String? ?? _generateDescription(json['id'] as int? ?? 0),
      completed: json['completed'] as bool? ?? false,
      userId: json['userId'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'completed': completed,
        'userId': userId,
      };

  /// Converts this DTO into a domain entity.
  /// Priority is derived from id to produce variety in mock data.
  TaskEntity toDomain() {
    final priority = _derivePriority(id);
    final status = completed ? TaskStatus.completed : _deriveStatus(id);
    final now = DateTime.now();

    return TaskEntity(
      id: id.toString(),
      title: _capitalise(title),
      description: body.isNotEmpty ? body : _generateDescription(id),
      status: status,
      priority: priority,
      assignedDate: now.subtract(Duration(days: id % 14)),
      dueDate: now.add(Duration(days: (id % 7) + 1)),
      assignedTo: 'Agent ${((userId - 1) % 5) + 1}',
    );
  }

  static TaskPriority _derivePriority(int id) {
    final v = id % 4;
    if (v == 0) return TaskPriority.critical;
    if (v == 1) return TaskPriority.high;
    if (v == 2) return TaskPriority.medium;
    return TaskPriority.low;
  }

  static TaskStatus _deriveStatus(int id) {
    final v = id % 3;
    if (v == 0) return TaskStatus.pending;
    if (v == 1) return TaskStatus.inProgress;
    return TaskStatus.pending;
  }

  static String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String _generateDescription(int id) {
    const descriptions = [
      'Inspect and document the on-site equipment condition.',
      'Perform routine maintenance and log findings.',
      'Verify installation and run diagnostics.',
      'Conduct site survey and submit report.',
      'Address reported fault and validate resolution.',
    ];
    return descriptions[id % descriptions.length];
  }

  @override
  List<Object?> get props => [id, title, body, completed, userId];
}
