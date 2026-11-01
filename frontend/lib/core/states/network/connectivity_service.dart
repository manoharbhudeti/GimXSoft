import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_constants.dart';

class ConnectivityState {
  final bool isConnected;
  final bool isChecking;
  final DateTime? lastChecked;

  const ConnectivityState({
    required this.isConnected,
    this.isChecking = false,
    this.lastChecked,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isChecking,
    DateTime? lastChecked,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class ConnectivityNotifier extends Notifier<ConnectivityState> {
  Timer? _heartbeatTimer;
  final Dio _pingDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  @override
  ConnectivityState build() {
    // Start periodic background heartbeats
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });

    ref.onDispose(() {
      _heartbeatTimer?.cancel();
    });

    return ConnectivityState(
      isConnected: true,
      lastChecked: DateTime.now(),
    );
  }

  Future<bool> checkConnectivity() async {
    state = state.copyWith(isChecking: true);
    try {
      final response = await _pingDio.get(
        '${ApiConstants.baseUrl}/dashboard/metrics',
        options: Options(
          headers: {'Cache-Control': 'no-cache'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final reachable = response.statusCode != null && response.statusCode! < 500;
      state = state.copyWith(
        isConnected: reachable,
        isChecking: false,
        lastChecked: DateTime.now(),
      );
      return reachable;
    } catch (_) {
      state = state.copyWith(
        isConnected: false,
        isChecking: false,
        lastChecked: DateTime.now(),
      );
      return false;
    }
  }

  void setOfflineForTesting(bool isOffline) {
    state = state.copyWith(
      isConnected: !isOffline,
      isChecking: false,
      lastChecked: DateTime.now(),
    );
  }
}

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>(() {
  return ConnectivityNotifier();
});
