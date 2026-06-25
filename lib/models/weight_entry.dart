class WeightEntry {
  final String id;
  final double kg;
  final DateTime loggedAt;

  const WeightEntry({
    required this.id,
    required this.kg,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'kg': kg,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
        id: j['id'] as String,
        kg: (j['kg'] as num).toDouble(),
        loggedAt: DateTime.parse(j['loggedAt'] as String),
      );
}
