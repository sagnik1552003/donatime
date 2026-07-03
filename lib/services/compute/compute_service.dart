import 'package:dio/dio.dart';

import 'models/task.dart';

class ComputeService {

  final String deviceId;

  final Dio _dio;

  ComputeService({
    required this.deviceId,
    required String baseUrl,
  }) : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout:
      const Duration(
        seconds: 10,
      ),
    ),
  );

  Future<ComputeTask?> claimTask() async {

    try {

      final res =
      await _dio.post(
        '/tasks/claim',

        data: {
          'device_id': deviceId,
        },
      );

      return ComputeTask.fromJson(
        res.data,
      );

    } on DioException catch (e) {

      if (e.response?.statusCode ==
          404) {
        return null;
      }

      rethrow;
    }
  }

  Future<void> submitResult({
    required String taskId,
    required dynamic result,
    required bool success,
    required double durationMs,
  }) async {

    await _dio.post(
      '/tasks/$taskId/submit',

      data: {

        'device_id': deviceId,

        'result': result,

        'success': success,

        'duration_ms': durationMs,
      },
    );
  }

  Future<Map<String, dynamic>>
  stats() async {

    final r =
    await _dio.get(
      '/stats',
    );

    return r.data;
  }
}