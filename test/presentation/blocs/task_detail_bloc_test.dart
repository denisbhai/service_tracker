// test/presentation/blocs/task_detail_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:field_service_tracker/core/errors/failures.dart';
import 'package:field_service_tracker/domain/entities/task_entity.dart';
import 'package:field_service_tracker/domain/repositories/task_repository.dart';
import 'package:field_service_tracker/domain/usecases/task_usecases.dart';
import 'package:field_service_tracker/presentation/blocs/task_detail/task_detail_bloc.dart';

class MockUpdateTaskStatusUseCase extends Mock
    implements UpdateTaskStatusUseCase {}

TaskEntity _task(TaskStatus status) => TaskEntity(
      id: '42',
      title: 'Inspect Generator',
      description: 'Monthly inspection of backup generator.',
      status: status,
      priority: TaskPriority.high,
      assignedDate: DateTime(2024, 1, 1),
      dueDate: DateTime(2024, 12, 31),
    );

void main() {
  late MockUpdateTaskStatusUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(TaskStatus.pending);
  });

  setUp(() {
    mockUseCase = MockUpdateTaskStatusUseCase();
  });

  group('TaskDetailBloc', () {
    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits loaded state on TaskDetailLoaded',
      build: () =>
          TaskDetailBloc(updateTaskStatusUseCase: mockUseCase),
      act: (bloc) => bloc.add(TaskDetailLoaded(_task(TaskStatus.pending))),
      expect: () => [
        isA<TaskDetailState>()
            .having((s) => s.status, 'status', TaskDetailStatus.loaded)
            .having((s) => s.task?.id, 'task id', '42'),
      ],
    );

    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits updating → updateSuccess on successful status update',
      build: () {
        when(() => mockUseCase(
              taskId: any(named: 'taskId'),
              newStatus: any(named: 'newStatus'),
            )).thenAnswer(
          (_) async => Right(_task(TaskStatus.inProgress)),
        );
        return TaskDetailBloc(updateTaskStatusUseCase: mockUseCase);
      },
      act: (bloc) async {
        bloc.add(TaskDetailLoaded(_task(TaskStatus.pending)));
        await Future.delayed(Duration.zero);
        bloc.add(const TaskDetailStatusUpdateRequested(
          taskId: '42',
          newStatus: TaskStatus.inProgress,
        ));
      },
      skip: 1,
      expect: () => [
        isA<TaskDetailState>()
            .having((s) => s.status, 'status', TaskDetailStatus.updating),
        isA<TaskDetailState>()
            .having((s) => s.status, 'status', TaskDetailStatus.updateSuccess)
            .having((s) => s.task?.status, 'updated status',
                TaskStatus.inProgress),
      ],
    );

    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits updating → updateFailure on error',
      build: () {
        when(() => mockUseCase(
              taskId: any(named: 'taskId'),
              newStatus: any(named: 'newStatus'),
            )).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Server unavailable.')),
        );
        return TaskDetailBloc(updateTaskStatusUseCase: mockUseCase);
      },
      act: (bloc) async {
        bloc.add(TaskDetailLoaded(_task(TaskStatus.pending)));
        await Future.delayed(Duration.zero);
        bloc.add(const TaskDetailStatusUpdateRequested(
          taskId: '42',
          newStatus: TaskStatus.inProgress,
        ));
      },
      skip: 1,
      expect: () => [
        isA<TaskDetailState>()
            .having((s) => s.status, 'status', TaskDetailStatus.updating),
        isA<TaskDetailState>()
            .having(
                (s) => s.status, 'status', TaskDetailStatus.updateFailure)
            .having(
                (s) => s.errorMessage, 'error', 'Server unavailable.'),
      ],
    );
  });
}
