import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class ToastMessage {
  final String id;
  final ToastType type;
  final String title;
  final String? message;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  ToastMessage({
    required this.id,
    required this.type,
    required this.title,
    this.message,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
  });
}

class ToastNotifier extends Notifier<List<ToastMessage>> {
  @override
  List<ToastMessage> build() => [];

  void show({
    required ToastType type,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final toast = ToastMessage(
      id: id,
      type: type,
      title: title,
      message: message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    // Keep at most 3 simultaneous toasts
    final currentList = state.length >= 3 ? state.sublist(state.length - 2) : state;
    state = [...currentList, toast];

    Timer(duration, () {
      dismiss(id);
    });
  }

  void success(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.success,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void error(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.error,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void warning(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.warning,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void info(String title, {String? message, String? actionLabel, VoidCallback? onAction}) {
    show(
      type: ToastType.info,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void dismiss(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final toastProvider = NotifierProvider<ToastNotifier, List<ToastMessage>>(() {
  return ToastNotifier();
});

/// Visual Overlay rendering active toasts
class ToastOverlay extends ConsumerWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);

    if (toasts.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: toasts.map((toast) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ToastCard(toast: toast),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends ConsumerWidget {
  final ToastMessage toast;

  const _ToastCard({required this.toast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color accentColor;
    IconData icon;

    switch (toast.type) {
      case ToastType.success:
        accentColor = AppColors.emerald;
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        accentColor = AppColors.rose;
        icon = Icons.error_rounded;
        break;
      case ToastType.warning:
        accentColor = AppColors.amber;
        icon = Icons.warning_rounded;
        break;
      case ToastType.info:
        accentColor = AppColors.cyan;
        icon = Icons.info_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161924) : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: accentColor.withOpacity(isDark ? 0.35 : 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  toast.title,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (toast.message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    toast.message!,
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (toast.actionLabel != null && toast.onAction != null) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                toast.onAction!();
                ref.read(toastProvider.notifier).dismiss(toast.id);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                toast.actionLabel!,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted(isDark)),
            onPressed: () => ref.read(toastProvider.notifier).dismiss(toast.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
}

