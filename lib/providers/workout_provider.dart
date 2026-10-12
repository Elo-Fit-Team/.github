import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/exercise_model.dart';
import '../models/plan_model.dart';

class WorkoutSetLog {
  final int setNumber;
  final double weightKg;
  final int reps;

  const WorkoutSetLog({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });
}

class WorkoutExerciseLog {
  final String exerciseName;
  final String category;
  final List<WorkoutSetLog> sets;

  const WorkoutExerciseLog({
    required this.exerciseName,
    required this.category,
    required this.sets,
  });

  double get totalVolumeKg => sets.fold(0.0, (acc, s) => acc + (s.weightKg * s.reps));
  int get totalReps => sets.fold(0, (acc, s) => acc + s.reps);
  double get maxWeightKg => sets.fold(0.0, (acc, s) => s.weightKg > acc ? s.weightKg : acc);
}

class WorkoutHistoryItem {
  final String id;
  final String title;
  final DateTime date;
  final int durationMinutes;
  final bool isRanked;
  final int xpEarned;
  final int? eloDelta;
  final String? note;
  final List<WorkoutExerciseLog> exercises;

  const WorkoutHistoryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.durationMinutes,
    required this.isRanked,
    required this.xpEarned,
    this.eloDelta,
    this.note,
    required this.exercises,
  });

  double get totalTonnageKg => exercises.fold(0.0, (acc, e) => acc + e.totalVolumeKg);
  int get totalSets => exercises.fold(0, (acc, e) => acc + e.sets.length);
}

class WorkoutProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  bool _isLoadingPlans = false;
  String? _error;
  List<ExerciseModel> _exercises = [];
  List<PlanModel> _plans = [];
  final List<WorkoutHistoryItem> _history = [];

  // Active workout tracking
  String? _activeWorkoutId;
  int _activeVersion = 1;
  int? _activeCharacterId;
  DateTime? _activeStartedAt;
  bool _isWorkoutInProgress = false;
  final List<Map<String, dynamic>> _activeResults = [];

  WorkoutProvider({required this.apiClient}) {
    _initStandardPlans();
    _initStandardExercises();
    _initHistory();
  }

  bool get isLoading => _isLoading;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get error => _error;
  List<ExerciseModel> get exercises => _exercises;
  List<PlanModel> get plans => _plans;
  List<WorkoutHistoryItem> get history => _history;
  bool get isWorkoutInProgress => _isWorkoutInProgress;
  String? get activeWorkoutId => _activeWorkoutId;
  int get activeVersion => _activeVersion;
  int? get activeCharacterId => _activeCharacterId;
  DateTime? get activeStartedAt => _activeStartedAt;
  List<Map<String, dynamic>> get activeResults => _activeResults;

  void addHistoryItem(WorkoutHistoryItem item) {
    _history.insert(0, item);
    notifyListeners();
  }

  void _initHistory() {
    final now = DateTime.now();
    _history.addAll([
      WorkoutHistoryItem(
        id: 'hist-1',
        title: 'Базовая силовая база',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        durationMinutes: 48,
        isRanked: true,
        xpEarned: 280,
        eloDelta: 22,
        note: 'Отличный прогресс в жиме! Пожал 90 кг на 6 повторений. Видео подтверждено судьями.',
        exercises: const [
          WorkoutExerciseLog(
            exerciseName: 'Жим штанги лёжа',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 80.0, reps: 10),
              WorkoutSetLog(setNumber: 2, weightKg: 85.0, reps: 8),
              WorkoutSetLog(setNumber: 3, weightKg: 90.0, reps: 6),
            ],
          ),
          WorkoutExerciseLog(
            exerciseName: 'Армейский жим стоя',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 45.0, reps: 10),
              WorkoutSetLog(setNumber: 2, weightKg: 50.0, reps: 8),
              WorkoutSetLog(setNumber: 3, weightKg: 55.0, reps: 6),
            ],
          ),
          WorkoutExerciseLog(
            exerciseName: 'Отжимания от пола',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 0.0, reps: 25),
              WorkoutSetLog(setNumber: 2, weightKg: 0.0, reps: 20),
              WorkoutSetLog(setNumber: 3, weightKg: 0.0, reps: 20),
            ],
          ),
        ],
      ),
      WorkoutHistoryItem(
        id: 'hist-2',
        title: 'Турники и брусья (Street Workout)',
        date: now.subtract(const Duration(days: 3, hours: 5)),
        durationMinutes: 42,
        isRanked: false,
        xpEarned: 180,
        eloDelta: null,
        note: 'Свободная тренировка во дворе без видео. Идеальная амплитуда и глубокий памп.',
        exercises: const [
          WorkoutExerciseLog(
            exerciseName: 'Подтягивания на перекладине',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 0.0, reps: 12),
              WorkoutSetLog(setNumber: 2, weightKg: 10.0, reps: 8),
              WorkoutSetLog(setNumber: 3, weightKg: 10.0, reps: 7),
            ],
          ),
          WorkoutExerciseLog(
            exerciseName: 'Планка на предплечьях',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 0.0, reps: 60),
              WorkoutSetLog(setNumber: 2, weightKg: 0.0, reps: 60),
            ],
          ),
        ],
      ),
      WorkoutHistoryItem(
        id: 'hist-3',
        title: 'Железные ноги и кор',
        date: now.subtract(const Duration(days: 6, hours: 1)),
        durationMinutes: 55,
        isRanked: true,
        xpEarned: 320,
        eloDelta: 25,
        note: 'Установил новый личный рекорд в приседе — 120 кг! Рейтинг ELO вырос.',
        exercises: const [
          WorkoutExerciseLog(
            exerciseName: 'Приседания со штангой',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 100.0, reps: 10),
              WorkoutSetLog(setNumber: 2, weightKg: 110.0, reps: 8),
              WorkoutSetLog(setNumber: 3, weightKg: 120.0, reps: 5),
            ],
          ),
          WorkoutExerciseLog(
            exerciseName: 'Становая тяга',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 110.0, reps: 8),
              WorkoutSetLog(setNumber: 2, weightKg: 120.0, reps: 6),
              WorkoutSetLog(setNumber: 3, weightKg: 130.0, reps: 5),
            ],
          ),
          WorkoutExerciseLog(
            exerciseName: 'Выпады с гантелями',
            category: 'strength',
            sets: [
              WorkoutSetLog(setNumber: 1, weightKg: 20.0, reps: 12),
              WorkoutSetLog(setNumber: 2, weightKg: 22.0, reps: 10),
            ],
          ),
        ],
      ),
    ]);
  }

  void _initStandardPlans() {
    _plans = [
      PlanModel(
        id: 1,
        name: 'Базовая силовая база',
        description: 'Классическая тройка: жим лёжа, приседания и становая тяга',
        estimatedMinutes: 45,
        difficulty: 'Easy',
        category: 'Strength',
        exercises: [
          PlanExerciseModel(exercise: 1, position: 1, sets: 3, repetitions: 10, durationSeconds: 0),
          PlanExerciseModel(exercise: 2, position: 2, sets: 3, repetitions: 8, durationSeconds: 0),
          PlanExerciseModel(exercise: 3, position: 3, sets: 3, repetitions: 5, durationSeconds: 0),
        ],
      ),
      PlanModel(
        id: 2,
        name: 'Верх тела и жим',
        description: 'Интенсивная проработка мышц груди, плеч, трицепсов и спины',
        estimatedMinutes: 40,
        difficulty: 'Medium',
        category: 'Strength',
        exercises: [
          PlanExerciseModel(exercise: 1, position: 1, sets: 4, repetitions: 8, durationSeconds: 0),
          PlanExerciseModel(exercise: 4, position: 2, sets: 3, repetitions: 10, durationSeconds: 0),
          PlanExerciseModel(exercise: 5, position: 3, sets: 3, repetitions: 15, durationSeconds: 0),
          PlanExerciseModel(exercise: 6, position: 4, sets: 3, repetitions: 8, durationSeconds: 0),
        ],
      ),
      PlanModel(
        id: 3,
        name: 'Взрывной кардио-интенсив',
        description: 'Интервальный бег и велотренажер для максимального сжигания калорий',
        estimatedMinutes: 35,
        difficulty: 'High',
        category: 'Cardio',
        exercises: [
          PlanExerciseModel(exercise: 8, position: 1, sets: 1, repetitions: 1, durationSeconds: 1800),
          PlanExerciseModel(exercise: 9, position: 2, sets: 1, repetitions: 1, durationSeconds: 1200),
        ],
      ),
      PlanModel(
        id: 4,
        name: 'Ноги и пресс',
        description: 'Мощная тренировка квадрицепсов, бицепсов бедер и мышц кора',
        estimatedMinutes: 30,
        difficulty: 'Medium',
        category: 'Strength',
        exercises: [
          PlanExerciseModel(exercise: 2, position: 1, sets: 4, repetitions: 10, durationSeconds: 0),
          PlanExerciseModel(exercise: 7, position: 2, sets: 3, repetitions: 12, durationSeconds: 0),
          PlanExerciseModel(exercise: 10, position: 3, sets: 3, repetitions: 1, durationSeconds: 60),
        ],
      ),
      PlanModel(
        id: 5,
        name: 'Full Body Power',
        description: 'Комплексная силовая нагрузка на все основные мышечные группы',
        estimatedMinutes: 50,
        difficulty: 'Hard',
        category: 'Strength',
        exercises: [
          PlanExerciseModel(exercise: 2, position: 1, sets: 3, repetitions: 8, durationSeconds: 0),
          PlanExerciseModel(exercise: 1, position: 2, sets: 3, repetitions: 8, durationSeconds: 0),
          PlanExerciseModel(exercise: 3, position: 3, sets: 3, repetitions: 5, durationSeconds: 0),
          PlanExerciseModel(exercise: 6, position: 4, sets: 3, repetitions: 8, durationSeconds: 0),
        ],
      ),
    ];
  }

  void _initStandardExercises() {
    _exercises = [
      ExerciseModel(id: 1, slug: 'bench-press', name: 'Жим лёжа', category: 'strength', instructions: 'Классический жим штанги от груди на горизонтальной скамье', isRanked: true, countsForTotal: true),
      ExerciseModel(id: 2, slug: 'squat', name: 'Приседания со штангой', category: 'strength', instructions: 'Глубокий присед со штангой на плечах с контролем спины', isRanked: true, countsForTotal: true),
      ExerciseModel(id: 3, slug: 'deadlift', name: 'Становая тяга', category: 'strength', instructions: 'Тяга штанги с помоста с прямой спиной и активацией таза', isRanked: true, countsForTotal: true),
      ExerciseModel(id: 4, slug: 'overhead-press', name: 'Армейский жим', category: 'strength', instructions: 'Жим штанги или гантелей вверх над головой стоя', isRanked: true, countsForTotal: true),
      ExerciseModel(id: 5, slug: 'push-ups', name: 'Отжимания от пола', category: 'strength', instructions: 'Отжимания в упоре лёжа с полной амплитудой', isRanked: false, countsForTotal: false),
      ExerciseModel(id: 6, slug: 'pull-ups', name: 'Подтягивания', category: 'strength', instructions: 'Подтягивания на перекладине широким или средним хватом', isRanked: false, countsForTotal: false),
      ExerciseModel(id: 7, slug: 'lunges', name: 'Выпады с гантелями', category: 'strength', instructions: 'Шагающие выпады вперед с удержанием гантелей', isRanked: false, countsForTotal: false),
      ExerciseModel(id: 8, slug: 'running', name: 'Бег на дистанцию', category: 'cardio', instructions: 'Бег на открытом воздухе или беговой дорожке', isRanked: false, countsForTotal: false),
      ExerciseModel(id: 9, slug: 'cycling', name: 'Велосипед', category: 'cardio', instructions: 'Езда на велосипеде или сайкл-тренажере', isRanked: false, countsForTotal: false),
      ExerciseModel(id: 10, slug: 'plank', name: 'Планка на предплечьях', category: 'strength', instructions: 'Статическое удержание ровной линии тела', isRanked: false, countsForTotal: false),
    ];
  }

  Future<void> fetchExercises({String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final query = category != null ? {'category': category} : null;
      final res = await apiClient.get(ApiConstants.exercises, queryParams: query);
      final list = (res is Map && res.containsKey('results')) ? res['results'] as List : (res as List? ?? []);
      if (list.isNotEmpty) {
        _exercises = list.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Keep standard fallback exercises if offline or demo
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlans() async {
    _isLoadingPlans = true;
    notifyListeners();
    try {
      final res = await apiClient.get(ApiConstants.plans);
      final list = (res is Map && res.containsKey('results')) ? res['results'] as List : (res as List? ?? []);
      if (list.isNotEmpty) {
        _plans = list.map((p) => PlanModel.fromJson(p as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Keep rich standard plans
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  String _generateUuid() {
    final r = Random();
    return '${r.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}-'
        '${r.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0')}-4'
        '${r.nextInt(0xFFF).toRadixString(16).padLeft(3, '0')}-a'
        '${r.nextInt(0xFFF).toRadixString(16).padLeft(3, '0')}-'
        '${r.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        '${r.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  Future<bool> startWorkout({
    int? planId,
    int? characterId,
    String? bodyWeightKg,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final workoutId = _generateUuid();
    final now = DateTime.now().toUtc().toIso8601String();
    final actualCharId = characterId ?? 1;

    _activeWorkoutId = workoutId;
    _activeVersion = 1;
    _activeCharacterId = actualCharId;
    _activeStartedAt = DateTime.now();
    _isWorkoutInProgress = true;
    _activeResults.clear();

    try {
      final body = <String, dynamic>{
        'id': workoutId,
        'character': actualCharId,
        if (planId != null) 'plan': planId,
        'started_at': now,
        'finished_at': null,
        if (bodyWeightKg != null) 'body_weight_kg': bodyWeightKg,
      };

      await apiClient.post(ApiConstants.workouts, body: body);
    } catch (_) {
      // Offline or demo mode: workout proceeds seamlessly in local state
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> addExerciseResult({
    required int exerciseId,
    required String exerciseName,
    required String category,
    List<Map<String, dynamic>>? sets,
    int? distanceM,
    int? durationSeconds,
    String? evidenceUuid,
  }) async {
    if (_activeWorkoutId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final resultUuid = _generateUuid();
    final body = <String, dynamic>{
      'version': _activeVersion,
      'exercise': exerciseId,
    };

    if (category == 'strength' && sets != null) {
      body['sets'] = sets;
    } else if (category == 'cardio') {
      body['distance_m'] = distanceM ?? 1000;
      body['duration_seconds'] = durationSeconds ?? 300;
    }

    if (evidenceUuid != null) {
      body['evidence'] = evidenceUuid;
      body['video_start_seconds'] = 0;
      body['video_end_seconds'] = 60;
    }

    try {
      final res = await apiClient.put(
        '${ApiConstants.workouts}$_activeWorkoutId/results/$resultUuid/',
        body: body,
      );

      if (res is Map && res.containsKey('workout_version')) {
        _activeVersion = res['workout_version'] as int;
      } else {
        _activeVersion++;
      }
    } catch (_) {
      _activeVersion++;
    }

    _activeResults.add({
      'result_id': resultUuid,
      'exercise_name': exerciseName,
      'category': category,
      'sets': sets,
      'distance_m': distanceM,
    });

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> finishWorkout() async {
    if (_activeWorkoutId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final res = await apiClient.patch(
        '${ApiConstants.workouts}$_activeWorkoutId/',
        body: {
          'version': _activeVersion,
          'finished_at': now,
        },
      );

      if (res is Map && res.containsKey('version')) {
        _activeVersion = res['version'] as int;
      }
    } catch (_) {}

    _isWorkoutInProgress = false;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> publishWorkout({
    required String caption,
    bool isRanked = true,
    String visibility = 'public',
  }) async {
    if (_activeWorkoutId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await apiClient.post(
        ApiConstants.posts,
        body: {
          'workout': _activeWorkoutId,
          'version': _activeVersion,
          'caption': caption,
          'visibility': visibility,
          'is_ranked': isRanked,
        },
      );
    } catch (_) {}

    _activeWorkoutId = null;
    _activeResults.clear();
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
