import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'workout_models.dart';

final exercisesProvider = FutureProvider.family<List<ExerciseModel>, String?>((ref, category) async {
  final client = ref.read(apiClientProvider);
  final queryParams = <String, dynamic>{};
  if (category != null && category != 'All') {
    queryParams['category'] = category;
  }
  final response = await client.dio.get(ApiConstants.exercises, queryParameters: queryParams);
  final list = response.data as List;
  return list.map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>)).toList();
});

final exerciseCategoriesProvider = FutureProvider<List<ExerciseCategoryModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.exerciseCategories);
  final list = response.data as List;
  return list.map((item) => ExerciseCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
});

final workoutTemplatesProvider = FutureProvider<List<WorkoutTemplateModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get(ApiConstants.workoutTemplates);
  final list = response.data as List;
  return list.map((item) => WorkoutTemplateModel.fromJson(item as Map<String, dynamic>)).toList();
});

final workoutSchedulesProvider = FutureProvider.family<List<MemberWorkoutScheduleModel>, String?>((ref, memberId) async {
  final client = ref.read(apiClientProvider);
  final queryParams = <String, dynamic>{};
  if (memberId != null) queryParams['memberId'] = memberId;
  final response = await client.dio.get(ApiConstants.workoutSchedules, queryParameters: queryParams);
  final list = response.data as List;
  return list.map((item) => MemberWorkoutScheduleModel.fromJson(item as Map<String, dynamic>)).toList();
});

class WorkoutActionService {
  final Ref ref;

  WorkoutActionService(this.ref);

  Future<bool> createExercise(Map<String, dynamic> data) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(ApiConstants.exercises, data: data);
      ref.invalidate(exercisesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteExercise(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.delete('${ApiConstants.exercises}/$id');
      ref.invalidate(exercisesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createTemplate(Map<String, dynamic> data) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(ApiConstants.workoutTemplates, data: data);
      ref.invalidate(workoutTemplatesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignSchedule(Map<String, dynamic> data) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post(ApiConstants.assignWorkoutSchedule, data: data);
      ref.invalidate(workoutSchedulesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> triggerWorkoutDeliveryNow(String scheduleId) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post('${ApiConstants.workoutSchedules}/$scheduleId/send-now');
      return true;
    } catch (_) {
      return false;
    }
  }
}

final workoutActionProvider = Provider<WorkoutActionService>((ref) {
  return WorkoutActionService(ref);
});

