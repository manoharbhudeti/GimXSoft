import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../loading/app_loading.dart';
import '../network/api_error_handler.dart';
import '../success/app_toast.dart';
import '../success/confirmation_dialog.dart';
import '../success/success_dialog.dart';

class AppFeedbackManager {
  final WidgetRef ref;

  AppFeedbackManager(this.ref);

  void showToast({
    required String title,
    String? message,
    ToastType type = ToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ref.read(toastProvider.notifier).show(
      type: type,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showSuccess(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    ref.read(toastProvider.notifier).success(
      title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showError(dynamic error, {String? overrideTitle, String? actionLabel, VoidCallback? onAction}) {
    final appError = ApiErrorHandler.handle(error);
    ref.read(toastProvider.notifier).error(
      overrideTitle ?? appError.title,
      message: appError.message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showWarning(String title, {String? message}) {
    ref.read(toastProvider.notifier).warning(title, message: message);
  }

  void showInfo(String title, {String? message}) {
    ref.read(toastProvider.notifier).info(title, message: message);
  }

  void showLoading({String? message, double? progress}) {
    ref.read(globalLoadingProvider.notifier).show(
      type: LoadingType.fullScreen,
      message: message,
      progress: progress,
    );
  }

  void hideLoading() {
    ref.read(globalLoadingProvider.notifier).hide();
  }

  Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await SystemConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    );
    return result ?? false;
  }

  Future<void> showSuccessModal({
    required BuildContext context,
    required String title,
    required String message,
    String primaryActionLabel = 'Done',
    VoidCallback? onPrimaryAction,
  }) {
    return SuccessDialog.show(
      context: context,
      title: title,
      message: message,
      primaryActionLabel: primaryActionLabel,
      onPrimaryAction: onPrimaryAction,
    );
  }
}

final feedbackManagerProvider = Provider.family<AppFeedbackManager, WidgetRef>((ref, widgetRef) {
  return AppFeedbackManager(widgetRef);
});
