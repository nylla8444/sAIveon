import 'package:dio/dio.dart';
import 'api_error.dart';

ApiError mapDioError(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    final msg = error.message ?? 'Network error';
    return ApiError(msg, statusCode: code);
  }
  return ApiError('Unexpected error');
}
