import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/hub_provider.dart';
import '../../../providers/workout_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileDialog() {
    final hub = Provider.of<HubProvider>(context, listen: false);
    final currentWeight = hub.hubData?.profile.bodyWeightKg ?? '75.00';
    final currentGender = hub.hubData?.profile.gender ?? 'unspecified';

    final weightController = TextEditingController(text: currentWeight);
    String selectedGender = currentGender;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Спортивные данные', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Вес используется для расчёта относительной силы и коэффициентов в таблицах лидеров:',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Собственный вес (кг)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: ['male', 'female', 'other', 'unspecified'].contains(selectedGender) ? selectedGender : 'unspecified',
                    decoration: const InputDecoration(labelText: 'Пол атлета', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Мужской')),
                      DropdownMenuItem(value: 'female', child: Text('Женский')),
                      DropdownMenuItem(value: 'other', child: Text('Другой')),
                      DropdownMenuItem(value: 'unspecified', child: Text('Не указано')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedGender = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A869)),
                  onPressed: () async {
                    await hub.updateProfile(
                      bodyWeightKg: weightController.text.trim(),
                      gender: selectedGender,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showServerSettingsDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final urlController = TextEditingController(text: auth.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Подключение к серверу', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Адрес бэкенда Django REST API:\n• Браузер / Windows: http://127.0.0.1:8000/api/\n• Эмулятор Android: http://10.0.2.2:8000/api/',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL сервера', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A869)),
            onPressed: () {
              auth.updateBaseUrl(urlController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Адрес сервера обновлён')),
              );
            },
            child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetailDialog(WorkoutHistoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isRanked ? const Color(0xFFC5A869).withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.isRanked ? '🏆 ELO +${item.eloDelta ?? 20}' : '🛡️ +${item.xpEarned} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: item.isRanked ? const Color(0xFF7A6843) : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('${item.durationMinutes} мин', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 16),
                    const Icon(Icons.fitness_center_rounded, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('Тоннаж: ${item.totalTonnageKg.toInt()} кг', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      '«${item.note}»',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const Text(
                  'ПРОТОКОЛ УПРАЖНЕНИЙ И ПОДХОДОВ:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                ...item.exercises.map((ex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ex.exerciseName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C3440)),
                            ),
                            Text(
                              '${ex.totalVolumeKg.toInt()} кг',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC5A869)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: ex.sets.map((s) {
                            final weightText = s.weightKg > 0 ? '${s.weightKg.toStringAsFixed(s.weightKg % 1 == 0 ? 0 : 1)} кг' : 'Свой вес';
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EFE9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Сет ${s.setNumber}: $weightText × ${s.reps}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3440)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final hub = Provider.of<HubProvider>(context);
    final wp = Provider.of<WorkoutProvider>(context);

    final user = auth.currentUser;
    final balances = hub.hubData?.balances;
    final profile = hub.hubData?.profile;
    final activeChar = hub.hubData?.activeCharacter;

    final displayName = user?.displayName ?? 'Атлет EloFit';
    final email = user?.email ?? 'athlete@elofit.test';
    final elo = balances?.elo ?? 1250;
    final weight = profile?.bodyWeightKg ?? '75.00';
    final heroName = activeChar?.character.name ?? 'Каэл';

    final historyList = wp.history;
    final totalTonnage = historyList.fold(0.0, (acc, item) => acc + item.totalTonnageKg);
    final totalWorkouts = historyList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                children: [
                  const Text(
                    'ПРОФИЛЬ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Color(0xFF2C3440),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.black54),
                    onPressed: _showServerSettingsDialog,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // User Info Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF2C3440),
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'А',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC5A869),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2C3440),
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFC5A869), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '$elo ELO',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$weight кг',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Edit Profile Button
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A869),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'ИЗМЕНИТЬ СПОРТИВНЫЕ ДАННЫЕ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  onPressed: _showEditProfileDialog,
                ),
              ),
              const SizedBox(height: 24),

              // Workout Stats Highlights
              const Text(
                'СПОРТИВНАЯ СВОДКА',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fitness_center_rounded, color: Color(0xFFC5A869), size: 22),
                          const SizedBox(height: 8),
                          Text(
                            '${totalTonnage.toInt()} кг',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C3440)),
                          ),
                          const Text('Суммарный тоннаж', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.event_available_rounded, color: Colors.blueAccent, size: 22),
                          const SizedBox(height: 8),
                          Text(
                            '$totalWorkouts',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C3440)),
                          ),
                          const Text('Завершено сессий', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.bolt_rounded, color: Colors.orange, size: 22),
                          SizedBox(height: 8),
                          Text(
                            '120 кг',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C3440)),
                          ),
                          Text('Рекорд (Присед)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Workout History Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ИСТОРИЯ ТРЕНИРОВОК И ДНЕВНИК ВЕСОВ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.black54),
                  ),
                  Text(
                    '${historyList.length} записи',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC5A869)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Workout History List
              if (historyList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text('У вас пока нет завершённых тренировок'),
                )
              else
                ...historyList.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _showWorkoutDetailDialog(item),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: title & badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2C3440),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isRanked
                                        ? const Color(0xFFC5A869).withValues(alpha: 0.15)
                                        : Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.isRanked ? '🏆 Рейтинговая (ELO +${item.eloDelta ?? 20})' : '🛡️ Свободная (+${item.xpEarned} XP)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.isRanked ? const Color(0xFF7A6843) : Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Date & metrics
                            Row(
                              children: [
                                Text(
                                  '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year} • ${item.durationMinutes} мин',
                                  style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text(
                                  'Тоннаж: ${item.totalTonnageKg.toInt()} кг',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C3440)),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Exercises breakdown
                            ...item.exercises.map((ex) {
                              final setsSummary = ex.sets.map((s) {
                                return s.weightKg > 0 ? '${s.weightKg.toInt()}×${s.reps}' : '${s.reps} повт';
                              }).join(', ');

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.circle, size: 6, color: Color(0xFFC5A869)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                          children: [
                                            TextSpan(
                                              text: '${ex.exerciseName}: ',
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                            TextSpan(
                                              text: '${ex.sets.length} подхода ($setsSummary)',
                                              style: const TextStyle(color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            if (item.note != null && item.note!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '💬 «${item.note}»',
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black45),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Text(
                                  'Подробный протокол',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC5A869)),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFC5A869)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),

              // Settings Sections
              const Text(
                'АККАУНТ И НАСТРОЙКИ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shield_rounded, color: Color(0xFF7A6843)),
                      title: const Text('Активный персонаж', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text(heroName, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                    ),
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    ListTile(
                      leading: const Icon(Icons.dns_rounded, color: Color(0xFF2C3440)),
                      title: const Text('Сервер API бэкенда', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text(auth.baseUrl, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      trailing: const Icon(Icons.edit, size: 18, color: Colors.black26),
                      onTap: _showServerSettingsDialog,
                    ),
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    const ListTile(
                      leading: Icon(Icons.location_on_rounded, color: Colors.redAccent),
                      title: Text('Город и регион', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text('Алматы, Казахстан (KZ)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Tile
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text(
                    'Выйти из аккаунта',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.redAccent),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                  onTap: () async {
                    await auth.logout();
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
