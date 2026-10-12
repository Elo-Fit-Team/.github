class PostModel {
  final int id;
  final String workout;
  final int authorId;
  final String username;
  final int character;
  final String caption;
  final String visibility;
  final bool isRanked;
  final String? startedAt;
  final String? createdAt;
  final int likeCount;
  final int commentCount;
  final List<dynamic> results;

  PostModel({
    required this.id,
    required this.workout,
    required this.authorId,
    required this.username,
    required this.character,
    required this.caption,
    required this.visibility,
    required this.isRanked,
    this.startedAt,
    this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.results,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      workout: json['workout']?.toString() ?? '',
      authorId: json['author_id'] is int ? json['author_id'] : 0,
      username: json['username'] as String? ?? 'Athlete',
      character: json['character'] is int ? json['character'] : 1,
      caption: json['caption'] as String? ?? '',
      visibility: json['visibility'] as String? ?? 'public',
      isRanked: json['is_ranked'] as bool? ?? true,
      startedAt: json['started_at'] as String?,
      createdAt: json['created_at'] as String?,
      likeCount: json['like_count'] is int ? json['like_count'] : 0,
      commentCount: json['comment_count'] is int ? json['comment_count'] : 0,
      results: json['results'] as List? ?? [],
    );
  }
}
