// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String todosEndpoint = '/todos';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // UI
  static const String appName = 'Field Service Tracker';
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Priorities
  static const List<String> priorityLevels = ['Low', 'Medium', 'High', 'Critical'];

  // Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';

  static const List<String> taskStatuses = [
    statusPending,
    statusInProgress,
    statusCompleted,
  ];
}
