class MemberMeasurementModel {
  final String id;
  final String memberId;
  final String memberName;
  final double weightKg;
  final double heightCm;
  final double calculatedBmi;
  final double? waistCm;
  final double? chestCm;
  final double? hipCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftThighCm;
  final double? rightThighCm;
  final double? bodyFatPercentage;
  final String inputUnitSystem;
  final DateTime measurementDate;
  final String? recordedByUserId;
  final String? recordedByUserName;
  final String? notes;
  final double? weightDifferenceKg;
  final double? weightChangePercent;
  final DateTime createdAt;

  MemberMeasurementModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.weightKg,
    required this.heightCm,
    required this.calculatedBmi,
    this.waistCm,
    this.chestCm,
    this.hipCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
    this.bodyFatPercentage,
    required this.inputUnitSystem,
    required this.measurementDate,
    this.recordedByUserId,
    this.recordedByUserName,
    this.notes,
    this.weightDifferenceKg,
    this.weightChangePercent,
    required this.createdAt,
  });

  factory MemberMeasurementModel.fromJson(Map<String, dynamic> json) {
    return MemberMeasurementModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      calculatedBmi: (json['calculatedBmi'] as num?)?.toDouble() ?? 22.0,
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      chestCm: (json['chestCm'] as num?)?.toDouble(),
      hipCm: (json['hipCm'] as num?)?.toDouble(),
      leftArmCm: (json['leftArmCm'] as num?)?.toDouble(),
      rightArmCm: (json['rightArmCm'] as num?)?.toDouble(),
      leftThighCm: (json['leftThighCm'] as num?)?.toDouble(),
      rightThighCm: (json['rightThighCm'] as num?)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      inputUnitSystem: json['inputUnitSystem'] as String? ?? 'Metric',
      measurementDate: DateTime.tryParse(json['measurementDate'] as String? ?? '') ?? DateTime.now(),
      recordedByUserId: json['recordedByUserId'] as String?,
      recordedByUserName: json['recordedByUserName'] as String?,
      notes: json['notes'] as String?,
      weightDifferenceKg: (json['weightDifferenceKg'] as num?)?.toDouble(),
      weightChangePercent: (json['weightChangePercent'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class WeightDataPointModel {
  final DateTime date;
  final double weightKg;
  final double bmi;

  WeightDataPointModel({
    required this.date,
    required this.weightKg,
    required this.bmi,
  });

  factory WeightDataPointModel.fromJson(Map<String, dynamic> json) {
    return WeightDataPointModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MeasurementHistoryPointModel {
  final DateTime date;
  final double? waistCm;
  final double? chestCm;
  final double? hipCm;
  final double? bodyFatPercentage;

  MeasurementHistoryPointModel({
    required this.date,
    this.waistCm,
    this.chestCm,
    this.hipCm,
    this.bodyFatPercentage,
  });

  factory MeasurementHistoryPointModel.fromJson(Map<String, dynamic> json) {
    return MeasurementHistoryPointModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      chestCm: (json['chestCm'] as num?)?.toDouble(),
      hipCm: (json['hipCm'] as num?)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
    );
  }
}

class FitnessProgressCardModel {
  final String memberId;
  final String memberName;
  final String memberCode;
  final String? avatarUrl;
  final String fitnessGoal;
  final String fitnessLevel;
  final double baselineWeightKg;
  final double currentWeightKg;
  final double totalWeightChangeKg;
  final double weightChangePercentage;
  final double currentBmi;
  final String bmiCategory;
  final DateTime? lastMeasurementDate;
  final List<WeightDataPointModel> weightHistory;
  final List<MeasurementHistoryPointModel> measurementTrends;
  final bool hasOverdueReview;

  FitnessProgressCardModel({
    required this.memberId,
    required this.memberName,
    required this.memberCode,
    this.avatarUrl,
    required this.fitnessGoal,
    required this.fitnessLevel,
    required this.baselineWeightKg,
    required this.currentWeightKg,
    required this.totalWeightChangeKg,
    required this.weightChangePercentage,
    required this.currentBmi,
    required this.bmiCategory,
    this.lastMeasurementDate,
    required this.weightHistory,
    required this.measurementTrends,
    required this.hasOverdueReview,
  });

  factory FitnessProgressCardModel.fromJson(Map<String, dynamic> json) {
    final wList = (json['weightHistory'] as List? ?? [])
        .map((item) => WeightDataPointModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final mList = (json['measurementTrends'] as List? ?? [])
        .map((item) => MeasurementHistoryPointModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return FitnessProgressCardModel(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      memberCode: json['memberCode'] as String? ?? 'GIX',
      avatarUrl: json['avatarUrl'] as String?,
      fitnessGoal: json['fitnessGoal'] as String? ?? 'General Fitness',
      fitnessLevel: json['fitnessLevel'] as String? ?? 'Beginner',
      baselineWeightKg: (json['baselineWeightKg'] as num?)?.toDouble() ?? 75.0,
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble() ?? 75.0,
      totalWeightChangeKg: (json['totalWeightChangeKg'] as num?)?.toDouble() ?? 0.0,
      weightChangePercentage: (json['weightChangePercentage'] as num?)?.toDouble() ?? 0.0,
      currentBmi: (json['currentBmi'] as num?)?.toDouble() ?? 22.0,
      bmiCategory: json['bmiCategory'] as String? ?? 'Normal Weight',
      lastMeasurementDate: json['lastMeasurementDate'] != null
          ? DateTime.tryParse(json['lastMeasurementDate'] as String)
          : null,
      weightHistory: wList,
      measurementTrends: mList,
      hasOverdueReview: json['hasOverdueReview'] as bool? ?? false,
    );
  }
}

class MemberFitnessBaselineModel {
  final String id;
  final String memberId;
  final String memberName;
  final double initialWeightKg;
  final double heightCm;
  final double initialBmi;
  final DateTime initialMeasurementDate;
  final String fitnessGoal;
  final String fitnessLevel;
  final int trainingFrequencyDaysPerWeek;
  final String? medicalAndDietNotes;

  MemberFitnessBaselineModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.initialWeightKg,
    required this.heightCm,
    required this.initialBmi,
    required this.initialMeasurementDate,
    required this.fitnessGoal,
    required this.fitnessLevel,
    required this.trainingFrequencyDaysPerWeek,
    this.medicalAndDietNotes,
  });

  factory MemberFitnessBaselineModel.fromJson(Map<String, dynamic> json) {
    return MemberFitnessBaselineModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble() ?? 75.0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      initialBmi: (json['initialBmi'] as num?)?.toDouble() ?? 22.0,
      initialMeasurementDate: DateTime.tryParse(json['initialMeasurementDate'] as String? ?? '') ?? DateTime.now(),
      fitnessGoal: json['fitnessGoal'] as String? ?? 'General Fitness',
      fitnessLevel: json['fitnessLevel'] as String? ?? 'Beginner',
      trainingFrequencyDaysPerWeek: (json['trainingFrequencyDaysPerWeek'] as num?)?.toInt() ?? 4,
      medicalAndDietNotes: json['medicalAndDietNotes'] as String?,
    );
  }
}

class MemberOnboardingJourneyModel {
  final String id;
  final String memberId;
  final String memberName;
  final bool registrationCompleted;
  final DateTime? registrationCompletedAt;
  final bool consentCollected;
  final DateTime? consentCollectedAt;
  final bool welcomeSent;
  final DateTime? welcomeSentAt;
  final bool assessmentCompleted;
  final DateTime? assessmentCompletedAt;
  final bool initialMeasurementDone;
  final DateTime? initialMeasurementDoneAt;
  final bool trainerAssigned;
  final DateTime? trainerAssignedAt;
  final bool workoutPlanAssigned;
  final DateTime? workoutPlanAssignedAt;
  final bool firstWorkoutDelivered;
  final DateTime? firstWorkoutDeliveredAt;
  final bool firstWeekReviewDone;
  final DateTime? firstWeekReviewDoneAt;
  final String? notes;
  final DateTime updatedAt;

  MemberOnboardingJourneyModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.registrationCompleted,
    this.registrationCompletedAt,
    required this.consentCollected,
    this.consentCollectedAt,
    required this.welcomeSent,
    this.welcomeSentAt,
    required this.assessmentCompleted,
    this.assessmentCompletedAt,
    required this.initialMeasurementDone,
    this.initialMeasurementDoneAt,
    required this.trainerAssigned,
    this.trainerAssignedAt,
    required this.workoutPlanAssigned,
    this.workoutPlanAssignedAt,
    required this.firstWorkoutDelivered,
    this.firstWorkoutDeliveredAt,
    required this.firstWeekReviewDone,
    this.firstWeekReviewDoneAt,
    this.notes,
    required this.updatedAt,
  });

  factory MemberOnboardingJourneyModel.fromJson(Map<String, dynamic> json) {
    return MemberOnboardingJourneyModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      registrationCompleted: json['registrationCompleted'] as bool? ?? true,
      registrationCompletedAt: json['registrationCompletedAt'] != null ? DateTime.tryParse(json['registrationCompletedAt'] as String) : null,
      consentCollected: json['consentCollected'] as bool? ?? true,
      consentCollectedAt: json['consentCollectedAt'] != null ? DateTime.tryParse(json['consentCollectedAt'] as String) : null,
      welcomeSent: json['welcomeSent'] as bool? ?? true,
      welcomeSentAt: json['welcomeSentAt'] != null ? DateTime.tryParse(json['welcomeSentAt'] as String) : null,
      assessmentCompleted: json['assessmentCompleted'] as bool? ?? false,
      assessmentCompletedAt: json['assessmentCompletedAt'] != null ? DateTime.tryParse(json['assessmentCompletedAt'] as String) : null,
      initialMeasurementDone: json['initialMeasurementDone'] as bool? ?? false,
      initialMeasurementDoneAt: json['initialMeasurementDoneAt'] != null ? DateTime.tryParse(json['initialMeasurementDoneAt'] as String) : null,
      trainerAssigned: json['trainerAssigned'] as bool? ?? false,
      trainerAssignedAt: json['trainerAssignedAt'] != null ? DateTime.tryParse(json['trainerAssignedAt'] as String) : null,
      workoutPlanAssigned: json['workoutPlanAssigned'] as bool? ?? false,
      workoutPlanAssignedAt: json['workoutPlanAssignedAt'] != null ? DateTime.tryParse(json['workoutPlanAssignedAt'] as String) : null,
      firstWorkoutDelivered: json['firstWorkoutDelivered'] as bool? ?? false,
      firstWorkoutDeliveredAt: json['firstWorkoutDeliveredAt'] != null ? DateTime.tryParse(json['firstWorkoutDeliveredAt'] as String) : null,
      firstWeekReviewDone: json['firstWeekReviewDone'] as bool? ?? false,
      firstWeekReviewDoneAt: json['firstWeekReviewDoneAt'] != null ? DateTime.tryParse(json['firstWeekReviewDoneAt'] as String) : null,
      notes: json['notes'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
