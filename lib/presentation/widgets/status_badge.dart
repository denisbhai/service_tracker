// lib/presentation/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _StatusConfig.of(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: config.fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(priority);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return AppTheme.lowColor;
      case TaskPriority.medium:
        return AppTheme.mediumColor;
      case TaskPriority.high:
        return AppTheme.highColor;
      case TaskPriority.critical:
        return AppTheme.criticalColor;
    }
  }
}

class _StatusConfig {
  final Color fg;
  final Color bg;

  const _StatusConfig({required this.fg, required this.bg});

  static _StatusConfig of(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const _StatusConfig(
            fg: AppTheme.pendingColor, bg: AppTheme.pendingBg);
      case TaskStatus.inProgress:
        return const _StatusConfig(
            fg: AppTheme.inProgressColor, bg: AppTheme.inProgressBg);
      case TaskStatus.completed:
        return const _StatusConfig(
            fg: AppTheme.completedColor, bg: AppTheme.completedBg);
    }
  }
}
