/// User-defined daily nutrition targets.
class NutritionGoals {
  final int dailyCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  const NutritionGoals({
    required this.dailyCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  /// Sensible defaults (2000 kcal, 150g protein, 200g carbs, 65g fat).
  const NutritionGoals.defaults()
      : dailyCalories = 2000,
        proteinGrams = 150,
        carbsGrams = 200,
        fatGrams = 65;

  NutritionGoals copyWith({
    int? dailyCalories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
  }) =>
      NutritionGoals(
        dailyCalories: dailyCalories ?? this.dailyCalories,
        proteinGrams: proteinGrams ?? this.proteinGrams,
        carbsGrams: carbsGrams ?? this.carbsGrams,
        fatGrams: fatGrams ?? this.fatGrams,
      );

  Map<String, dynamic> toJson() => {
        'dailyCalories': dailyCalories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
      };

  factory NutritionGoals.fromJson(Map<String, dynamic> j) => NutritionGoals(
        dailyCalories: (j['dailyCalories'] as num).toInt(),
        proteinGrams: (j['proteinGrams'] as num).toInt(),
        carbsGrams: (j['carbsGrams'] as num).toInt(),
        fatGrams: (j['fatGrams'] as num).toInt(),
      );
}
