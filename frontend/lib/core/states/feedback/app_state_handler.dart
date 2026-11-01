import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_error.dart';
import '../errors/network_error.dart';
import '../errors/not_found_error.dart';
import '../errors/server_error.dart';
import '../errors/unauthorized_error.dart';
import '../loading/inline_loader.dart';
import '../loading/skeleton_loader.dart';
import '../network/api_error_handler.dart';

extension AsyncValueFeedbackX<T> on AsyncValue<T> {
  Widget buildStateWidget(
    BuildContext context, {
    required Widget Function(T data) onData,
    Widget? loadingWidget,
    bool Function(T data)? isEmpty,
    Widget? emptyWidget,
    VoidCallback? onRetry,
  }) {
    return when(
      loading: () =>
          loadingWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: InlineLoader(size: 32),
            ),
          ),
      error: (error, stackTrace) {
        final appError = ApiErrorHandler.handle(error);

        switch (appError.type) {
          case AppErrorType.noInternet:
          case AppErrorType.networkTimeout:
            return NetworkErrorView(
              title: appError.title,
              message: appError.message,
              onRetry: onRetry,
            );

          case AppErrorType.unauthorized:
            return UnauthorizedErrorView(
              isForbidden: false,
              title: appError.title,
              message: appError.message,
              onAction: onRetry,
            );

          case AppErrorType.forbidden:
            return UnauthorizedErrorView(
              isForbidden: true,
              title: appError.title,
              message: appError.message,
            );

          case AppErrorType.notFound:
            return NotFoundErrorView(
              title: appError.title,
              message: appError.message,
              onBack: onRetry,
            );

          case AppErrorType.server:
            return ServerErrorView(
              title: appError.title,
              message: appError.message,
              correlationId: appError.correlationId,
              onRetry: onRetry,
            );

          default:
            return ServerErrorView(
              title: appError.title,
              message: appError.message,
              correlationId: appError.correlationId,
              onRetry: onRetry,
            );
        }
      },
      data: (data) {
        if (isEmpty != null && isEmpty(data) && emptyWidget != null) {
          return emptyWidget;
        }
        return onData(data);
      },
    );
  }

  Widget buildTableState(
    BuildContext context, {
    required Widget Function(T data) onData,
    bool Function(T data)? isEmpty,
    Widget? emptyWidget,
    VoidCallback? onRetry,
    int skeletonRows = 6,
    int skeletonColumns = 5,
  }) {
    return buildStateWidget(
      context,
      loadingWidget: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppSkeletonLoader.tableRows(
          rows: skeletonRows,
          columns: skeletonColumns,
        ),
      ),
      isEmpty: isEmpty,
      emptyWidget: emptyWidget,
      onRetry: onRetry,
      onData: onData,
    );
  }
}

