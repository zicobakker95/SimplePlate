/// A food product from the Open Food Facts database or custom user entry.
/// All macro values are per 100 g / 100 ml.
class FoodItem {
  final String id; // barcode or generated UUID
  final String name;
  final String brand;
  final double caloriesPer100;
  final double proteinPer100;
  final double carbsPer100;
  final double fatPer100;
  final String? imageUrl;
  final bool isFavourite;
  final bool isCustom;

  const FoodItem({
    required this.id,
    required this.name,
    this.brand = '',
    required this.caloriesPer100,
    required this.proteinPer100,
    required this.carbsPer100,
    required this.fatPer100,
    this.imageUrl,
    this.isFavourite = false,
    this.isCustom = false,
  });

  /// Calories for a specific serving size in grams.
  double caloriesFor(double grams) => caloriesPer100 * grams / 100;
  double proteinFor(double grams) => proteinPer100 * grams / 100;
  double carbsFor(double grams) => carbsPer100 * grams / 100;
  double fatFor(double grams) => fatPer100 * grams / 100;

  FoodItem copyWith({bool? isFavourite}) => FoodItem(
        id: id,
        name: name,
        brand: brand,
        caloriesPer100: caloriesPer100,
        proteinPer100: proteinPer100,
        carbsPer100: carbsPer100,
        fatPer100: fatPer100,
        imageUrl: imageUrl,
        isFavourite: isFavourite ?? this.isFavourite,
        isCustom: isCustom,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'caloriesPer100': caloriesPer100,
        'proteinPer100': proteinPer100,
        'carbsPer100': carbsPer100,
        'fatPer100': fatPer100,
        'imageUrl': imageUrl,
        'isFavourite': isFavourite,
        'isCustom': isCustom,
      };

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        id: j['id'] as String,
        name: j['name'] as String,
        brand: (j['brand'] as String?) ?? '',
        caloriesPer100: (j['caloriesPer100'] as num).toDouble(),
        proteinPer100: (j['proteinPer100'] as num).toDouble(),
        carbsPer100: (j['carbsPer100'] as num).toDouble(),
        fatPer100: (j['fatPer100'] as num).toDouble(),
        imageUrl: j['imageUrl'] as String?,
        isFavourite: (j['isFavourite'] as bool?) ?? false,
        isCustom: (j['isCustom'] as bool?) ?? false,
      );

  @override
  bool operator ==(Object other) => other is FoodItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
