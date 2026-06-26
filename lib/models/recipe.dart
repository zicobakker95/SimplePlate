import 'food_item.dart';

class RecipeIngredient {
  const RecipeIngredient({required this.item, required this.grams});

  final FoodItem item;
  final double grams;

  double get calories => item.caloriesPer100 * grams / 100;
  double get protein => item.proteinPer100 * grams / 100;
  double get carbs => item.carbsPer100 * grams / 100;
  double get fat => item.fatPer100 * grams / 100;

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'grams': grams,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> j) =>
      RecipeIngredient(
        item: FoodItem.fromJson(j['item'] as Map<String, dynamic>),
        grams: (j['grams'] as num).toDouble(),
      );
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    this.description = '',
    required this.servings,
    required this.ingredients,
  });

  final String id;
  final String name;
  final String description;
  final int servings;
  final List<RecipeIngredient> ingredients;

  double get totalCalories =>
      ingredients.fold(0, (s, i) => s + i.calories);
  double get totalProtein =>
      ingredients.fold(0, (s, i) => s + i.protein);
  double get totalCarbs =>
      ingredients.fold(0, (s, i) => s + i.carbs);
  double get totalFat =>
      ingredients.fold(0, (s, i) => s + i.fat);

  double get caloriesPerServing => totalCalories / servings;
  double get proteinPerServing => totalProtein / servings;
  double get carbsPerServing => totalCarbs / servings;
  double get fatPerServing => totalFat / servings;

  double get totalGrams =>
      ingredients.fold(0, (s, i) => s + i.grams);
  double get gramsPerServing => totalGrams / servings;

  FoodItem toFoodItem() => FoodItem(
        id: 'recipe-$id',
        name: name,
        brand: description.isNotEmpty ? description : '',
        caloriesPer100: gramsPerServing > 0
            ? caloriesPerServing / gramsPerServing * 100
            : 0,
        proteinPer100: gramsPerServing > 0
            ? proteinPerServing / gramsPerServing * 100
            : 0,
        carbsPer100: gramsPerServing > 0
            ? carbsPerServing / gramsPerServing * 100
            : 0,
        fatPer100: gramsPerServing > 0
            ? fatPerServing / gramsPerServing * 100
            : 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'servings': servings,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        servings: (j['servings'] as num).toInt(),
        ingredients: (j['ingredients'] as List<dynamic>)
            .map((i) =>
                RecipeIngredient.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
