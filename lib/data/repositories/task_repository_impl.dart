// lib/data/repositories/task_repository_impl.dart

import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Concrete implementation of [TaskRepository].
/// Responsibilities:
///   1. Delegate to the remote data source
///   2. Convert exceptions → failures (domain-safe errors)
///   3. Map data models → domain entities
///   4. Merge remote data with any locally-created tasks (session-scoped)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;
  final _uuid = const Uuid();

  /// Session cache — holds locally created tasks so they survive screen
  /// navigation without a full re-fetch from the API.
  final List<TaskEntity> _localTasks = [];

  /// Tracks status overrides for remote tasks patched this session.
  final Map<String, TaskStatus> _statusOverrides = {};

  TaskRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final models = await _remote.getTasks();
      final remoteTasks = models.map((m) {
        final entity = m.toDomain();
        // Apply any in-session status overrides
        final override = _statusOverrides[entity.id];
        return override != null ? entity.copyWith(status: override) : entity;
      }).toList();

      // Merge: local (session-created) tasks first, then remote
      final all = [..._localTasks, ...remoteTasks];
      return Right(all);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ParseException catch (e) {
      return Left(ParseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    // Check if it's a locally-created task
    final localIndex = _localTasks.indexWhere((t) => t.id == taskId);
    if (localIndex != -1) {
      final updated = _localTasks[localIndex].copyWith(status: newStatus);
      _localTasks[localIndex] = updated;
      return Right(updated);
    }

    // Otherwise it's a remote task — call the API
    try {
      final taskIdInt = int.tryParse(taskId);
      if (taskIdInt == null) {
        return const Left(ValidationFailure(message: 'Invalid task ID.'));
      }

      await _remote.updateTaskStatus(
        taskId: taskIdInt,
        completed: newStatus == TaskStatus.completed,
      );

      // JSONPlaceholder always returns the same object shape regardless of status
      // so we apply our own status logic and cache the override for the session.
      _statusOverrides[taskId] = newStatus;

      // Re-fetch to build the updated entity
      final allResult = await getTasks();
      return allResult.fold(
        (failure) => Left(failure),
        (tasks) {
          final updated = tasks.firstWhere(
            (t) => t.id == taskId,
            orElse: () => throw const NotFoundException(),
          );
          return Right(updated);
        },
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      // POST to JSONPlaceholder (simulated — returns id 201 always)
      await _remote.createTask(taskData: {
        'title': title,
        'body': description,
        'completed': false,
        'userId': 1,
      });

      // Build a proper local entity with a real UUID
      final newTask = TaskEntity(
        id: _uuid.v4(),
        title: title,
        description: description,
        status: TaskStatus.pending,
        priority: priority,
        assignedDate: DateTime.now(),
        dueDate: dueDate,
        assignedTo: 'Current Agent',
      );

      _localTasks.insert(0, newTask);
      return Right(newTask);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}


