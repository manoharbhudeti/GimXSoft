class ExerciseModel {
  final String id;
  final String tenantId;
  final String name;
  final String description;
  final String category;
  final String targetMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final String difficultyLevel;
  final String instructions;
  final int defaultSets;
  final String defaultReps;
  final int defaultRestSeconds;
  final int? durationSeconds;
  final String? demoImageUrl;
  final String? demoVideoUrl;
  final String? safetyNotes;
  final bool isActive;
  final DateTime createdAt;

  ExerciseModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.category,
    required this.targetMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficultyLevel,
    required this.instructions,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultRestSeconds,
    this.durationSeconds,
    this.demoImageUrl,
    this.demoVideoUrl,
    this.safetyNotes,
    required this.isActive,
    required this.createdAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    List<String> sec = [];
    if (json['secondaryMusclesJson'] != null) {
      try {
        final parsed = json['secondaryMusclesJson'] as String;
        sec = parsed.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      } catch (_) {}
    }

    return ExerciseModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Strength',
      targetMuscle: json['targetMuscle'] as String? ?? 'Chest',
      secondaryMuscles: sec,
      equipment: json['equipment'] as String? ?? 'Barbell',
      difficultyLevel: json['difficultyLevel'] as String? ?? 'Intermediate',
      instructions: json['instructions'] as String? ?? '',
      defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: json['defaultReps'] as String? ?? '10-12',
      defaultRestSeconds: (json['defaultRestSeconds'] as num?)?.toInt() ?? 60,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      demoImageUrl: json['demoImageUrl'] as String?,
      demoVideoUrl: json['demoVideoUrl'] as String?,
      safetyNotes: json['safetyNotes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ExerciseCategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconName;

  ExerciseCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
  });

  factory ExerciseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'dumbbell',
    );
  }
}

class WorkoutTemplateModel {
  final String id;
  final String tenantId;
  final String title;
  final String description;
  final String goal;
  final String level;
  final int daysPerWeek;
  final int estimatedMinutesPerSession;
  final String routineJson;
  final String? createdByUserId;
  final DateTime createdAt;

  WorkoutTemplateModel({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.estimatedMinutesPerSession,
    required this.routineJson,
    this.createdByUserId,
    required this.createdAt,
  });

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      goal: json['goal'] as String? ?? 'Muscle Building',
      level: json['level'] as String? ?? 'Intermediate',
      daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 4,
      estimatedMinutesPerSession: (json['estimatedMinutesPerSession'] as num?)?.toInt() ?? 45,
      routineJson: json['routineJson'] as String? ?? '[]',
      createdByUserId: json['createdByUserId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class MemberWorkoutScheduleModel {
  final String id;
  final String memberId;
  final String memberName;
  final String? workoutTemplateId;
  final String? templateTitle;
  final String? assignedTrainerId;
  final String? trainerName;
  final String dayOfWeek;
  final String scheduledDeliveryTime;
  final String routineTitle;
  final String exercisesJson;
  final bool isRestDay;
  final bool trainerApproved;
  final bool isActive;
  final String? trainerNotes;
  final DateTime updatedAt;

  MemberWorkoutScheduleModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    this.workoutTemplateId,
    this.templateTitle,
    this.assignedTrainerId,
    this.trainerName,
    required this.dayOfWeek,
    required this.scheduledDeliveryTime,
    required this.routineTitle,
    required this.exercisesJson,
    required this.isRestDay,
    required this.trainerApproved,
    required this.isActive,
    this.trainerNotes,
    required this.updatedAt,
  });

  factory MemberWorkoutScheduleModel.fromJson(Map<String, dynamic> json) {
    return MemberWorkoutScheduleModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      workoutTemplateId: json['workoutTemplateId'] as String?,
      templateTitle: json['templateTitle'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String?,
      trainerName: json['trainerName'] as String?,
      dayOfWeek: json['dayOfWeek'] as String? ?? 'Monday',
      scheduledDeliveryTime: json['scheduledDeliveryTime'] as String? ?? '07:00',
      routineTitle: json['routineTitle'] as String? ?? 'Daily Workout',
      exercisesJson: json['exercisesJson'] as String? ?? '[]',
      isRestDay: json['isRestDay'] as bool? ?? false,
      trainerApproved: json['trainerApproved'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      trainerNotes: json['trainerNotes'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
