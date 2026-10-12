import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAccessToken = 'elofit_access_token';
  static const String _keyRefreshToken = 'elofit_refresh_token';
  static const String _keyBaseUrl = 'elofit_base_url';
  static const String _keyCachedHub = 'elofit_cached_hub';
  static const String _keyCachedUser = 'elofit_cached_user';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String? getAccessToken() => _prefs.getString(_keyAccessToken);
  Future<void> setAccessToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_keyAccessToken);
    } else {
      await _prefs.setString(_keyAccessToken, token);
    }
  }

  String? getRefreshToken() => _prefs.getString(_keyRefreshToken);
  Future<void> setRefreshToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_keyRefreshToken);
    } else {
      await _prefs.setString(_keyRefreshToken, token);
    }
  }

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _prefs.setString(_keyAccessToken, access);
    await _prefs.setString(_keyRefreshToken, refresh);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
  }

  String? getBaseUrl() => _prefs.getString(_keyBaseUrl);
  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  String? getCachedHub() => _prefs.getString(_keyCachedHub);
  Future<void> setCachedHub(String jsonStr) async {
    await _prefs.setString(_keyCachedHub, jsonStr);
  }

  String? getCachedUser() => _prefs.getString(_keyCachedUser);
  Future<void> setCachedUser(String jsonStr) async {
    await _prefs.setString(_keyCachedUser, jsonStr);
  }
}
