import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../providers/auth_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isAdminUnlocked = false;
  final _adminLoginController = TextEditingController();
  final _adminPassController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _adminLoginController.dispose();
    _adminPassController.dispose();
    super.dispose();
  }

  void _verifyAdminCredentials() {
    final login = _adminLoginController.text.trim();
    final pass = _adminPassController.text;

    if (login == 'admin' && pass == 'admin123') {
      setState(() {
        _isAdminUnlocked = true;
        _errorMessage = null;
      });
      _fetchAdminUsers();
    } else {
      setState(() {
        _errorMessage = 'Неверный логин или пароль администратора';
      });
    }
  }

  Future<void> _fetchAdminUsers() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final res = await auth.apiClient.get(ApiConstants.adminUsers, requiresAuth: false);
      if (res is Map && res.containsKey('users')) {
        final list = (res['users'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _users = list;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки базы: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E242C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141920),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFC5A869)),
            SizedBox(width: 8),
            Text(
              'ПАНЕЛЬ АДМИНИСТРАТОРА',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          ],
        ),
        actions: [
          if (_isAdminUnlocked)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFC5A869)),
              onPressed: _fetchAdminUsers,
              tooltip: 'Обновить данные базы',
            ),
        ],
      ),
      body: SafeArea(
        child: _isAdminUnlocked ? _buildDashboard() : _buildLoginCard(),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3440),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC5A869).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(Icons.security_rounded, size: 48, color: Color(0xFFC5A869)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Вход в систему управления',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Доступ к базе данных пользователей и системным параметрам',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _adminLoginController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Логин администратора',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFC5A869), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1E242C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _adminPassController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Пароль администратора',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFC5A869), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1E242C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A869),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _verifyAdminCredentials,
                  child: const Text(
                    'ВОЙТИ КАК АДМИНИСТРАТОР',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final filteredUsers = _users.where((u) {
      final q = _searchQuery.toLowerCase();
      final username = (u['username'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final name = (u['display_name'] ?? '').toString().toLowerCase();
      return username.contains(q) || email.contains(q) || name.contains(q);
    }).toList();

    return RefreshIndicator(
      color: const Color(0xFFC5A869),
      onRefresh: _fetchAdminUsers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatTile('ВСЕГО АТЛЕТОВ', '${_users.length}', Icons.group_rounded, const Color(0xFFC5A869)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    'АДМИНЫ',
                    '${_users.where((u) => u['is_staff'] == true).length}',
                    Icons.verified_user_rounded,
                    Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile('БД DJANGO', 'ONLINE', Icons.check_circle_rounded, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Поиск по имени, email или username...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFC5A869), size: 20),
                filled: true,
                fillColor: const Color(0xFF2C3440),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Users List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ПОЛЬЗОВАТЕЛИ В БАЗЕ ДАННЫХ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${filteredUsers.length} записей',
                  style: const TextStyle(color: Color(0xFFC5A869), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFC5A869))),
              )
            else if (filteredUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3440),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('Пользователи не найдены', style: TextStyle(color: Colors.white54)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final u = filteredUsers[index];
                  final isStaff = u['is_staff'] == true;
                  final displayName = u['display_name']?.toString() ?? u['username']?.toString() ?? 'Пользователь';
                  final email = u['email']?.toString() ?? '-';
                  final username = u['username']?.toString() ?? '-';
                  final joined = u['date_joined']?.toString() ?? '';
                  final city = u['city']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3440),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isStaff ? const Color(0xFFC5A869).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isStaff ? const Color(0xFFC5A869) : const Color(0xFF1E242C),
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: isStaff ? Colors.black : const Color(0xFFC5A869),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isStaff) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC5A869),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@$username • $email',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                              if (city.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: Color(0xFFC5A869), size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      city,
                                      style: const TextStyle(color: Color(0xFFC5A869), fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                              if (joined.isNotEmpty)
                                Text(
                                  'Регистрация: $joined',
                                  style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'АКТИВЕН',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Logout from Admin Panel button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.exit_to_app, color: Colors.white60, size: 18),
              label: const Text(
                'Выйти из панели управления',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              onPressed: () {
                setState(() {
                  _isAdminUnlocked = false;
                  _adminPassController.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3440),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
