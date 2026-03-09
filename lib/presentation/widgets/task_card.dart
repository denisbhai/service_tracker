// lib/presentation/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Priority badge + Status badge
              Row(
                children: [
                  PriorityBadge(priority: task.priority, compact: true),
                  const Spacer(),
                  StatusBadge(status: task.status, compact: true),
                ],
              ),
              const SizedBox(height: 10),

              // Task title
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.3,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Description preview
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Divider
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer: assigned agent + due date
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedTo ?? 'Unassigned',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.calendar_today_rounded,
                    size: 13,
                    color: isOverdue ? AppTheme.errorColor : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOverdue
                        ? 'Overdue · ${AppDateUtils.toDisplayDate(task.dueDate)}'
                        : AppDateUtils.toDisplayDate(task.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? AppTheme.errorColor
                              : AppTheme.textMuted,
                          fontWeight: isOverdue ? FontWeight.w600 : null,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
