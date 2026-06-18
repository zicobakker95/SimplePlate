/// Which meal of the day this entry belongs to.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// A single logged food entry tied to a day and meal.
class FoodEntry {
  final String id;
  final String foodItemId;
  final String foodName;
  final String foodBrand;
  final double servingGrams;
  final double caloriesPer100;
  final double proteinPer100;
  final double carbsPer100;
  final double fatPer100;
  final MealType meal;
  final DateTime loggedAt;

  const FoodEntry({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    this.foodBrand = '',
    required this.servingGrams,
    required this.caloriesPer100,
    required this.proteinPer100,
    required this.carbsPer100,
    required this.fatPer100,
    required this.meal,
    required this.loggedAt,
  });

  double get calories => caloriesPer100 * servingGrams / 100;
  double get protein => proteinPer100 * servingGrams / 100;
  double get carbs => carbsPer100 * servingGrams / 100;
  double get fat => fatPer100 * servingGrams / 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'foodItemId': foodItemId,
        'foodName': foodName,
        'foodBrand': foodBrand,
        'servingGrams': servingGrams,
        'caloriesPer100': caloriesPer100,
        'proteinPer100': proteinPer100,
        'carbsPer100': carbsPer100,
        'fatPer100': fatPer100,
        'meal': meal.name,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory FoodEntry.fromJson(Map<String, dynamic> j) => FoodEntry(
        id: j['id'] as String,
        foodItemId: j['foodItemId'] as String,
        foodName: j['foodName'] as String,
        foodBrand: (j['foodBrand'] as String?) ?? '',
        servingGrams: (j['servingGrams'] as num).toDouble(),
        caloriesPer100: (j['caloriesPer100'] as num).toDouble(),
        proteinPer100: (j['proteinPer100'] as num).toDouble(),
        carbsPer100: (j['carbsPer100'] as num).toDouble(),
        fatPer100: (j['fatPer100'] as num).toDouble(),
        meal: MealType.values.firstWhere((m) => m.name == j['meal'],
            orElse: () => MealType.snack),
        loggedAt: DateTime.parse(j['loggedAt'] as String),
      );
}
