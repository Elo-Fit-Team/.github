class ExerciseModel {
  final int id;
  final String slug;
  final String name;
  final String category; // strength | cardio
  final String instructions;
  final bool isRanked;
  final bool countsForTotal;

  ExerciseModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.instructions,
    required this.isRanked,
    required this.countsForTotal,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'strength',
      instructions: json['instructions'] as String? ?? '',
      isRanked: json['is_ranked'] as bool? ?? false,
      countsForTotal: json['counts_for_total'] as bool? ?? false,
    );
  }
}
