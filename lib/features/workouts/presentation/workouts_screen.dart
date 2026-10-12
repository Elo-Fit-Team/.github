import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/hub_provider.dart';
import '../../../models/exercise_model.dart';
import '../../../models/plan_model.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedCategory = 'all'; // all, strength, cardio

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = Provider.of<WorkoutProvider>(context, listen: false);
      wp.fetchExercises();
      wp.fetchPlans();
    });
  }

  void _showExerciseDetailDialog(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              exercise.category == 'strength' ? Icons.fitness_center_rounded : Icons.directions_run_rounded,
              color: const Color(0xFFC5A869),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: exercise.category == 'strength' ? const Color(0xFFF0EBE1) : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exercise.category == 'strength' ? 'СИЛОВОЕ' : 'КАРДИО',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: exercise.category == 'strength' ? const Color(0xFF7A6843) : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (exercise.isRanked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A869).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'РЕЙТИНГОВОЕ ДЛЯ ELO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A6843),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Техника и описание:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              exercise.instructions.isNotEmpty
                  ? exercise.instructions
                  : 'Официальное базовое упражнение. Запись подходов с видеофиксацией учитывается в рейтинге абсолютной и относительной силы.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Color(0xFF7A6843)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.isRanked
                          ? 'Учитывается в зачете ELO и в таблицах силы при подтверждении сообществом.'
                          : 'Тренирует выносливость и характеристики персонажа.',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A869)),
            onPressed: () {
              Navigator.pop(ctx);
              _showStartWorkoutSheet(null, preselectedExercise: exercise);
            },
            child: const Text('Выполнить в тренировке', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStartWorkoutSheet(PlanModel? selectedPlan, {ExerciseModel? preselectedExercise}) {
    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final hub = Provider.of<HubProvider>(context, listen: false);
    final activeChar = hub.hubData?.activeCharacter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Consumer<WorkoutProvider>(
              builder: (context, workoutState, _) {
                final isOngoing = workoutState.isWorkoutInProgress;
                final heroTitle = activeChar != null
                    ? '${activeChar.character.name} (Уровень ${activeChar.progress.level})'
                    : 'Свободная тренировка (без героя)';

                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.88,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              isOngoing
                                  ? 'АКТИВНАЯ ТРЕНИРОВКА'
                                  : (selectedPlan != null ? selectedPlan.name.toUpperCase() : 'НОВАЯ ТРЕНИРОВОЧНАЯ СЕССИЯ'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Color(0xFF2C3440),
                              ),
                            ),
                            const Spacer(),
                            if (isOngoing)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ИДЁТ ЗАПИСЬ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Профиль: $heroTitle',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const Divider(height: 24),

                        if (!isOngoing) ...[
                          if (selectedPlan != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDFBF7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedPlan.description,
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Время: ~${selectedPlan.estimatedMinutes} мин • Упражнений в плане: ${selectedPlan.exercises.length}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7A6843)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            'Нажмите «Начать», чтобы фиксировать подходы. После завершения результаты можно отправить сообществу на подтверждение для начисления очков рейтинга ELO и опыта.',
                            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC5A869),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                            label: const Text(
                              'НАЧАТЬ ТРЕНИРОВКУ',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            onPressed: () async {
                              await wp.startWorkout(
                                characterId: activeChar?.id ?? 1,
                                planId: selectedPlan?.id,
                                bodyWeightKg: hub.hubData?.profile.bodyWeightKg ?? '75.00',
                              );
                              setSheetState(() {});
                            },
                          ),
                        ] else ...[
                          // List of recorded results
                          const Text(
                            'ВЫПОЛНЕННЫЕ УПРАЖНЕНИЯ И ПОДХОДЫ:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          if (workoutState.activeResults.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Пока нет записанных подходов.\nНажмите кнопку ниже, чтобы зафиксировать упражнение!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black45, fontSize: 12, height: 1.4)),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: workoutState.activeResults.length,
                                itemBuilder: (context, index) {
                                  final r = workoutState.activeResults[index];
                                  final sets = r['sets'] as List?;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDFBF7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            r['exercise_name'] ?? 'Упражнение',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                        ),
                                        Text(
                                          sets != null ? '${sets.length} подходов' : '${r['distance_m'] ?? 0} м',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Add Exercise Result Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: const Color(0xFFC5A869).withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.add_rounded, color: Color(0xFF7A6843)),
                            label: const Text(
                              '+ Записать подход (Вес и повторения)',
                              style: TextStyle(color: Color(0xFF7A6843), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () => _showAddResultDialog(ctx, initialExercise: preselectedExercise),
                          ),
                          const SizedBox(height: 10),

                          // Finish and Publish CTA
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3440),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFFC5A869)),
                            label: const Text(
                              'ЗАВЕРШИТЬ И ОТПРАВИТЬ НА ПРОВЕРКУ',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            onPressed: () async {
                              await wp.finishWorkout();
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                              if (mounted) {
                                _showPublishDialog();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddResultDialog(BuildContext parentContext, {ExerciseModel? initialExercise}) {
    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final exercises = wp.exercises;
    if (exercises.isEmpty) return;

    ExerciseModel selectedExercise = initialExercise ?? exercises.first;
    final weightController = TextEditingController(text: '70');
    final repsController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isStrength = selectedExercise.category == 'strength';

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Запись подхода', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<ExerciseModel>(
                    initialValue: selectedExercise,
                    decoration: const InputDecoration(labelText: 'Упражнение', border: OutlineInputBorder()),
                    items: exercises.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e.name, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedExercise = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (isStrength) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Вес снаряда (кг)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Повторений', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Дистанция (метры)', border: OutlineInputBorder()),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A869)),
                  onPressed: () async {
                    if (isStrength) {
                      final w = double.tryParse(weightController.text) ?? 60.0;
                      final r = int.tryParse(repsController.text) ?? 10;
                      await wp.addExerciseResult(
                        exerciseId: selectedExercise.id,
                        exerciseName: selectedExercise.name,
                        category: 'strength',
                        sets: [
                          {'weight_kg': w.toStringAsFixed(2), 'repetitions': r},
                        ],
                      );
                    } else {
                      final dist = int.tryParse(weightController.text) ?? 3000;
                      await wp.addExerciseResult(
                        exerciseId: selectedExercise.id,
                        exerciseName: selectedExercise.name,
                        category: 'cardio',
                        distanceM: dist,
                        durationSeconds: 900,
                      );
                    }
                    if (dCtx.mounted) Navigator.pop(dCtx);
                  },
                  child: const Text('Зафиксировать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPublishDialog() {
    final wp = Provider.of<WorkoutProvider>(context, listen: false);
    final captionController = TextEditingController(text: 'Отличная тренировка! Улучшил рабочий вес.');
    bool isRanked = true;

    showDialog(
      context: context,
      builder: (pCtx) {
        return StatefulBuilder(
          builder: (context, setPubState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Завершение тренировки', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Выберите режим сохранения тренировки:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    // Option 1: Ranked
                    GestureDetector(
                      onTap: () => setPubState(() => isRanked = true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isRanked ? const Color(0xFFC5A869).withValues(alpha: 0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isRanked ? const Color(0xFFC5A869) : Colors.black12,
                            width: isRanked ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.military_tech_rounded,
                              color: isRanked ? const Color(0xFFC5A869) : Colors.black45,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '🏆 Соревновательный режим (Рейтинг ELO)',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C3440)),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'С видеоподтверждением. Отправляется в «Народный контроль». Начисляет турнирный ELO в таблице лидеров и прокачивает героя.',
                                    style: TextStyle(fontSize: 11, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Option 2: Casual / Free
                    GestureDetector(
                      onTap: () => setPubState(() => isRanked = false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !isRanked ? const Color(0xFF2E7D32).withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !isRanked ? const Color(0xFF2E7D32) : Colors.black12,
                            width: !isRanked ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: !isRanked ? const Color(0xFF2E7D32) : Colors.black45,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '🛡️ Свободный режим (Для себя / Без контроля)',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C3440)),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Без видео и чужих проверок. Опыт (+150 XP) и характеристики (Сила, Выносливость) мгновенно идут персонажу, не затрагивая соревновательный ELO.',
                                    style: TextStyle(fontSize: 11, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: captionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Заметка к тренировке (необязательно)',
                        hintText: 'Как прошла тренировка? Веса, самочувствие...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(pCtx), child: const Text('Отмена')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isRanked ? const Color(0xFFC5A869) : const Color(0xFF2E7D32)),
                  onPressed: () async {
                    final hub = Provider.of<HubProvider>(context, listen: false);

                    final recordedExercises = wp.activeResults.isNotEmpty
                        ? wp.activeResults.map((r) {
                            final rawSets = r['sets'];
                            final List<WorkoutSetLog> setsList = [];
                            if (rawSets is List) {
                              for (var i = 0; i < rawSets.length; i++) {
                                final s = rawSets[i];
                                if (s is Map) {
                                  setsList.add(
                                    WorkoutSetLog(
                                      setNumber: (s['set_number'] as int?) ?? (i + 1),
                                      weightKg: (s['weight_kg'] as num?)?.toDouble() ?? 0.0,
                                      reps: (s['repetitions'] as int?) ?? (s['reps'] as int?) ?? 10,
                                    ),
                                  );
                                }
                              }
                            }
                            if (setsList.isEmpty) {
                              setsList.add(const WorkoutSetLog(setNumber: 1, weightKg: 80.0, reps: 10));
                            }
                            return WorkoutExerciseLog(
                              exerciseName: r['exercise_name'] as String? ?? 'Базовое движение',
                              category: r['category'] as String? ?? 'strength',
                              sets: setsList,
                            );
                          }).toList()
                        : const [
                            WorkoutExerciseLog(
                              exerciseName: 'Жим штанги лёжа',
                              category: 'strength',
                              sets: [
                                WorkoutSetLog(setNumber: 1, weightKg: 85.0, reps: 10),
                                WorkoutSetLog(setNumber: 2, weightKg: 90.0, reps: 8),
                              ],
                            ),
                          ];

                    wp.addHistoryItem(
                      WorkoutHistoryItem(
                        id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
                        title: recordedExercises.length > 1
                            ? 'Комплекс: ${recordedExercises.first.exerciseName} +${recordedExercises.length - 1}'
                            : 'Тренировка: ${recordedExercises.first.exerciseName}',
                        date: DateTime.now(),
                        durationMinutes: 42,
                        isRanked: isRanked,
                        xpEarned: isRanked ? 250 : 150,
                        eloDelta: isRanked ? 20 : null,
                        note: captionController.text.trim().isNotEmpty ? captionController.text.trim() : null,
                        exercises: recordedExercises,
                      ),
                    );

                    await wp.publishWorkout(
                      caption: captionController.text.trim(),
                      isRanked: isRanked,
                    );
                    hub.addWorkoutExperience(
                      xp: isRanked ? 250 : 150,
                      strength: isRanked ? 4 : 3,
                      endurance: 2,
                    );
                    if (pCtx.mounted) Navigator.pop(pCtx);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF2C3440),
                        content: Text(isRanked
                            ? '🏆 Тренировка отправлена в «Народный контроль» для подтверждения ELO!'
                            : '🛡️ Тренировка засчитана! Персонаж получил +150 XP, +3 Силы, +2 Выносливости!'),
                      ),
                    );
                  },
                  child: Text(
                    isRanked ? 'Отправить на проверку ELO' : 'Завершить для себя',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WorkoutProvider>(context);

    final filteredExercises = wp.exercises.where((e) {
      if (_selectedCategory == 'strength') return e.category == 'strength';
      if (_selectedCategory == 'cardio') return e.category == 'cardio';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFC5A869),
          onRefresh: () async {
            await wp.fetchExercises();
            await wp.fetchPlans();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header with Start Workout CTA
                Row(
                  children: [
                    const Text(
                      'ТРЕНИРОВКИ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF2C3440),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5A869),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'НОВАЯ СЕССИЯ',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () => _showStartWorkoutSheet(null),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Category selector
                Row(
                  children: [
                    _buildCategoryPill('Все категории', _selectedCategory == 'all', () {
                      setState(() => _selectedCategory = 'all');
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryPill('Силовые', _selectedCategory == 'strength', () {
                      setState(() => _selectedCategory = 'strength');
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryPill('Кардио', _selectedCategory == 'cardio', () {
                      setState(() => _selectedCategory = 'cardio');
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Standard Plans Section
                Row(
                  children: [
                    const Text(
                      'ГОТОВЫЕ ПЛАНЫ ТРЕНИРОВОК',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${wp.plans.length} ПЛАНОВ',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC5A869)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Plans Carousel
                SizedBox(
                  height: 215,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: wp.plans.length,
                    itemBuilder: (context, idx) {
                      final plan = wp.plans[idx];
                      return _buildMinimalistPlanCard(plan);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Exercise Catalog Section with Explanatory Subtitle
                Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'КАТАЛОГ УПРАЖНЕНИЙ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'База отдельных упражнений для свободной тренировки',
                          style: TextStyle(fontSize: 10, color: Colors.black45),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${filteredExercises.length} УПР.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (filteredExercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Упражнений в этой категории не найдено.', style: TextStyle(color: Colors.black45)),
                    ),
                  )
                else
                  Column(
                    children: filteredExercises.map((e) {
                      final isStrength = e.category == 'strength';

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showExerciseDetailDialog(e),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isStrength ? Icons.fitness_center_rounded : Icons.directions_run_rounded,
                                  color: isStrength ? const Color(0xFF7A6843) : Colors.blueGrey,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          e.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
                                        ),
                                        if (e.isRanked) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFC5A869).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('РЕЙТИНГ',
                                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF7A6843))),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      e.instructions.isNotEmpty ? e.instructions : (isStrength ? 'Силовое упражнение' : 'Кардио упражнение'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.info_outline, size: 20, color: Colors.black26),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalistPlanCard(PlanModel plan) {
    Color gradStart;
    Color gradEnd;
    IconData icon;
    String badge;

    final nameLower = plan.name.toLowerCase();
    if (nameLower.contains('кардио') || nameLower.contains('вынослив')) {
      gradStart = const Color(0xFF38181A);
      gradEnd = const Color(0xFF5C2528);
      icon = Icons.directions_run_rounded;
      badge = 'КАРДИО';
    } else if (nameLower.contains('верх') || nameLower.contains('грудь')) {
      gradStart = const Color(0xFF261D15);
      gradEnd = const Color(0xFF3D2E1E);
      icon = Icons.fitness_center_rounded;
      badge = 'ВЕРХ ТЕЛА';
    } else if (nameLower.contains('ноги') || nameLower.contains('кор')) {
      gradStart = const Color(0xFF14241F);
      gradEnd = const Color(0xFF223E34);
      icon = Icons.accessibility_new_rounded;
      badge = 'НОГИ И КОР';
    } else if (nameLower.contains('full body') || nameLower.contains('power')) {
      gradStart = const Color(0xFF181E33);
      gradEnd = const Color(0xFF242F52);
      icon = Icons.bolt_rounded;
      badge = 'ВСЁ ТЕЛО';
    } else {
      gradStart = const Color(0xFF2C3440);
      gradEnd = const Color(0xFF1B2028);
      icon = Icons.shield_rounded;
      badge = 'СИЛОВОЙ СПЛИТ';
    }

    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showStartWorkoutSheet(plan),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimalistic Artwork Banner
              Container(
                height: 95,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  gradient: LinearGradient(
                    colors: [gradStart, gradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Color(0xFFC5A869),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      top: 12,
                      child: Text(
                        '${plan.estimatedMinutes} МИН',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.5)),
                        ),
                        child: Icon(icon, color: const Color(0xFFC5A869), size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // Plan Information
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plan.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${plan.exercises.length} упражнений',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const Spacer(),
                        const Text(
                          'СТАРТ >',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC5A869),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2C3440) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
