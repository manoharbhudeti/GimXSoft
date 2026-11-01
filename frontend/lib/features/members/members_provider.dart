import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../auth/auth_provider.dart';
import 'member_models.dart';

class MemberSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final memberSearchQueryProvider = NotifierProvider<MemberSearchNotifier, String>(MemberSearchNotifier.new);

class MemberStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? s) => state = s;
}

final memberStatusFilterProvider = NotifierProvider<MemberStatusFilterNotifier, String?>(MemberStatusFilterNotifier.new);

final membersListProvider = FutureProvider.autoDispose<List<MemberModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider);
  final statusFilter = ref.watch(memberStatusFilterProvider);

  final queryParams = <String, dynamic>{};
  if (authState.selectedBranch?.id != null) {
    queryParams['branchId'] = authState.selectedBranch!.id;
  }
  if (searchQuery.isNotEmpty) {
    queryParams['search'] = searchQuery;
  }
  if (statusFilter != null && statusFilter != 'All') {
    queryParams['status'] = statusFilter;
  }

  final response = await apiClient.dio.get(
    ApiConstants.members,
    queryParameters: queryParams,
  );

  return (response.data as List)
      .map((item) => MemberModel.fromJson(item))
      .toList();
});

final memberDetailProvider = FutureProvider.autoDispose.family<MemberDetailModel, String>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('${ApiConstants.members}/$id');
  return MemberDetailModel.fromJson(response.data);
});
