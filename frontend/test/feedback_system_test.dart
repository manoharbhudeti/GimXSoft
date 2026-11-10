import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/states/empty_states/app_empty_state.dart';
import 'package:frontend/core/states/empty_states/search_empty_state.dart';
import 'package:frontend/core/states/errors/app_error.dart';
import 'package:frontend/core/states/errors/network_error.dart';
import 'package:frontend/core/states/errors/server_error.dart';
import 'package:frontend/core/states/errors/unauthorized_error.dart';
import 'package:frontend/core/states/loading/app_loading.dart';
import 'package:frontend/core/states/loading/inline_loader.dart';
import 'package:frontend/core/states/network/connectivity_service.dart';
import 'package:frontend/core/states/success/app_toast.dart';
import 'package:frontend/core/theme/app_theme.dart';

void main() {
  group('1. API Error & RFC 9457 Mapping Tests', () {
    test('Should parse RFC 9457 Problem Details from DioException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/members/123'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/members/123'),
          statusCode: 404,
          data: {
            'type': 'https://tools.ietf.org/html/rfc9457#section-3.1',
            'title': 'Resource Not Found',
            'status': 404,
            'detail': 'Member with ID 123 was not found.',
            'errorCode': 'RESOURCE_NOT_FOUND',
            'correlationId': 'CORR-TEST-123',
          },
        ),
      );

      final appError = AppError.fromDioException(dioException);

      expect(appError.type, equals(AppErrorType.notFound));
      expect(appError.statusCode, equals(404));
      expect(appError.title, equals('Resource Not Found'));
      expect(appError.message, equals('Member with ID 123 was not found.'));
      expect(appError.errorCode, equals('RESOURCE_NOT_FOUND'));
      expect(appError.correlationId, equals('CORR-TEST-123'));
    });

    test('Should handle Network Timeout with user-friendly advice', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/attendance/check-in'),
        type: DioExceptionType.connectionTimeout,
      );

      final appError = AppError.fromDioException(dioException);

      expect(appError.type, equals(AppErrorType.networkTimeout));
      expect(appError.isNetworkError, isTrue);
      expect(appError.message, contains('took too long to respond'));
    });

    test('Should map 401 to Session Expired and 403 to Access Denied', () {
      final err401 = AppError.fromStatusCode(statusCode: 401);
      expect(err401.type, equals(AppErrorType.unauthorized));
      expect(err401.isAuthError, isTrue);
      expect(err401.title, equals('Session Expired'));

      final err403 = AppError.fromStatusCode(statusCode: 403);
      expect(err403.type, equals(AppErrorType.forbidden));
      expect(err403.isAuthError, isTrue);
      expect(err403.title, equals('Access Denied'));
    });

    test('Should sanitize 500 server error and never expose stack traces', () {
      final err500 = AppError.fromStatusCode(
        statusCode: 500,
        correlationId: 'REQ-ERR-999',
      );
      expect(err500.isServerError, isTrue);
      expect(err500.message, contains('unexpected error'));
      expect(err500.correlationId, equals('REQ-ERR-999'));
    });
  });

  group('2. Toast Notifier & Global Loading State Tests', () {
    test('ToastNotifier adds, limits to 3, and removes toasts', () {
      final container = ProviderContainer();
      final notifier = container.read(toastProvider.notifier);

      expect(container.read(toastProvider), isEmpty);

      notifier.success('Payment Collected', message: 'Invoice INV-001 generated.');
      expect(container.read(toastProvider).length, equals(1));
      expect(container.read(toastProvider).first.title, equals('Payment Collected'));
      expect(container.read(toastProvider).first.type, equals(ToastType.success));

      notifier.warning('Approaching Renewal');
      notifier.info('Sync in Progress');
      notifier.error('Failed to save');

      // Maximum 3 toasts preserved to avoid cluttering UI
      expect(container.read(toastProvider).length, equals(3));
    });

    test('GlobalLoadingNotifier transitions and cleans up without sticking', () {
      final container = ProviderContainer();
      final notifier = container.read(globalLoadingProvider.notifier);

      expect(container.read(globalLoadingProvider).isLoading, isFalse);

      notifier.show(type: LoadingType.fullScreen, message: 'Processing...');
      expect(container.read(globalLoadingProvider).isLoading, isTrue);
      expect(container.read(globalLoadingProvider).message, equals('Processing...'));

      notifier.updateProgress(0.75);
      expect(container.read(globalLoadingProvider).progress, equals(0.75));

      notifier.hide();
      expect(container.read(globalLoadingProvider).isLoading, isFalse);
    });

    test('ConnectivityNotifier toggles state accurately', () {
      final container = ProviderContainer();
      final notifier = container.read(connectivityProvider.notifier);

      expect(container.read(connectivityProvider).isConnected, isTrue);

      notifier.setOfflineForTesting(true);
      expect(container.read(connectivityProvider).isConnected, isFalse);

      notifier.setOfflineForTesting(false);
      expect(container.read(connectivityProvider).isConnected, isTrue);
    });
  });

  group('3. UI Component Rendering & Theme Tests', () {
    testWidgets('AppEmptyState renders icon, title and executes actions in Light and Dark mode',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.inbox_rounded,
              title: 'Empty Inbox',
              description: 'You have no pending inquiries or alerts.',
              primaryActionLabel: 'Refresh Items',
              onPrimaryAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Empty Inbox'), findsOneWidget);
      expect(find.text('You have no pending inquiries or alerts.'), findsOneWidget);
      expect(find.text('Refresh Items'), findsOneWidget);

      await tester.tap(find.text('Refresh Items'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('SearchEmptyState displays query and onClear trigger', (tester) async {
      bool clearTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SearchEmptyState(
              searchQuery: 'Yoga Advanced',
              onClear: () => clearTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No Matching Results'), findsOneWidget);
      expect(find.textContaining('Yoga Advanced'), findsOneWidget);

      await tester.tap(find.text('Clear Search & Filters'));
      expect(clearTriggered, isTrue);
    });

    testWidgets('NetworkErrorView renders error and responds to Retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: NetworkErrorView(
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Connection Unavailable'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      await tester.tap(find.text('Retry Connection'));
      expect(retried, isTrue);
    });

    testWidgets('ServerErrorView renders correlation ID reference and try again',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ServerErrorView(
              correlationId: 'CORR-9988-XYZ',
            ),
          ),
        ),
      );

      expect(find.text('Server Temporarily Unavailable'), findsOneWidget);
      expect(find.textContaining('CORR-9988-XYZ'), findsOneWidget);
    });

    testWidgets('UnauthorizedErrorView renders forbidden and session expired states',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: UnauthorizedErrorView(
              isForbidden: true,
            ),
          ),
        ),
      );

      expect(find.text('Access Restricted'), findsOneWidget);
      expect(find.textContaining('user role does not possess permissions'), findsOneWidget);
    });

    testWidgets('InlineLoader renders with custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineLoader(size: 28),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
