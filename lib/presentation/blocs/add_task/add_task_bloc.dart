// lib/presentation/blocs/add_task/add_task_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task_usecases.dart';

part 'add_task_event.dart';
part 'add_task_state.dart';

class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
  final CreateTaskUseCase _createTaskUseCase;

  AddTaskBloc({required CreateTaskUseCase createTaskUseCase})
      : _createTaskUseCase = createTaskUseCase,
        super( AddTaskState()) {
    on<AddTaskPriorityChanged>(_onPriorityChanged);
    on<AddTaskDueDateChanged>(_onDueDateChanged);
    on<AddTaskSubmitted>(_onSubmitted);
    on<AddTaskReset>(_onReset);
  }

  void _onPriorityChanged(
    AddTaskPriorityChanged event,
    Emitter<AddTaskState> emit,
  ) {
    emit(state.copyWith(selectedPriority: event.priority));
  }

  void _onDueDateChanged(
    AddTaskDueDateChanged event,
    Emitter<AddTaskState> emit,
  ) {
    emit(state.copyWith(selectedDueDate: event.dueDate));
  }

  Future<void> _onSubmitted(
    AddTaskSubmitted event,
    Emitter<AddTaskState> emit,
  ) async {
    emit(state.copyWith(status: AddTaskStatus.submitting, clearError: true));

    final result = await _createTaskUseCase(
      title: event.title,
      description: event.description,
      priority: state.selectedPriority,
      dueDate: state.selectedDueDate,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddTaskStatus.failure,
        errorMessage: failure.message,
      )),
      (task) => emit(state.copyWith(
        status: AddTaskStatus.success,
        createdTask: task,
        clearError: true,
      )),
    );
  }

  void _onReset(AddTaskReset event, Emitter<AddTaskState> emit) {
    emit( AddTaskState());
  }
}
