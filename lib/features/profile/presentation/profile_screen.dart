import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/hub_provider.dart';
import '../../../providers/workout_provider.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoginTab = true;
  bool _obscurePassword = true;
  bool _obscureRegPassword = true;

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  String _selectedCity = 'Алматы (Almaty)';

  static const List<String> _kazakhstanCities = [
    'Алматы (Almaty)',
    'Астана (Astana)',
    'Шымкент (Shymkent)',
    'Караганда (Karaganda)',
    'Актобе (Aktobe)',
    'Тараз (Taraz)',
    'Павлодар (Pavlodar)',
    'Усть-Каменогорск (Oskemen)',
    'Семей (Semey)',
    'Атырау (Atyrau)',
    'Костанай (Kostanay)',
    'Кызылорда (Kyzylorda)',
    'Уральск (Oral)',
    'Петропавловск (Petropavl)',
    'Актау (Aktau)',
    'Темиртау (Temirtau)',
    'Туркестан (Turkistan)',
    'Кокшетау (Kokshetau)',
    'Талдыкорган (Taldykorgan)',
    'Экибастуз (Ekibastuz)',
    'Рудный (Rudny)',
    'Жезказган (Zhezkazgan)',
    'Конаев (Konaev)',
  ];

  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLockedOut) {
        setState(() {});
      } else {
        auth.checkLockoutStatus();
      }
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _loginController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final hub = Provider.of<HubProvider>(context, listen: false);
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите логин/email и пароль')),
      );
      return;
    }

    final success = await auth.login(login: login, password: password);
    if (!mounted) return;
    if (success) {
      await hub.refreshHub();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2C3440),
          content: Text('Добро пожаловать, ${auth.currentUser?.displayName ?? "Атлет"}!'),
        ),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(auth.errorMessage!),
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final hub = Provider.of<HubProvider>(context, listen: false);
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final confirm = _regConfirmPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите корректный адрес email')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль должен содержать минимум 6 символов')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введенные пароли не совпадают')),
      );
      return;
    }

    final success = await auth.register(
      email: email,
      password: password,
      displayName: name.isNotEmpty ? name : null,
      city: _selectedCity,
    );

    if (!mounted) return;
    if (success) {
      await hub.refreshHub();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('🎉 Добро пожаловать в EloFit! Профиль успешно создан!'),
        ),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(auth.errorMessage!),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: Color(0xFFC5A869)),
            SizedBox(width: 10),
            Text('Сброс пароля', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Введите email, указанный при регистрации. Мы отправим инструкцию по восстановлению доступа:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A869)),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пожалуйста, введите корректный email')),
                );
                return;
              }
              Navigator.pop(ctx);
              final msg = await auth.requestPasswordReset(email);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF2C3440),
                    content: Text(msg),
                  ),
                );
              }
            },
            child: const Text('Отправить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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

  Widget _buildAuthCard(AuthProvider auth) {
    final isLocked = auth.isLockedOut;
    final remainingSec = auth.remainingLockSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5A869).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLoginTab = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isLoginTab ? const Color(0xFF2C3440) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ВХОД В АККАУНТ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: _isLoginTab ? const Color(0xFFC5A869) : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLoginTab = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isLoginTab ? const Color(0xFF2C3440) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'РЕГИСТРАЦИЯ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: !_isLoginTab ? const Color(0xFFC5A869) : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_isLoginTab) ...[
            // LOGIN FORM
            const Text(
              'Вход в аккаунт',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2C3440)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Войдите, чтобы продолжить тренировки и отслеживать прогресс:',
              style: TextStyle(fontSize: 11.5, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Email или имя пользователя',
                hintText: 'athlete@elofit.kz или username',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Пароль',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
            ),
            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  'Забыли пароль?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7A6843)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Lockout alert banner if 5 attempts failed
            if (isLocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_rounded, color: Colors.redAccent, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Блокировка защиты: 5 неверных попыток',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Повторная попытка через: ${_formatDuration(remainingSec)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ] else if (auth.failedAttempts > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Неверный пароль. Осталось попыток до блокировки на 2 мин: ${5 - auth.failedAttempts}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocked ? Colors.grey : const Color(0xFFC5A869),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                ),
                onPressed: (isLocked || auth.isLoading) ? null : _handleLogin,
                child: auth.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        isLocked ? 'БЛОКИРОВКА (${_formatDuration(remainingSec)})' : 'ВОЙТИ В АККАУНТ',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                      ),
              ),
            ),
          ] else ...[
            // REGISTER FORM
            const Text(
              'Регистрация нового атлета',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2C3440)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Создайте профиль, чтобы сохранять тренировки и расти в рейтинге ELO:',
              style: TextStyle(fontSize: 11.5, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _regNameController,
              decoration: InputDecoration(
                labelText: 'Имя или никнейм атлета *',
                hintText: 'Например: Тимур (Titan)',
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'name@example.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
            ),
            const SizedBox(height: 12),

            // City selection for Kazakhstan
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: InputDecoration(
                labelText: 'Город (Казахстан) 🇰🇿 *',
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFFC5A869)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
              items: _kazakhstanCities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3440)),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCity = val);
                }
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _regPasswordController,
              obscureText: _obscureRegPassword,
              decoration: InputDecoration(
                labelText: 'Пароль (минимум 6 символов) *',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _regConfirmPasswordController,
              obscureText: _obscureRegPassword,
              decoration: InputDecoration(
                labelText: 'Повторите пароль *',
                prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFFDFBF7),
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3440),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: auth.isLoading ? null : _handleRegister,
                child: auth.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'СОЗДАТЬ АККАУНТ',
                        style: TextStyle(color: Color(0xFFC5A869), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final hub = Provider.of<HubProvider>(context);
    final wp = Provider.of<WorkoutProvider>(context);

    final isAuthenticated = auth.isAuthenticated;
    final user = auth.currentUser;
    final balances = hub.hubData?.balances;
    final profile = hub.hubData?.profile;
    final activeChar = hub.hubData?.activeCharacter;

    final displayName = user?.displayName ?? 'Атлет EloFit';
    final email = user?.email ?? 'athlete@elofit.kz';
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
                    icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFC5A869)),
                    tooltip: 'Панель администратора (admin/admin123)',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.black54),
                    onPressed: _showServerSettingsDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // If NOT authenticated, show the Auth card (Login / Register)
              if (!isAuthenticated) ...[
                _buildAuthCard(auth),
                const SizedBox(height: 24),
              ] else ...[
                // User Info Card for logged in user
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
              ],

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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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

              // Settings Sections (Visible for all or authenticated)
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
                    if (isAuthenticated) ...[
                      ListTile(
                        leading: const Icon(Icons.shield_rounded, color: Color(0xFF7A6843)),
                        title: const Text('Активный персонаж', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: Text(heroName, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                      ),
                      Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    ],
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFC5A869)),
                      title: const Text('Панель администратора', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Управление базой атлетов и статистика (admin/admin123)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminScreen()),
                        );
                      },
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

              // Logout Tile (Only when logged in)
              if (isAuthenticated) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
