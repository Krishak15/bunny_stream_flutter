import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class DioClient {
  late Dio _dio;
  final String accessKey;
  final String baseUrl = 'https://video.bunnycdn.com';

  DioClient({required this.accessKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'AccessKey': accessKey, 'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '🌐 REQUEST: ${options.method} ${options.baseUrl}${options.path}\n'
            'Params: ${options.queryParameters}',
            name: 'DioClient',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}\n'
            'Data: ${response.data}',
            name: 'DioClient',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
            '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.path}\n'
            'Message: ${error.message}\n'
            'Response: ${error.response?.data}',
            name: 'DioClient',
            error: error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    } else if (error.response != null) {
      return 'Error ${error.response?.statusCode}: ${error.response?.statusMessage}';
    }
    return error.message ?? 'Unknown error';
  }
}
