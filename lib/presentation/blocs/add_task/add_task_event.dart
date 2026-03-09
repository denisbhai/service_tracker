// lib/presentation/blocs/add_task/add_task_event.dart

part of 'add_task_bloc.dart';

abstract class AddTaskEvent extends Equatable {
  const AddTaskEvent();

  @override
  List<Object?> get props => [];
}

class AddTaskPriorityChanged extends AddTaskEvent {
  final TaskPriority priority;
  const AddTaskPriorityChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

class AddTaskDueDateChanged extends AddTaskEvent {
  final DateTime dueDate;
  const AddTaskDueDateChanged(this.dueDate);

  @override
  List<Object?> get props => [dueDate];
}

class AddTaskSubmitted extends AddTaskEvent {
  final String title;
  final String description;

  const AddTaskSubmitted({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}

class AddTaskReset extends AddTaskEvent {
  const AddTaskReset();
}
