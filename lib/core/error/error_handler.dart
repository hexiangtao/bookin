import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else {
      return ServerFailure('Unexpected error occurred');
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Connection timeout');
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response?.statusCode);
      case DioExceptionType.cancel:
        return ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return ServerFailure('No internet connection');
      default:
        return ServerFailure('Something went wrong');
    }
  }

  static Failure _handleResponseError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ServerFailure('Bad request');
      case 401:
        return ServerFailure('Unauthorized');
      case 403:
        return ServerFailure('Forbidden');
      case 404:
        return ServerFailure('Not found');
      case 500:
        return ServerFailure('Internal server error');
      default:
        return ServerFailure('Something went wrong');
    }
  }
}