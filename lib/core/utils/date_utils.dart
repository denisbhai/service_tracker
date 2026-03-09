// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _fullFormat = DateFormat('MMMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd");

  static String toDisplayDate(DateTime date) => _displayFormat.format(date);

  static String toFullDate(DateTime date) => _fullFormat.format(date);

  static String toTime(DateTime date) => _timeFormat.format(date);

  static String toIso(DateTime date) => _isoFormat.format(date);

  /// Returns human-readable relative time ("2 days ago", "Just now")
  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return toDisplayDate(date);
  }

  /// Returns whether a task is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }
}
