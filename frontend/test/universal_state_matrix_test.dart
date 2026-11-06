import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/states/universal/universal_state.dart';
import 'package:frontend/core/states/universal/universal_state_priority_resolver.dart';
import 'package:frontend/core/states/universal/permission_interlock.dart';

void main() {
  group('Universal State Priority Resolver Tests', () {
    test('Critical Error takes priority over Network and Auth', () {
      const ctx = StateResolutionContext(
        isMaintenance: true,
        isOffline: true,
        isSessionExpired: true,
        isLoading: true,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.maintenance));
    });

    test('Network Outage takes priority over Auth and Data Views', () {
      const ctx = StateResolutionContext(
        isOffline: true,
        isForbidden: true,
        isEmpty: true,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.noInternet));
    });

    test('HTTP 429 resolves to rateLimited', () {
      const ctx = StateResolutionContext(
        httpStatusCode: 429,
        rateLimitResetSeconds: 30,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.rateLimited));
    });

    test('HTTP 401 resolves to sessionExpired over loading', () {
      const ctx = StateResolutionContext(
        httpStatusCode: 401,
        isLoading: true,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.sessionExpired));
    });

    test('HTTP 403 resolves to permissionDenied', () {
      const ctx = StateResolutionContext(
        httpStatusCode: 403,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.permissionDenied));
    });

    test('Unsaved changes takes priority over empty data view', () {
      const ctx = StateResolutionContext(
        hasUnsavedChanges: true,
        isEmpty: true,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.unsavedChanges));
    });

    test('Empty container with no errors resolves to empty', () {
      const ctx = StateResolutionContext(
        isEmpty: true,
      );

      final state = UniversalStatePriorityResolver.resolve(ctx);
      expect(state, equals(UniversalState.empty));
    });
  });

  group('Permission Interlock Requirement Tests', () {
    test('Destructive delete factory requires typed confirmation', () {
      final req = PermissionRequirement.destructiveDelete(
        resourceName: 'Titan Downtown Branch',
        resourceIdentifier: 'DELETE-DOWNTOWN',
      );

      expect(req.severity, equals(MutationSeverity.high));
      expect(req.requiresTypedConfirmation, isTrue);
      expect(req.expectedConfirmationPhrase, equals('DELETE-DOWNTOWN'));
    });

    test('Elevated action does not require typed confirmation', () {
      final req = PermissionRequirement.elevatedAction(
        actionTitle: 'Batch Invoice Recalculation',
        description: 'Recalculate invoices for fiscal year 2026',
        consequenceText: 'Modifies pending payment line items',
      );

      expect(req.severity, equals(MutationSeverity.medium));
      expect(req.requiresTypedConfirmation, isFalse);
    });
  });
}

