// lib/presentation/screens/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task_detail/task_detail_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/status_badge.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskDetailBloc(updateTaskStatusUseCase: sl())
        ..add(TaskDetailLoaded(task)),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailBloc, TaskDetailState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == TaskDetailStatus.updateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Status updated to ${state.task?.status.label}'),
                ],
              ),
              backgroundColor: AppTheme.completedColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
          // Return updated task to list screen
          Navigator.of(context).pop(state.task);
        }
        if (state.status == TaskDetailStatus.updateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Update failed'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }
      },
      builder: (context, state) {
        final task = state.task;
        if (task == null) return const Scaffold();

        final isUpdating = state.status == TaskDetailStatus.updating;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Task Detail'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(task: task),
                const SizedBox(height: 12),
                _DescriptionCard(task: task),
                const SizedBox(height: 12),
                _MetaCard(task: task),
                const SizedBox(height: 24),
                if (!task.status.isTerminal)
                  _UpdateStatusButton(
                    task: task,
                    isLoading: isUpdating,
                    onPressed: () => context
                        .read<TaskDetailBloc>()
                        .add(TaskDetailStatusUpdateRequested(
                          taskId: task.id,
                          newStatus: task.status.next,
                        )),
                  ),
                if (task.status.isTerminal) _CompletionBanner(task: task),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final TaskEntity task;
  const _HeaderCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PriorityBadge(priority: task.priority),
              const SizedBox(width: 8),
              StatusBadge(status: task.status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (task.isOverdue) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.errorBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: AppTheme.errorColor),
                  SizedBox(width: 6),
                  Text(
                    'Overdue',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final TaskEntity task;
  const _DescriptionCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return _InfoSection(
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        task.description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final TaskEntity task;
  const _MetaCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return _InfoSection(
      title: 'Details',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.person_outline_rounded,
            label: 'Assigned To',
            value: task.assignedTo ?? 'Unassigned',
          ),
          const SizedBox(height: 12),
          _MetaRow(
            icon: Icons.calendar_today_rounded,
            label: 'Assigned Date',
            value: AppDateUtils.toFullDate(task.assignedDate),
          ),
          const SizedBox(height: 12),
          _MetaRow(
            icon: Icons.event_rounded,
            label: 'Due Date',
            value: AppDateUtils.toFullDate(task.dueDate),
            valueColor:
                task.isOverdue ? AppTheme.errorColor : AppTheme.textPrimary,
          ),
          const SizedBox(height: 12),
          _MetaRow(
            icon: Icons.tag_rounded,
            label: 'Task ID',
            value: '#${task.id.length > 8 ? task.id.substring(0, 8) : task.id}',
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _UpdateStatusButton extends StatelessWidget {
  final TaskEntity task;
  final bool isLoading;
  final VoidCallback onPressed;

  const _UpdateStatusButton({
    required this.task,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final nextStatus = task.status.next;
    final isComplete = nextStatus == TaskStatus.completed;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isComplete ? AppTheme.completedColor : AppTheme.primaryColor,
      ),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              isComplete
                  ? Icons.check_circle_outline_rounded
                  : Icons.play_arrow_rounded,
              size: 20,
            ),
      label: Text(
        isLoading
            ? 'Updating...'
            : (isComplete
                ? 'Mark as Completed'
                : 'Mark as ${nextStatus.label}'),
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  final TaskEntity task;
  const _CompletionBanner({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.completedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.completedColor.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded,
              size: 20, color: AppTheme.completedColor),
          SizedBox(width: 10),
          Text(
            'This task is completed.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.completedColor,
            ),
          ),
        ],
      ),
    );
  }
}
