import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioErrorMapper {
  static AppException map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException("Connection timeout. Please try again.");

      case DioExceptionType.connectionError:
        return NetworkException("No internet connection.");

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? "Something went wrong";

        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(message, statusCode);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException("Server error. Try again later.", statusCode);
        } else {
          return ServerException(message, statusCode);
        }

      case DioExceptionType.cancel:
        return NetworkException("Request was cancelled.");

      case DioExceptionType.unknown:
      default:
        return UnknownException("Unexpected error occurred.");
    }
  }
}
