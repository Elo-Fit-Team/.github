import 'character_model.dart';

class PlayerProfileModel {
  final int? city;
  final String gender;
  final String? birthDate;
  final String? bodyWeightKg;
  final int? activeCharacter;
  final bool starterClaimed;

  PlayerProfileModel({
    this.city,
    required this.gender,
    this.birthDate,
    this.bodyWeightKg,
    this.activeCharacter,
    required this.starterClaimed,
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      city: json['city'] is int ? json['city'] : null,
      gender: json['gender'] as String? ?? 'unspecified',
      birthDate: json['birth_date'] as String?,
      bodyWeightKg: json['body_weight_kg']?.toString(),
      activeCharacter: json['active_character'] is int ? json['active_character'] : null,
      starterClaimed: json['starter_claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (city != null) 'city': city,
    'gender': gender,
    if (birthDate != null) 'birth_date': birthDate,
    if (bodyWeightKg != null) 'body_weight_kg': bodyWeightKg,
  };
}

class BalancesModel {
  final int elo;
  final int xp;
  final int coins;
  final int reputation;
  final int strength;
  final int endurance;
  final int flexibility;

  BalancesModel({
    required this.elo,
    required this.xp,
    required this.coins,
    required this.reputation,
    required this.strength,
    required this.endurance,
    required this.flexibility,
  });

  factory BalancesModel.fromJson(Map<String, dynamic> json) {
    return BalancesModel(
      elo: json['elo'] is int ? json['elo'] : 1000,
      xp: json['xp'] is int ? json['xp'] : 0,
      coins: json['coins'] is int ? json['coins'] : 0,
      reputation: json['reputation'] is int ? json['reputation'] : 0,
      strength: json['strength'] is int ? json['strength'] : 0,
      endurance: json['endurance'] is int ? json['endurance'] : 0,
      flexibility: json['flexibility'] is int ? json['flexibility'] : 0,
    );
  }
}

class HubDataModel {
  final PlayerProfileModel profile;
  final BalancesModel balances;
  final OwnedCharacterModel? activeCharacter;
  final int confirmedWorkouts;
  final int unreadNotifications;

  HubDataModel({
    required this.profile,
    required this.balances,
    this.activeCharacter,
    required this.confirmedWorkouts,
    required this.unreadNotifications,
  });

  factory HubDataModel.fromJson(Map<String, dynamic> json) {
    return HubDataModel(
      profile: PlayerProfileModel.fromJson(json['profile'] as Map<String, dynamic>? ?? {}),
      balances: BalancesModel.fromJson(json['balances'] as Map<String, dynamic>? ?? {}),
      activeCharacter: json['active_character'] != null
          ? OwnedCharacterModel.fromJson(json['active_character'] as Map<String, dynamic>)
          : null,
      confirmedWorkouts: json['confirmed_workouts'] is int ? json['confirmed_workouts'] : 0,
      unreadNotifications: json['unread_notifications'] is int ? json['unread_notifications'] : 0,
    );
  }
}
