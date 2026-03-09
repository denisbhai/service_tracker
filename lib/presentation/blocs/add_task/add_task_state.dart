// lib/presentation/blocs/add_task/add_task_state.dart

part of 'add_task_bloc.dart';

enum AddTaskStatus { idle, submitting, success, failure }

class AddTaskState extends Equatable {
  final AddTaskStatus status;
  final TaskPriority selectedPriority;
  final DateTime selectedDueDate;
  final TaskEntity? createdTask;
  final String? errorMessage;

  AddTaskState({
    this.status = AddTaskStatus.idle,
    this.selectedPriority = TaskPriority.medium,
    DateTime? selectedDueDate,
    this.createdTask,
    this.errorMessage,
  }) : selectedDueDate =
            selectedDueDate ?? DateTime.now().add(const Duration(days: 3));

  AddTaskState copyWith({
    AddTaskStatus? status,
    TaskPriority? selectedPriority,
    DateTime? selectedDueDate,
    TaskEntity? createdTask,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddTaskState(
      status: status ?? this.status,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedDueDate: selectedDueDate ?? this.selectedDueDate,
      createdTask: createdTask ?? this.createdTask,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, selectedPriority, selectedDueDate, createdTask, errorMessage];
}
