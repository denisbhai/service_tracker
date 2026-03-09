// lib/domain/repositories/task_repository.dart

import '../entities/task_entity.dart';
import '../../core/errors/failures.dart';

/// Abstract contract for the task repository.
/// The domain layer depends on this interface — never on the concrete implementation.
/// This inversion allows easy swapping of data sources (real API, mock, offline cache).
abstract class TaskRepository {
  /// Fetches all tasks from the remote data source.
  /// Returns a [Failure] on error — never throws.
  Future<Either<Failure, List<TaskEntity>>> getTasks();

  /// Updates the status of a task by [taskId].
  Future<Either<Failure, TaskEntity>> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  });

  /// Creates a new task.
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  });
}

/// Minimal Either implementation — avoids the `dartz` dependency overhead.
/// In production, consider using `fpdart` or `dartz` for a richer functional toolkit.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (this is Left<L, R>) return onLeft((this as Left<L, R>).value);
    return onRight((this as Right<L, R>).value);
  }

  R? get right => isRight ? (this as Right<L, R>).value : null;
  L? get left => isLeft ? (this as Left<L, R>).value : null;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
