import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/leaderboard_model.dart';

class LeaderboardProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _error;
  List<LeaderboardRowModel> _rows = [];

  String _metric = 'elo'; // elo, absolute, relative
  String _scope = 'city'; // city, country, world
  final String _country = 'KZ';
  final int _cityId = 1;

  LeaderboardProvider({required this.apiClient}) {
    _initFallbackRows();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LeaderboardRowModel> get rows => _rows;
  String get metric => _metric;
  String get scope => _scope;

  void _initFallbackRows() {
    _rows = [
      LeaderboardRowModel(rank: 1, userId: 1, username: 'aidar_fit', displayName: 'Айдар К.', city: 'Алматы', score: 1480),
      LeaderboardRowModel(rank: 2, userId: 2, username: 'timur_power', displayName: 'Тимур С.', city: 'Алматы', score: 1395),
      LeaderboardRowModel(rank: 3, userId: 3, username: 'diana_run', displayName: 'Диана М.', city: 'Астана', score: 1310),
      LeaderboardRowModel(rank: 4, userId: 4, username: 'erlan_beast', displayName: 'Ерлан Б.', city: 'Алматы', score: 1250),
      LeaderboardRowModel(rank: 5, userId: 5, username: 'athlete', displayName: 'Athlete (Вы)', city: 'Алматы', score: 1120),
    ];
  }

  Future<void> setMetric(String metric) async {
    _metric = metric;
    notifyListeners();
    await fetchLeaderboard();
  }

  Future<void> setScope(String scope) async {
    _scope = scope;
    notifyListeners();
    await fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{
        'metric': _metric,
        'scope': _scope,
      };

      if (_scope == 'country') {
        params['country'] = _country;
      } else if (_scope == 'city') {
        params['city'] = _cityId;
      }

      final res = await apiClient.get(ApiConstants.leaderboard, queryParams: params);
      final list = (res is Map && res.containsKey('results'))
          ? res['results'] as List
          : (res as List? ?? []);

      if (list.isNotEmpty) {
        _rows = list.map((r) => LeaderboardRowModel.fromJson(r as Map<String, dynamic>)).toList();
      } else if (_rows.isEmpty) {
        _initFallbackRows();
      }
    } catch (_) {
      if (_rows.isEmpty) {
        _initFallbackRows();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
