// lib/presentation/blocs/task_list/task_list_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task_usecases.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final GetTasksUseCase _getTasksUseCase;

  TaskListBloc({required GetTasksUseCase getTasksUseCase})
      : _getTasksUseCase = getTasksUseCase,
        super(const TaskListState()) {
    on<TaskListFetched>(_onFetched);
    on<TaskListFilterChanged>(_onFilterChanged);
    on<TaskListTaskUpdated>(_onTaskUpdated);
    on<TaskListTaskCreated>(_onTaskCreated);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onFetched(
    TaskListFetched event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(status: TaskListStatus.loading, clearError: true));

    final result = await _getTasksUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskListStatus.failure,
        errorMessage: failure.message,
      )),
      (tasks) {
        final filtered = _applyFilter(tasks, state.activeFilter);
        emit(state.copyWith(
          status: TaskListStatus.success,
          allTasks: tasks,
          filteredTasks: filtered,
          clearError: true,
        ));
      },
    );
  }

  void _onFilterChanged(
    TaskListFilterChanged event,
    Emitter<TaskListState> emit,
  ) {
    final filtered = _applyFilter(state.allTasks, event.filter);
    emit(state.copyWith(
      activeFilter: event.filter,
      clearFilter: event.filter == null,
      filteredTasks: filtered,
    ));
  }

  void _onTaskUpdated(
    TaskListTaskUpdated event,
    Emitter<TaskListState> emit,
  ) {
    // Replace the old task with the updated one in allTasks
    final updated = state.allTasks.map((t) {
      return t.id == event.updatedTask.id ? event.updatedTask : t;
    }).toList();

    final filtered = _applyFilter(updated, state.activeFilter);
    emit(state.copyWith(allTasks: updated, filteredTasks: filtered));
  }

  void _onTaskCreated(
    TaskListTaskCreated event,
    Emitter<TaskListState> emit,
  ) {
    final updated = [event.newTask, ...state.allTasks];
    final filtered = _applyFilter(updated, state.activeFilter);
    emit(state.copyWith(allTasks: updated, filteredTasks: filtered));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<TaskEntity> _applyFilter(List<TaskEntity> tasks, TaskStatus? filter) {
    if (filter == null) return tasks;
    return tasks.where((t) => t.status == filter).toList();
  }
}
