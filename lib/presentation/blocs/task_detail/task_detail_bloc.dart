// lib/presentation/blocs/task_detail/task_detail_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task_usecases.dart';

part 'task_detail_event.dart';
part 'task_detail_state.dart';

class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final UpdateTaskStatusUseCase _updateTaskStatusUseCase;

  TaskDetailBloc({required UpdateTaskStatusUseCase updateTaskStatusUseCase})
      : _updateTaskStatusUseCase = updateTaskStatusUseCase,
        super(const TaskDetailState()) {
    on<TaskDetailLoaded>(_onLoaded);
    on<TaskDetailStatusUpdateRequested>(_onStatusUpdateRequested);
  }

  void _onLoaded(TaskDetailLoaded event, Emitter<TaskDetailState> emit) {
    emit(state.copyWith(
      status: TaskDetailStatus.loaded,
      task: event.task,
    ));
  }

  Future<void> _onStatusUpdateRequested(
    TaskDetailStatusUpdateRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(status: TaskDetailStatus.updating));

    final result = await _updateTaskStatusUseCase(
      taskId: event.taskId,
      newStatus: event.newStatus,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskDetailStatus.updateFailure,
        errorMessage: failure.message,
      )),
      (updatedTask) => emit(state.copyWith(
        status: TaskDetailStatus.updateSuccess,
        task: updatedTask,
        clearError: true,
      )),
    );
  }
}
