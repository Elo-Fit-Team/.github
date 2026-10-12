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

  AuthProvider({required this.apiClient, required this.storage});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String get baseUrl => apiClient.baseUrl;

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
