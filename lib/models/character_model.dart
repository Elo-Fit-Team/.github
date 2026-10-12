class CharacterModel {
  final int id;
  final String slug;
  final String name;
  final String story;
  final String specialty;
  final int bonusPercent;
  final String portraitUrl;
  final String modelUrl;
  final bool isStarter;
  final int coinCost;
  final int requiredWorkouts;

  CharacterModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.story,
    required this.specialty,
    required this.bonusPercent,
    required this.portraitUrl,
    required this.modelUrl,
    required this.isStarter,
    required this.coinCost,
    required this.requiredWorkouts,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      story: json['story'] as String? ?? '',
      specialty: json['specialty'] as String? ?? 'strength',
      bonusPercent: json['bonus_percent'] is int ? json['bonus_percent'] : 0,
      portraitUrl: json['portrait_url'] as String? ?? '',
      modelUrl: json['model_url'] as String? ?? '',
      isStarter: json['is_starter'] as bool? ?? false,
      coinCost: json['coin_cost'] is int ? json['coin_cost'] : 0,
      requiredWorkouts: json['required_workouts'] is int ? json['required_workouts'] : 0,
    );
  }
}

class CharacterProgressModel {
  final int xp;
  final int level;
  final int levelFloorXp;
  final int? nextLevelXp;
  final int health;
  final String portraitUrl;
  final int strength;
  final int endurance;
  final int flexibility;

  CharacterProgressModel({
    required this.xp,
    required this.level,
    required this.levelFloorXp,
    this.nextLevelXp,
    required this.health,
    required this.portraitUrl,
    required this.strength,
    required this.endurance,
    required this.flexibility,
  });

  factory CharacterProgressModel.fromJson(Map<String, dynamic> json) {
    return CharacterProgressModel(
      xp: json['xp'] is int ? json['xp'] : 0,
      level: json['level'] is int ? json['level'] : 1,
      levelFloorXp: json['level_floor_xp'] is int ? json['level_floor_xp'] : 0,
      nextLevelXp: json['next_level_xp'] is int ? json['next_level_xp'] : null,
      health: json['health'] is int ? json['health'] : 100,
      portraitUrl: json['portrait_url'] as String? ?? '',
      strength: json['strength'] is int ? json['strength'] : 10,
      endurance: json['endurance'] is int ? json['endurance'] : 10,
      flexibility: json['flexibility'] is int ? json['flexibility'] : 10,
    );
  }

  double get progressRatio {
    if (nextLevelXp == null || nextLevelXp! <= levelFloorXp) return 1.0;
    final current = xp - levelFloorXp;
    final total = nextLevelXp! - levelFloorXp;
    if (total <= 0) return 1.0;
    return (current / total).clamp(0.0, 1.0);
  }
}

class OwnedCharacterModel {
  final int id;
  final CharacterModel character;
  final String? acquiredAt;
  final CharacterProgressModel progress;

  OwnedCharacterModel({
    required this.id,
    required this.character,
    this.acquiredAt,
    required this.progress,
  });

  factory OwnedCharacterModel.fromJson(Map<String, dynamic> json) {
    return OwnedCharacterModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      character: CharacterModel.fromJson(json['character'] as Map<String, dynamic>? ?? {}),
      acquiredAt: json['acquired_at'] as String?,
      progress: CharacterProgressModel.fromJson(json['progress'] as Map<String, dynamic>? ?? {}),
    );
  }
}
