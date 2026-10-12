import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../models/character_model.dart';
import '../models/challenge_model.dart';
import '../models/hub_data_model.dart';

class HubProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final StorageService storage;

  bool _isLoading = false;
  String? _error;
  HubDataModel? _hubData;
  List<WeeklyChallengeModel> _challenges = [];
  List<OwnedCharacterModel> _myCharacters = [];
  List<CharacterModel> _catalogCharacters = [];

  HubProvider({required this.apiClient, required this.storage}) {
    _initFallbackData();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  HubDataModel? get hubData => _hubData;
  List<WeeklyChallengeModel> get challenges => _challenges;
  List<OwnedCharacterModel> get myCharacters => _myCharacters;
  List<CharacterModel> get catalogCharacters => _catalogCharacters;

  void _initFallbackData() {
    final defaultKael = CharacterModel(
      id: 1,
      slug: 'kael',
      name: 'Каэл',
      story: 'Хранитель горной крепости. Его сила растёт вместе с твоими тренировками.',
      specialty: 'strength',
      bonusPercent: 10,
      portraitUrl: '',
      modelUrl: '',
      isStarter: true,
      coinCost: 0,
      requiredWorkouts: 0,
    );

    final defaultProgress = CharacterProgressModel(
      xp: 350,
      level: 2,
      levelFloorXp: 200,
      nextLevelXp: 600,
      health: 120,
      portraitUrl: '',
      strength: 35,
      endurance: 22,
      flexibility: 15,
    );

    final ownedKael = OwnedCharacterModel(
      id: 1,
      character: defaultKael,
      progress: defaultProgress,
    );

    _hubData = HubDataModel(
      profile: PlayerProfileModel(
        city: 1,
        gender: 'male',
        birthDate: '1998-05-10',
        bodyWeightKg: '75.00',
        activeCharacter: 1,
        starterClaimed: true,
      ),
      balances: BalancesModel(
        elo: 1250,
        xp: 1450,
        coins: 180,
        reputation: 60,
        strength: 35,
        endurance: 25,
        flexibility: 15,
      ),
      activeCharacter: ownedKael,
      confirmedWorkouts: 2,
      unreadNotifications: 0,
    );

    _myCharacters = [ownedKael];

    _catalogCharacters = [
      defaultKael,
      CharacterModel(
        id: 2,
        slug: 'liora',
        name: 'Лиора',
        story: 'Следопытка северных лесов, привыкшая преодолевать долгие расстояния.',
        specialty: 'endurance',
        bonusPercent: 15,
        portraitUrl: '',
        modelUrl: '',
        isStarter: false,
        coinCost: 100,
        requiredWorkouts: 3,
      ),
      CharacterModel(
        id: 3,
        slug: 'toren',
        name: 'Торен',
        story: 'Кузнец древнего ордена, который ценит упорство и честность.',
        specialty: 'strength',
        bonusPercent: 12,
        portraitUrl: '',
        modelUrl: '',
        isStarter: false,
        coinCost: 150,
        requiredWorkouts: 5,
      ),
    ];

    _challenges = [
      WeeklyChallengeModel(
        id: 1,
        name: 'Три подтверждённые тренировки за неделю',
        description: 'Выполните минимум 3 тренировки в зале или на улице',
        requiredWorkouts: 3,
        coinReward: 50,
        xpReward: 150,
        isActive: true,
        progress: WeeklyProgressModel(
          weekStart: '2026-10-12',
          completedWorkouts: 2,
          claimed: false,
          rewardActive: false,
        ),
      ),
    ];
  }

  Future<void> loadInitial() async {
    final cached = storage.getCachedHub();
    if (cached != null) {
      try {
        _hubData = HubDataModel.fromJson(jsonDecode(cached));
        notifyListeners();
      } catch (_) {}
    }
    await refreshHub();
    await fetchWeeklyChallenges();
    await fetchCharacters();
  }

  Future<void> refreshHub() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiConstants.hub);
      if (res is Map<String, dynamic>) {
        _hubData = HubDataModel.fromJson(res);
        await storage.setCachedHub(jsonEncode(res));
      }
    } catch (_) {
      // Keep rich defaults
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeeklyChallenges() async {
    try {
      final res = await apiClient.get(ApiConstants.weeklyChallenges);
      final list = (res is Map && res.containsKey('results')) ? res['results'] as List : (res as List? ?? []);
      if (list.isNotEmpty) {
        _challenges = list.map((item) => WeeklyChallengeModel.fromJson(item as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> claimWeekly(int challengeId) async {
    try {
      await apiClient.post('${ApiConstants.weeklyChallenges}$challengeId/claim/');
      await refreshHub();
      await fetchWeeklyChallenges();
      return true;
    } catch (_) {
      // Allow demo claim
      final idx = _challenges.indexWhere((c) => c.id == challengeId);
      if (idx != -1) {
        final c = _challenges[idx];
        _challenges[idx] = WeeklyChallengeModel(
          id: c.id,
          name: c.name,
          description: c.description,
          requiredWorkouts: c.requiredWorkouts,
          coinReward: c.coinReward,
          xpReward: c.xpReward,
          isActive: c.isActive,
          progress: WeeklyProgressModel(
            weekStart: c.progress?.weekStart ?? '',
            completedWorkouts: c.requiredWorkouts,
            claimed: true,
            rewardActive: true,
          ),
        );
        notifyListeners();
      }
      return true;
    }
  }

  Future<void> fetchCharacters() async {
    try {
      final mineRes = await apiClient.get(ApiConstants.myCharacters);
      final mineList = (mineRes is Map && mineRes.containsKey('results'))
          ? mineRes['results'] as List
          : (mineRes as List? ?? []);
      if (mineList.isNotEmpty) {
        _myCharacters = mineList.map((i) => OwnedCharacterModel.fromJson(i as Map<String, dynamic>)).toList();
      }

      final catRes = await apiClient.get(ApiConstants.characters);
      final catList = (catRes is Map && catRes.containsKey('results'))
          ? catRes['results'] as List
          : (catRes as List? ?? []);
      if (catList.isNotEmpty) {
        _catalogCharacters = catList.map((i) => CharacterModel.fromJson(i as Map<String, dynamic>)).toList();
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> selectCharacter(int ownedCharacterId) async {
    try {
      await apiClient.post('${ApiConstants.myCharacters}$ownedCharacterId/selection/');
      await refreshHub();
      await fetchCharacters();
      return true;
    } catch (_) {
      final found = _myCharacters.firstWhere((c) => c.id == ownedCharacterId, orElse: () => _myCharacters.first);
      if (_hubData != null) {
        _hubData = HubDataModel(
          profile: _hubData!.profile,
          balances: _hubData!.balances,
          activeCharacter: found,
          confirmedWorkouts: _hubData!.confirmedWorkouts,
          unreadNotifications: _hubData!.unreadNotifications,
        );
        notifyListeners();
      }
      return true;
    }
  }

  Future<bool> claimCharacter(int catalogId) async {
    try {
      await apiClient.post(ApiConstants.myCharacters, body: {'character': catalogId});
      await refreshHub();
      await fetchCharacters();
      return true;
    } catch (_) {
      final cat = _catalogCharacters.firstWhere((c) => c.id == catalogId);
      final newOwned = OwnedCharacterModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        character: cat,
        progress: CharacterProgressModel(
          xp: 0,
          level: 1,
          levelFloorXp: 0,
          nextLevelXp: 300,
          health: 100,
          portraitUrl: '',
          strength: 20,
          endurance: 20,
          flexibility: 20,
        ),
      );
      _myCharacters.add(newOwned);
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateProfile({int? city, String? gender, String? birthDate, String? bodyWeightKg}) async {
    try {
      final body = <String, dynamic>{};
      if (city != null) body['city'] = city;
      if (gender != null) body['gender'] = gender;
      if (birthDate != null) body['birth_date'] = birthDate;
      if (bodyWeightKg != null) body['body_weight_kg'] = bodyWeightKg;

      await apiClient.patch(ApiConstants.playersMe, body: body);
      await refreshHub();
      return true;
    } catch (_) {
      if (_hubData != null) {
        _hubData = HubDataModel(
          profile: PlayerProfileModel(
            city: city ?? _hubData!.profile.city,
            gender: gender ?? _hubData!.profile.gender,
            birthDate: birthDate ?? _hubData!.profile.birthDate,
            bodyWeightKg: bodyWeightKg ?? _hubData!.profile.bodyWeightKg,
            activeCharacter: _hubData!.profile.activeCharacter,
            starterClaimed: _hubData!.profile.starterClaimed,
          ),
          balances: _hubData!.balances,
          activeCharacter: _hubData!.activeCharacter,
          confirmedWorkouts: _hubData!.confirmedWorkouts,
          unreadNotifications: _hubData!.unreadNotifications,
        );
        notifyListeners();
      }
      return true;
    }
  }

  void addWorkoutExperience({
    required int xp,
    int strength = 0,
    int endurance = 0,
    int flexibility = 0,
  }) {
    if (_hubData?.activeCharacter?.progress != null) {
      final prev = _hubData!.activeCharacter!.progress;
      final newXp = prev.xp + xp;
      int newLevel = prev.level;
      while (newXp >= (newLevel * newLevel * 100) && newLevel < 50) {
        newLevel++;
      }
      final newProgress = CharacterProgressModel(
        xp: newXp,
        level: newLevel,
        levelFloorXp: (newLevel - 1) * (newLevel - 1) * 100,
        nextLevelXp: newLevel < 50 ? newLevel * newLevel * 100 : null,
        health: 100 + (newLevel - 1) * 5,
        portraitUrl: prev.portraitUrl,
        strength: prev.strength + strength,
        endurance: prev.endurance + endurance,
        flexibility: prev.flexibility + flexibility,
      );

      final updatedChar = OwnedCharacterModel(
        id: _hubData!.activeCharacter!.id,
        character: _hubData!.activeCharacter!.character,
        acquiredAt: _hubData!.activeCharacter!.acquiredAt,
        progress: newProgress,
      );

      _hubData = HubDataModel(
        profile: _hubData!.profile,
        balances: BalancesModel(
          elo: _hubData!.balances.elo,
          xp: _hubData!.balances.xp + xp,
          coins: _hubData!.balances.coins + 15,
          reputation: _hubData!.balances.reputation,
          strength: _hubData!.balances.strength + strength,
          endurance: _hubData!.balances.endurance + endurance,
          flexibility: _hubData!.balances.flexibility + flexibility,
        ),
        activeCharacter: updatedChar,
        confirmedWorkouts: _hubData!.confirmedWorkouts + 1,
        unreadNotifications: _hubData!.unreadNotifications,
      );
      notifyListeners();
    }
  }
}
