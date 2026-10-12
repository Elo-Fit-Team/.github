class WeeklyProgressModel {
  final String weekStart;
  final int completedWorkouts;
  final bool claimed;
  final bool rewardActive;

  WeeklyProgressModel({
    required this.weekStart,
    required this.completedWorkouts,
    required this.claimed,
    required this.rewardActive,
  });

  factory WeeklyProgressModel.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressModel(
      weekStart: json['week_start'] as String? ?? '',
      completedWorkouts: json['completed_workouts'] is int ? json['completed_workouts'] : 0,
      claimed: json['claimed'] as bool? ?? false,
      rewardActive: json['reward_active'] as bool? ?? false,
    );
  }
}

class WeeklyChallengeModel {
  final int id;
  final String name;
  final String description;
  final int requiredWorkouts;
  final int coinReward;
  final int xpReward;
  final bool isActive;
  final WeeklyProgressModel? progress;

  WeeklyChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredWorkouts,
    required this.coinReward,
    required this.xpReward,
    required this.isActive,
    this.progress,
  });

  factory WeeklyChallengeModel.fromJson(Map<String, dynamic> json) {
    return WeeklyChallengeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'Weekly Challenge',
      description: json['description'] as String? ?? '',
      requiredWorkouts: json['required_workouts'] is int ? json['required_workouts'] : 3,
      coinReward: json['coin_reward'] is int ? json['coin_reward'] : 50,
      xpReward: json['xp_reward'] is int ? json['xp_reward'] : 100,
      isActive: json['is_active'] as bool? ?? true,
      progress: json['progress'] != null
          ? WeeklyProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
    );
  }
}
