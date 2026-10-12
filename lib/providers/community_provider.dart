import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/post_model.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _error;
  List<PostModel> _posts = [];
  List<PostModel> _reviewPosts = [];

  CommunityProvider({required this.apiClient});

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PostModel> get posts => _posts;
  List<PostModel> get reviewPosts => _reviewPosts;

  Future<void> fetchFeed({String? feed}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = feed != null ? {'feed': feed} : null;
      final res = await apiClient.get(ApiConstants.posts, queryParams: query);
      final list = (res is Map && res.containsKey('results')) ? res['results'] as List : (res as List? ?? []);
      _posts = list.map((p) => PostModel.fromJson(p as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReviewQueue() async {
    try {
      final res = await apiClient.get(ApiConstants.posts, queryParams: {'feed': 'reviews'});
      final list = (res is Map && res.containsKey('results')) ? res['results'] as List : (res as List? ?? []);
      _reviewPosts = list.map((p) => PostModel.fromJson(p as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleLike(int postId, bool currentlyLiked) async {
    try {
      if (currentlyLiked) {
        await apiClient.delete('${ApiConstants.posts}$postId/like/');
      } else {
        await apiClient.post('${ApiConstants.posts}$postId/like/');
      }
      await fetchFeed();
    } catch (_) {}
  }

  Future<bool> voteOnResult({
    required String resultUuid,
    required int revision,
    required bool isTruthful,
    String? reason,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{
        'revision': revision,
        'is_truthful': isTruthful,
      };
      if (!isTruthful) {
        body['reason'] = reason ?? 'other';
        body['comment'] = comment ?? 'Technique does not meet standards';
      }
      await apiClient.post('results/$resultUuid/votes/', body: body);
      await fetchReviewQueue();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
