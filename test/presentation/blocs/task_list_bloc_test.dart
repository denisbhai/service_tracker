// test/presentation/blocs/task_list_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:field_service_tracker/core/errors/failures.dart';
import 'package:field_service_tracker/domain/entities/task_entity.dart';
import 'package:field_service_tracker/domain/repositories/task_repository.dart';
import 'package:field_service_tracker/domain/usecases/task_usecases.dart';
import 'package:field_service_tracker/presentation/blocs/task_list/task_list_bloc.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}

// ── Helpers ───────────────────────────────────────────────────────────────────

TaskEntity _makeTask(String id, TaskStatus status) => TaskEntity(
      id: id,
      title: 'Task $id',
      description: 'Description for $id',
      status: status,
      priority: TaskPriority.medium,
      assignedDate: DateTime(2024, 1, 1),
      dueDate: DateTime(2024, 12, 31),
      assignedTo: 'Agent 1',
    );

void main() {
  late MockGetTasksUseCase mockGetTasksUseCase;

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
  });

  group('TaskListBloc', () {
    // ── TaskListFetched ──────────────────────────────────────────────────────

    blocTest<TaskListBloc, TaskListState>(
      'emits [loading, success] when fetch succeeds',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer(
          (_) async => Right([
            _makeTask('1', TaskStatus.pending),
            _makeTask('2', TaskStatus.inProgress),
          ]),
        );
        return TaskListBloc(getTasksUseCase: mockGetTasksUseCase);
      },
      act: (bloc) => bloc.add(const TaskListFetched()),
      expect: () => [
        const TaskListState(status: TaskListStatus.loading),
        isA<TaskListState>()
            .having((s) => s.status, 'status', TaskListStatus.success)
            .having((s) => s.allTasks.length, 'tasks count', 2)
            .having((s) => s.filteredTasks.length, 'filtered count', 2),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'emits [loading, failure] when fetch fails',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer(
          (_) async =>
              const Left(NetworkFailure(message: 'No internet connection.')),
        );
        return TaskListBloc(getTasksUseCase: mockGetTasksUseCase);
      },
      act: (bloc) => bloc.add(const TaskListFetched()),
      expect: () => [
        const TaskListState(status: TaskListStatus.loading),
        isA<TaskListState>()
            .having((s) => s.status, 'status', TaskListStatus.failure)
            .having((s) => s.errorMessage, 'error',
                'No internet connection.'),
      ],
    );

    // ── TaskListFilterChanged ────────────────────────────────────────────────

    blocTest<TaskListBloc, TaskListState>(
      'filters tasks correctly when filter is set',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer(
          (_) async => Right([
            _makeTask('1', TaskStatus.pending),
            _makeTask('2', TaskStatus.inProgress),
            _makeTask('3', TaskStatus.completed),
          ]),
        );
        return TaskListBloc(getTasksUseCase: mockGetTasksUseCase);
      },
      act: (bloc) async {
        bloc.add(const TaskListFetched());
        await Future.delayed(Duration.zero);
        bloc.add(const TaskListFilterChanged(TaskStatus.pending));
      },
      skip: 2, // skip loading + success from fetch
      expect: () => [
        isA<TaskListState>()
            .having((s) => s.activeFilter, 'filter', TaskStatus.pending)
            .having((s) => s.filteredTasks.length, 'filtered count', 1),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'clears filter when null is passed',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer(
          (_) async => Right([
            _makeTask('1', TaskStatus.pending),
            _makeTask('2', TaskStatus.completed),
          ]),
        );
        return TaskListBloc(getTasksUseCase: mockGetTasksUseCase);
      },
      act: (bloc) async {
        bloc.add(const TaskListFetched());
        await Future.delayed(Duration.zero);
        bloc.add(const TaskListFilterChanged(TaskStatus.pending));
        bloc.add(const TaskListFilterChanged(null));
      },
      skip: 3,
      expect: () => [
        isA<TaskListState>()
            .having((s) => s.activeFilter, 'filter', null)
            .having((s) => s.filteredTasks.length, 'filtered count', 2),
      ],
    );

    // ── TaskListTaskUpdated ──────────────────────────────────────────────────

    blocTest<TaskListBloc, TaskListState>(
      'updates task in list when TaskListTaskUpdated is added',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer(
          (_) async => Right([
            _makeTask('1', TaskStatus.pending),
          ]),
        );
        return TaskListBloc(getTasksUseCase: mockGetTasksUseCase);
      },
      act: (bloc) async {
        bloc.add(const TaskListFetched());
        await Future.delayed(Duration.zero);
        bloc.add(
          TaskListTaskUpdated(_makeTask('1', TaskStatus.inProgress)),
        );
      },
      skip: 2,
      expect: () => [
        isA<TaskListState>().having(
          (s) => s.allTasks.first.status,
          'updated status',
          TaskStatus.inProgress,
        ),
      ],
    );

    // ── TaskListTaskCreated ──────────────────────────────────────────────────

    blocTest<TaskListBloc, TaskListState>(
      'prepends new task when TaskListTaskCreated is added',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer(
          (_) async => Right([_makeTask('1', TaskStatus.pending)]),
        );
        return TaskListBloc(getTasksUseCase: mockGetTasksUseCase);
      },
      act: (bloc) async {
        bloc.add(const TaskListFetched());
        await Future.delayed(Duration.zero);
        bloc.add(TaskListTaskCreated(_makeTask('new', TaskStatus.pending)));
      },
      skip: 2,
      expect: () => [
        isA<TaskListState>()
            .having((s) => s.allTasks.length, 'count', 2)
            .having((s) => s.allTasks.first.id, 'first task id', 'new'),
      ],
    );
  });
}
