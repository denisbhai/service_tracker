// lib/presentation/blocs/task_detail/task_detail_event.dart

part of 'task_detail_bloc.dart';

abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the detail screen with a task
class TaskDetailLoaded extends TaskDetailEvent {
  final TaskEntity task;

  const TaskDetailLoaded(this.task);

  @override
  List<Object?> get props => [task];
}

/// User tapped the status update button
class TaskDetailStatusUpdateRequested extends TaskDetailEvent {
  final String taskId;
  final TaskStatus newStatus;

  const TaskDetailStatusUpdateRequested({
    required this.taskId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [taskId, newStatus];
}
