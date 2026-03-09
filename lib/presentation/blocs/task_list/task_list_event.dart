// lib/presentation/blocs/task_list/task_list_event.dart

part of 'task_list_bloc.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial/refresh task fetch
class TaskListFetched extends TaskListEvent {
  const TaskListFetched();
}

/// User changed the status filter chip
class TaskListFilterChanged extends TaskListEvent {
  final TaskStatus? filter; // null = All

  const TaskListFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// A task was updated from the detail screen — propagate to list state
class TaskListTaskUpdated extends TaskListEvent {
  final TaskEntity updatedTask;

  const TaskListTaskUpdated(this.updatedTask);

  @override
  List<Object?> get props => [updatedTask];
}

/// A new task was created from the add screen — prepend to list
class TaskListTaskCreated extends TaskListEvent {
  final TaskEntity newTask;

  const TaskListTaskCreated(this.newTask);

  @override
  List<Object?> get props => [newTask];
}
