import 'package:dio/dio.dart';
import '../errors/app_error.dart';

class ApiErrorHandler {
  static AppError handle(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return AppError.fromDioException(error);
    }

    if (error is FormatException) {
      return AppError.serialization(error);
    }

    if (error is TypeError) {
      return AppError.serialization(error);
    }

    return AppError.generic(
      error?.toString() ?? 'An unknown error occurred.',
      originalException: error,
    );
  }

  static String getDisplayMessage(dynamic error) {
    return handle(error).message;
  }
}
