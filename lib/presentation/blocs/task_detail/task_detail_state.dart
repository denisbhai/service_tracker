// lib/presentation/blocs/task_detail/task_detail_state.dart

part of 'task_detail_bloc.dart';

enum TaskDetailStatus { initial, loaded, updating, updateSuccess, updateFailure }

class TaskDetailState extends Equatable {
  final TaskDetailStatus status;
  final TaskEntity? task;
  final String? errorMessage;

  const TaskDetailState({
    this.status = TaskDetailStatus.initial,
    this.task,
    this.errorMessage,
  });

  TaskDetailState copyWith({
    TaskDetailStatus? status,
    TaskEntity? task,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, task, errorMessage];
}
