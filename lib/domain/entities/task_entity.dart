// lib/domain/entities/task_entity.dart

import 'package:equatable/equatable.dart';

/// Pure domain entity — no JSON, no Flutter, no Dio.
/// This is what the BLoCs and use cases work with.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String? assignedTo;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedDate,
    required this.dueDate,
    this.assignedTo,
  });

  bool get isOverdue =>
      status != TaskStatus.completed &&
      DateTime.now().isAfter(dueDate);

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? assignedDate,
    DateTime? dueDate,
    String? assignedTo,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedDate: assignedDate ?? this.assignedDate,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, status, priority, assignedDate, dueDate, assignedTo];
}

enum TaskStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed');

  final String label;
  const TaskStatus(this.label);

  static TaskStatus fromLabel(String label) {
    return TaskStatus.values.firstWhere(
      (s) => s.label == label,
      orElse: () => TaskStatus.pending,
    );
  }

  /// Returns the next logical status in the workflow
  TaskStatus get next {
    switch (this) {
      case TaskStatus.pending:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.completed;
      case TaskStatus.completed:
        return TaskStatus.completed;
    }
  }

  bool get isTerminal => this == TaskStatus.completed;
}

enum TaskPriority {
  low('Low', 0),
  medium('Medium', 1),
  high('High', 2),
  critical('Critical', 3);

  final String label;
  final int level;
  const TaskPriority(this.label, this.level);

  static TaskPriority fromLabel(String label) {
    return TaskPriority.values.firstWhere(
      (p) => p.label.toLowerCase() == label.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}
