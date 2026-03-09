// test/domain/entities/task_entity_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:field_service_tracker/domain/entities/task_entity.dart';

void main() {
  group('TaskEntity', () {
    late TaskEntity pendingTask;
    late TaskEntity inProgressTask;
    late TaskEntity completedTask;

    setUp(() {
      pendingTask = TaskEntity(
        id: '1',
        title: 'Test Task',
        description: 'Test description',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        assignedDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
      );
      inProgressTask = pendingTask.copyWith(status: TaskStatus.inProgress);
      completedTask = pendingTask.copyWith(status: TaskStatus.completed);
    });

    group('TaskStatus.next', () {
      test('pending.next returns inProgress', () {
        expect(TaskStatus.pending.next, TaskStatus.inProgress);
      });

      test('inProgress.next returns completed', () {
        expect(TaskStatus.inProgress.next, TaskStatus.completed);
      });

      test('completed.next returns completed (terminal)', () {
        expect(TaskStatus.completed.next, TaskStatus.completed);
      });
    });

    group('TaskStatus.isTerminal', () {
      test('only completed is terminal', () {
        expect(TaskStatus.pending.isTerminal, isFalse);
        expect(TaskStatus.inProgress.isTerminal, isFalse);
        expect(TaskStatus.completed.isTerminal, isTrue);
      });
    });

    group('isOverdue', () {
      test('returns false for completed tasks even if past due', () {
        final overdueDone = completedTask.copyWith(
          dueDate: DateTime(2020, 1, 1),
        );
        expect(overdueDone.isOverdue, isFalse);
      });

      test('returns true for pending tasks past due date', () {
        final overdueTask = pendingTask.copyWith(
          dueDate: DateTime(2020, 1, 1),
        );
        expect(overdueTask.isOverdue, isTrue);
      });

      test('returns false for task due in future', () {
        expect(pendingTask.isOverdue, isFalse);
      });
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final copy = pendingTask.copyWith(status: TaskStatus.inProgress);
        expect(copy.id, pendingTask.id);
        expect(copy.title, pendingTask.title);
        expect(copy.status, TaskStatus.inProgress);
      });
    });

    group('TaskStatus.fromLabel', () {
      test('parses known labels correctly', () {
        expect(TaskStatus.fromLabel('Pending'), TaskStatus.pending);
        expect(TaskStatus.fromLabel('In Progress'), TaskStatus.inProgress);
        expect(TaskStatus.fromLabel('Completed'), TaskStatus.completed);
      });

      test('falls back to pending for unknown labels', () {
        expect(TaskStatus.fromLabel('Unknown'), TaskStatus.pending);
      });
    });

    group('TaskPriority.fromLabel', () {
      test('parses case-insensitively', () {
        expect(TaskPriority.fromLabel('critical'), TaskPriority.critical);
        expect(TaskPriority.fromLabel('HIGH'), TaskPriority.high);
        expect(TaskPriority.fromLabel('Medium'), TaskPriority.medium);
        expect(TaskPriority.fromLabel('low'), TaskPriority.low);
      });
    });

    group('Equatable', () {
      test('two identical entities are equal', () {
        final a = pendingTask;
        final b = pendingTask.copyWith();
        expect(a, b);
      });

      test('entities with different status are not equal', () {
        expect(pendingTask, isNot(inProgressTask));
      });
    });
  });
}
