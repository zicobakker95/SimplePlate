class ActivityEntry {
  final String id;
  final String name;
  final int caloriesBurned;
  final int durationMinutes;
  final DateTime loggedAt;

  const ActivityEntry({
    required this.id,
    required this.name,
    required this.caloriesBurned,
    required this.durationMinutes,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'caloriesBurned': caloriesBurned,
        'durationMinutes': durationMinutes,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory ActivityEntry.fromJson(Map<String, dynamic> j) => ActivityEntry(
        id: j['id'] as String,
        name: j['name'] as String,
        caloriesBurned: (j['caloriesBurned'] as num).toInt(),
        durationMinutes: (j['durationMinutes'] as num).toInt(),
        loggedAt: DateTime.parse(j['loggedAt'] as String),
      );
}
