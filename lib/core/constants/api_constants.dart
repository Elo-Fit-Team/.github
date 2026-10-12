import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Default base URLs depending on platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/';
    }
    return 'http://127.0.0.1:8000/api/';
  }

  // Auth endpoints
  static const String authFirebase = 'auth/firebase/';
  static const String authTokenRefresh = 'auth/token/refresh/';
  static const String authLogout = 'auth/logout/';
  static const String usersMe = 'users/me/';
  static const String usersDelete = 'users/me/deletion/';
  static const String usersDeleteCancel = 'users/me/deletion/cancel/';

  // Game & Profile endpoints
  static const String playersMe = 'players/me/';
  static const String hub = 'hub/';
  static const String leaderboard = 'leaderboard/';
  static const String characters = 'characters/';
  static const String myCharacters = 'characters/mine/';
  static const String weeklyChallenges = 'weekly-challenges/';
  static const String achievements = 'achievements/';
  static const String rewards = 'rewards/';
  static const String notifications = 'notifications/';
  static const String cities = 'cities/';
  static const String citiesResolve = 'cities/resolve/';

  // Workouts & Plans
  static const String exercises = 'exercises/';
  static const String plans = 'plans/';
  static const String workouts = 'workouts/';
  static const String evidenceUploads = 'evidence/uploads/';

  // Community
  static const String posts = 'posts/';
  static const String follows = 'follows/';
  static const String reports = 'reports/';
}
