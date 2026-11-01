import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoadingType {
  none,
  splash,
  initialization,
  fullScreen,
  backgroundSync,
}

class LoadingState {
  final LoadingType type;
  final String? message;
  final double? progress;

  const LoadingState({
    this.type = LoadingType.none,
    this.message,
    this.progress,
  });

  bool get isLoading => type != LoadingType.none;
}

class GlobalLoadingNotifier extends Notifier<LoadingState> {
  @override
  LoadingState build() => const LoadingState();

  void show({
    LoadingType type = LoadingType.fullScreen,
    String? message,
    double? progress,
  }) {
    state = LoadingState(
      type: type,
      message: message,
      progress: progress,
    );
  }

  void updateProgress(double progress, {String? message}) {
    state = LoadingState(
      type: state.type,
      message: message ?? state.message,
      progress: progress,
    );
  }

  void hide() {
    state = const LoadingState();
  }
}

final globalLoadingProvider =
    NotifierProvider<GlobalLoadingNotifier, LoadingState>(() {
  return GlobalLoadingNotifier();
});

final backgroundSyncProvider = NotifierProvider<BackgroundSyncNotifier, bool>(() {
  return BackgroundSyncNotifier();
});

class BackgroundSyncNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void startSync() => state = true;
  void finishSync() => state = false;
}
