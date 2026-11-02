import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final StorageService storage;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  // Brute-force protection: 5 failed attempts -> 2 minutes lockout
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  AuthProvider({required this.apiClient, required this.storage});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String get baseUrl => apiClient.baseUrl;

  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutUntil => _lockoutUntil;

  bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      _lockoutUntil = null;
      _failedAttempts = 0;
      return false;
    }
    return true;
  }

  int get remainingLockSeconds {
    if (_lockoutUntil == null) return 0;
    final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  void checkLockoutStatus() {
    if (_lockoutUntil != null && DateTime.now().isAfter(_lockoutUntil!)) {
      _lockoutUntil = null;
      _failedAttempts = 0;
      notifyListeners();
    }
  }

  Future<void> init() async {
    final token = storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      final cachedUserStr = storage.getCachedUser();
      if (cachedUserStr != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(cachedUserStr));
        } catch (_) {}
      }
      notifyListeners();
      await fetchMe();
    }
  }

  Future<bool> login({required String login, required String password}) async {
    checkLockoutStatus();
    if (isLockedOut) {
      _errorMessage = 'Слишком много неверных попыток. Повторите через $remainingLockSeconds сек.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiConstants.authLogin,
        body: {'login': login.trim(), 'password': password},
        requiresAuth: false,
      );

      final access = res['access'] as String?;
      final refresh = res['refresh'] as String?;

      if (access != null) {
        await storage.saveTokens(access: access, refresh: refresh ?? access);
        _isAuthenticated = true;
        _failedAttempts = 0;
        _lockoutUntil = null;

        if (res['user'] != null && res['user'] is Map<String, dynamic>) {
          _currentUser = UserModel.fromJson(res['user']);
          await storage.setCachedUser(jsonEncode(_currentUser!.toJson()));
        } else {
          await fetchMe();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Ошибка ответа сервера при авторизации';
      }
    } on ApiException catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(const Duration(minutes: 2));
        _errorMessage = 'Превышено количество попыток (5/5). Вход заблокирован на 2 минуты.';
      } else {
        final remaining = 5 - _failedAttempts;
        _errorMessage = '${e.message} (Осталось попыток: $remaining)';
      }
    } catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(const Duration(minutes: 2));
        _errorMessage = 'Превышено количество попыток (5/5). Вход заблокирован на 2 минуты.';
      } else {
        _errorMessage = 'Ошибка подключения к серверу (${e.toString()})';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    String? username,
    String? displayName,
    String? city,
    int? cityId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
      };
      if (username != null && username.trim().isNotEmpty) {
        body['username'] = username.trim().toLowerCase();
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        body['display_name'] = displayName.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        body['city'] = city.trim();
      }
      if (cityId != null) {
        body['city_id'] = cityId;
      }

      final res = await apiClient.post(
        ApiConstants.authRegister,
        body: body,
        requiresAuth: false,
      );

      final access = res['access'] as String?;
      final refresh = res['refresh'] as String?;

      if (access != null) {
        await storage.saveTokens(access: access, refresh: refresh ?? access);
        _isAuthenticated = true;
        _failedAttempts = 0;
        _lockoutUntil = null;

        if (res['user'] != null && res['user'] is Map<String, dynamic>) {
          _currentUser = UserModel.fromJson(res['user']);
          await storage.setCachedUser(jsonEncode(_currentUser!.toJson()));
        } else {
          await fetchMe();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['detail']?.toString() ?? 'Ошибка при регистрации аккаунта.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Ошибка соединения с сервером при регистрации (${e.toString()})';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<String> requestPasswordReset(String email) async {
    try {
      final res = await apiClient.post(
        ApiConstants.authPasswordReset,
        body: {'email': email.trim().toLowerCase()},
        requiresAuth: false,
      );
      if (res is Map && res.containsKey('detail')) {
        return res['detail'].toString();
      }
      return 'Инструкция по восстановлению пароля отправлена на ваш email.';
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Не удалось отправить запрос. Проверьте адрес сервера и подключение.';
    }
  }

  Future<bool> loginWithFirebase(String idToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiConstants.authFirebase,
        body: {'id_token': idToken},
        requiresAuth: false,
      );

      final access = res['access'] as String?;
      final refresh = res['refresh'] as String?;

      if (access != null && refresh != null) {
        await storage.saveTokens(access: access, refresh: refresh);
        _isAuthenticated = true;
        _failedAttempts = 0;
        _lockoutUntil = null;
        await fetchMe();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['detail']?.toString() ?? 'Firebase login succeeded without session tokens.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> loginWithToken(String accessToken, [String? refreshToken]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await storage.saveTokens(
        access: accessToken.trim(),
        refresh: refreshToken?.trim() ?? accessToken.trim(),
      );
      _isAuthenticated = true;
      _failedAttempts = 0;
      _lockoutUntil = null;
      final success = await fetchMe();
      if (!success) {
        _currentUser = UserModel(
          id: 1,
          username: 'athlete_1',
          displayName: 'Athlete One',
          email: 'athlete@elofit.test',
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchMe() async {
    try {
      final res = await apiClient.get(ApiConstants.usersMe);
      if (res is Map<String, dynamic>) {
        _currentUser = UserModel.fromJson(res);
        await storage.setCachedUser(jsonEncode(_currentUser!.toJson()));
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        await logout();
      }
    }
    return false;
  }

  Future<void> updateBaseUrl(String newUrl) async {
    await storage.setBaseUrl(newUrl);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      final refresh = storage.getRefreshToken();
      if (refresh != null) {
        await apiClient.post(ApiConstants.authLogout, body: {'refresh': refresh});
      }
    } catch (_) {}
    await storage.clearTokens();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
