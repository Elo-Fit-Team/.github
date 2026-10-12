class LeaderboardRowModel {
  final int rank;
  final int userId;
  final String username;
  final String displayName;
  final String? city;
  final dynamic score;

  LeaderboardRowModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.displayName,
    this.city,
    required this.score,
  });

  factory LeaderboardRowModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardRowModel(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? 'Player',
      city: json['city'] as String?,
      score: json['score'],
    );
  }

  String get formattedScore {
    if (score == null) return '0';
    if (score is num) {
      if (score is double) return (score as double).toStringAsFixed(1);
      return score.toString();
    }
    return score.toString();
  }
}
