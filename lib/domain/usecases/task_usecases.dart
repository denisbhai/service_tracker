// lib/domain/usecases/get_tasks_usecase.dart

import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';

/// Use case: Fetch all tasks
/// Single-responsibility: just orchestrates fetching.
/// BLoCs call use cases — not repositories directly.
class GetTasksUseCase {
  final TaskRepository _repository;

  const GetTasksUseCase(this._repository);

  Future<Either<Failure, List<TaskEntity>>> call() {
    return _repository.getTasks();
  }
}

/// Use case: Update task status
class UpdateTaskStatusUseCase {
  final TaskRepository _repository;

  const UpdateTaskStatusUseCase(this._repository);

  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
    required TaskStatus newStatus,
  }) {
    return _repository.updateTaskStatus(
      taskId: taskId,
      newStatus: newStatus,
    );
  }
}

/// Use case: Create a new task
class CreateTaskUseCase {
  final TaskRepository _repository;

  const CreateTaskUseCase(this._repository);

  Future<Either<Failure, TaskEntity>> call({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) {
    return _repository.createTask(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
  }
}
