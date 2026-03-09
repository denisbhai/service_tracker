// lib/core/di/service_locator.dart

import 'package:get_it/get_it.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/task_usecases.dart';
import '../network/dio_client.dart';

final GetIt sl = GetIt.instance;

/// Register all dependencies here.
/// BLoCs are NOT registered as singletons — they are created fresh
/// per screen via BlocProvider to avoid stale state.
void setupServiceLocator() {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Data sources
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl<TaskRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => UpdateTaskStatusUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl<TaskRepository>()));
}
