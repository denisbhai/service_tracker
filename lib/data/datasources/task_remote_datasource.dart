// lib/data/datasources/task_remote_datasource.dart

import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> updateTaskStatus({required int taskId, required bool completed});
  Future<TaskModel> createTask({required Map<String, dynamic> taskData});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSourceImpl(DioClient client) : _dio = client.dio;

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      // JSONPlaceholder returns 200 todos — we limit to 20 for a usable list
      final response = await _dio.get(
        AppConstants.todosEndpoint,
        queryParameters: {'_limit': 20},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! List) {
          throw const ParseException(message: 'Expected a list of tasks.');
        }
        return data
            .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Unexpected status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ParseException(message: 'Failed to parse tasks: $e');
    }
  }

  @override
  Future<TaskModel> updateTaskStatus({
    required int taskId,
    required bool completed,
  }) async {
    try {
      // JSONPlaceholder accepts PATCH — returns the merged object
      final response = await _dio.patch(
        '${AppConstants.todosEndpoint}/$taskId',
        data: {'completed': completed},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw const ParseException(message: 'Unexpected response shape.');
        }
        return TaskModel.fromJson(data);
      }

      throw ServerException(statusCode: response.statusCode);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Update failed');
    } catch (e) {
      throw ParseException(message: 'Failed to parse update response: $e');
    }
  }

  @override
  Future<TaskModel> createTask({required Map<String, dynamic> taskData}) async {
    try {
      // JSONPlaceholder POST /todos — returns the created object with id 201
      final response = await _dio.post(
        AppConstants.todosEndpoint,
        data: taskData,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw const ParseException(message: 'Unexpected response shape.');
        }
        return TaskModel.fromJson(data);
      }

      throw ServerException(statusCode: response.statusCode);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Create failed');
    } catch (e) {
      throw ParseException(message: 'Failed to parse create response: $e');
    }
  }
}
