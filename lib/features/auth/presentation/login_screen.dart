import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenController = TextEditingController();
  final _serverUrlController = TextEditingController();
  bool _isFirebaseMode = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _serverUrlController.text = auth.baseUrl;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  void _showServerSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Конфигурация сервера', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Укажите адрес Django REST API бэкенда:\n  Android Emulator: http://10.0.2.2:8000/api/\n  Windows / Web / iOS: http://127.0.0.1:8000/api/',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Базовый URL',
                border: OutlineInputBorder(),
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
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .updateBaseUrl(_serverUrlController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Адрес сервера успешно обновлен')),
              );
            },
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите токен')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success;
    if (_isFirebaseMode) {
      success = await auth.loginWithFirebase(token);
    } else {
      success = await auth.loginWithToken(token);
    }

    if (!mounted) return;
    if (!success && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Emblem
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3440),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Color(0xFFC5A869),
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ELOFIT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Color(0xFF2C3440),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Фэнтези-тренировки и ELO-прокачка',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 36),

                // Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isFirebaseMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isFirebaseMode ? const Color(0xFF2C3440) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'JWT / Сессионный токен',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_isFirebaseMode ? Colors.white : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isFirebaseMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isFirebaseMode ? const Color(0xFF2C3440) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Firebase ID Token',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isFirebaseMode ? Colors.white : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Token Input
                TextField(
                  controller: _tokenController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: _isFirebaseMode ? 'Firebase ID Token' : 'Access Token (JWT)',
                    hintText: _isFirebaseMode
                        ? 'Вставьте Firebase id_token'
                        : 'Вставьте Bearer JWT токен с бэкенда',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Login CTA Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5A869),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: auth.isLoading ? null : _handleLogin,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'ВОЙТИ В СИСТЕМУ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Demo Login Button for easy testing
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFF7A6843)),
                  label: const Text(
                    'Быстрый демо-вход для просмотра',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7A6843)),
                  ),
                  onPressed: () {
                    auth.loginWithToken('demo_token');
                  },
                ),
                const SizedBox(height: 24),

                // Server Configuration Button
                TextButton.icon(
                  icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.black54),
                  label: Text(
                    'Бэкенд: ${auth.baseUrl}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: _showServerSettingsDialog,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
