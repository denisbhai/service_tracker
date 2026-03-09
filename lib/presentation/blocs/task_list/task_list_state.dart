// lib/presentation/blocs/task_list/task_list_state.dart

part of 'task_list_bloc.dart';

enum TaskListStatus { initial, loading, success, failure }

class TaskListState extends Equatable {
  final TaskListStatus status;
  final List<TaskEntity> allTasks;    // Full unfiltered list
  final List<TaskEntity> filteredTasks; // What the UI renders
  final TaskStatus? activeFilter;      // null = show all
  final String? errorMessage;

  const TaskListState({
    this.status = TaskListStatus.initial,
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.activeFilter,
    this.errorMessage,
  });

  TaskListState copyWith({
    TaskListStatus? status,
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskStatus? activeFilter,
    bool clearFilter = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskListState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, allTasks, filteredTasks, activeFilter, errorMessage];
}
