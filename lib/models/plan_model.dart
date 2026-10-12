class PlanExerciseModel {
  final int exercise;
  final int position;
  final int sets;
  final int repetitions;
  final int durationSeconds;

  PlanExerciseModel({
    required this.exercise,
    required this.position,
    required this.sets,
    required this.repetitions,
    required this.durationSeconds,
  });

  factory PlanExerciseModel.fromJson(Map<String, dynamic> json) {
    return PlanExerciseModel(
      exercise: json['exercise'] is int ? json['exercise'] : 0,
      position: json['position'] is int ? json['position'] : 1,
      sets: json['sets'] is int ? json['sets'] : 3,
      repetitions: json['repetitions'] is int ? json['repetitions'] : 10,
      durationSeconds: json['duration_seconds'] is int ? json['duration_seconds'] : 0,
    );
  }
}

class PlanModel {
  final int id;
  final String name;
  final String description;
  final int estimatedMinutes;
  final String difficulty;
  final String category;
  final List<PlanExerciseModel> exercises;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedMinutes,
    this.difficulty = 'Medium',
    this.category = 'Strength',
    required this.exercises,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List? ?? [];
    final nameStr = json['name'] as String? ?? 'Workout Plan';
    
    // Auto-detect category & difficulty
    String cat = 'Strength';
    String diff = 'Medium';
    final lower = nameStr.toLowerCase();
    if (lower.contains('кардио') || lower.contains('cardio') || lower.contains('вынослив')) {
      cat = 'Cardio';
      diff = 'High';
    } else if (lower.contains('базов') || lower.contains('beginner') || lower.contains('split')) {
      diff = 'Easy';
    } else if (lower.contains('power') || lower.contains('тяжел')) {
      diff = 'Hard';
    }

    return PlanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: nameStr,
      description: json['description'] as String? ?? 'Comprehensive workout plan',
      estimatedMinutes: json['estimated_minutes'] is int ? json['estimated_minutes'] : 35,
      difficulty: diff,
      category: cat,
      exercises: rawExercises
          .map((e) => PlanExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
