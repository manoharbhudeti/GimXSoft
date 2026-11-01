import 'package:dio/dio.dart';

enum AppErrorType {
  noInternet,
  networkTimeout,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  rateLimit,
  server,
  serialization,
  unknown,
}

class AppError {
  final AppErrorType type;
  final int? statusCode;
  final String title;
  final String message;
  final String? errorCode;
  final String? correlationId;
  final Map<String, List<String>>? fieldErrors;
  final Object? originalException;

  const AppError({
    required this.type,
    required this.title,
    required this.message,
    this.statusCode,
    this.errorCode,
    this.correlationId,
    this.fieldErrors,
    this.originalException,
  });

  bool get isNetworkError =>
      type == AppErrorType.noInternet || type == AppErrorType.networkTimeout;

  bool get isAuthError =>
      type == AppErrorType.unauthorized || type == AppErrorType.forbidden;

  bool get isServerError => type == AppErrorType.server;

  factory AppError.fromDioException(DioException dioException) {
    if (dioException.type == DioExceptionType.connectionTimeout ||
        dioException.type == DioExceptionType.sendTimeout ||
        dioException.type == DioExceptionType.receiveTimeout) {
      return AppError(
        type: AppErrorType.networkTimeout,
        statusCode: 408,
        title: 'Connection Timed Out',
        message: 'The server took too long to respond. Please check your connection and try again.',
        errorCode: 'REQUEST_TIMEOUT',
        originalException: dioException,
      );
    }

    if (dioException.type == DioExceptionType.connectionError) {
      return AppError(
        type: AppErrorType.noInternet,
        title: 'Network Unreachable',
        message: 'Unable to connect to the GIMXSOFT server. Please check your internet connectivity.',
        errorCode: 'NETWORK_UNREACHABLE',
        originalException: dioException,
      );
    }

    final response = dioException.response;
    if (response != null) {
      final statusCode = response.statusCode ?? 500;
      final data = response.data;

      String? rfcTitle;
      String? rfcDetail;
      String? rfcErrorCode;
      String? rfcCorrelationId;
      Map<String, List<String>>? fieldErrors;

      if (data is Map<String, dynamic>) {
        rfcTitle = data['title'] as String?;
        rfcDetail = (data['detail'] ?? data['message']) as String?;
        rfcErrorCode = data['errorCode'] as String?;
        rfcCorrelationId = data['correlationId'] as String?;

        if (data['errors'] is Map<String, dynamic>) {
          fieldErrors = {};
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            if (value is List) {
              fieldErrors![key] = value.map((e) => e.toString()).toList();
            } else if (value != null) {
              fieldErrors![key] = [value.toString()];
            }
          });
        }
      }

      return AppError.fromStatusCode(
        statusCode: statusCode,
        customTitle: rfcTitle,
        customDetail: rfcDetail,
        errorCode: rfcErrorCode,
        correlationId: rfcCorrelationId,
        fieldErrors: fieldErrors,
        originalException: dioException,
      );
    }

    return AppError(
      type: AppErrorType.unknown,
      title: 'Unexpected Error',
      message: 'An unexpected application error occurred. Please try again.',
      errorCode: 'UNEXPECTED_ERROR',
      originalException: dioException,
    );
  }

  factory AppError.fromStatusCode({
    required int statusCode,
    String? customTitle,
    String? customDetail,
    String? errorCode,
    String? correlationId,
    Map<String, List<String>>? fieldErrors,
    Object? originalException,
  }) {
    switch (statusCode) {
      case 400:
        return AppError(
          type: AppErrorType.validation,
          statusCode: statusCode,
          title: customTitle ?? 'Invalid Request',
          message: customDetail ?? 'The request could not be processed due to invalid parameters.',
          errorCode: errorCode ?? 'BAD_REQUEST',
          correlationId: correlationId,
          fieldErrors: fieldErrors,
          originalException: originalException,
        );

      case 401:
        return AppError(
          type: AppErrorType.unauthorized,
          statusCode: statusCode,
          title: customTitle ?? 'Session Expired',
          message: customDetail ?? 'Your authentication session has expired. Please sign in again.',
          errorCode: errorCode ?? 'UNAUTHORIZED',
          correlationId: correlationId,
          originalException: originalException,
        );

      case 403:
        return AppError(
          type: AppErrorType.forbidden,
          statusCode: statusCode,
          title: customTitle ?? 'Access Denied',
          message: customDetail ?? 'You do not have sufficient permissions to perform this action.',
          errorCode: errorCode ?? 'FORBIDDEN',
          correlationId: correlationId,
          originalException: originalException,
        );

      case 404:
        return AppError(
          type: AppErrorType.notFound,
          statusCode: statusCode,
          title: customTitle ?? 'Resource Not Found',
          message: customDetail ?? 'The requested item or record could not be found.',
          errorCode: errorCode ?? 'NOT_FOUND',
          correlationId: correlationId,
          originalException: originalException,
        );

      case 409:
        return AppError(
          type: AppErrorType.conflict,
          statusCode: statusCode,
          title: customTitle ?? 'Data Conflict',
          message: customDetail ?? 'A record with similar details already exists or state is conflicting.',
          errorCode: errorCode ?? 'CONFLICT',
          correlationId: correlationId,
          originalException: originalException,
        );

      case 422:
        return AppError(
          type: AppErrorType.validation,
          statusCode: statusCode,
          title: customTitle ?? 'Validation Failed',
          message: customDetail ?? 'Please correct the highlighted errors before submitting.',
          errorCode: errorCode ?? 'VALIDATION_FAILED',
          correlationId: correlationId,
          fieldErrors: fieldErrors,
          originalException: originalException,
        );

      case 429:
        return AppError(
          type: AppErrorType.rateLimit,
          statusCode: statusCode,
          title: customTitle ?? 'Too Many Requests',
          message: customDetail ?? 'You have made too many requests in a short time. Please wait a moment.',
          errorCode: errorCode ?? 'RATE_LIMITED',
          correlationId: correlationId,
          originalException: originalException,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          type: AppErrorType.server,
          statusCode: statusCode,
          title: customTitle ?? 'Server Temporarily Unavailable',
          message: customDetail ?? 'Our backend encountered an unexpected error. Please retry shortly.',
          errorCode: errorCode ?? 'SERVER_ERROR',
          correlationId: correlationId,
          originalException: originalException,
        );

      default:
        return AppError(
          type: AppErrorType.unknown,
          statusCode: statusCode,
          title: customTitle ?? 'Unexpected Error',
          message: customDetail ?? 'An error occurred while processing your request.',
          errorCode: errorCode ?? 'UNKNOWN',
          correlationId: correlationId,
          originalException: originalException,
        );
    }
  }

  factory AppError.serialization(Object error) {
    return AppError(
      type: AppErrorType.serialization,
      title: 'Data Format Error',
      message: 'Failed to process data received from the server.',
      errorCode: 'SERIALIZATION_FAILED',
      originalException: error,
    );
  }

  factory AppError.generic(String message, {String? title, Object? originalException}) {
    return AppError(
      type: AppErrorType.unknown,
      title: title ?? 'Operation Failed',
      message: message,
      errorCode: 'GENERIC_ERROR',
      originalException: originalException,
    );
  }

  @override
  String toString() => 'AppError[$type] ($errorCode): $message';
}

