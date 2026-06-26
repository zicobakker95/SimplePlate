import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/models/food_item.dart';

void main() {
  group('FoodItem', () {
    test('toJson/fromJson round trip preserves all fields', () {
      const item = FoodItem(
        id: 'abc123',
        name: 'Banana',
        brand: 'Chiquita',
        caloriesPer100: 89,
        proteinPer100: 1.1,
        carbsPer100: 22.8,
        fatPer100: 0.3,
        imageUrl: 'https://example.com/banana.png',
        isFavourite: true,
        isCustom: false,
      );

      final decoded = FoodItem.fromJson(item.toJson());

      expect(decoded.id, item.id);
      expect(decoded.name, item.name);
      expect(decoded.brand, item.brand);
      expect(decoded.caloriesPer100, item.caloriesPer100);
      expect(decoded.proteinPer100, item.proteinPer100);
      expect(decoded.carbsPer100, item.carbsPer100);
      expect(decoded.fatPer100, item.fatPer100);
      expect(decoded.imageUrl, item.imageUrl);
      expect(decoded.isFavourite, item.isFavourite);
      expect(decoded.isCustom, item.isCustom);
    });

    test('fromJson fills in defaults for missing optional fields', () {
      final decoded = FoodItem.fromJson({
        'id': 'x',
        'name': 'Apple',
        'caloriesPer100': 52,
        'proteinPer100': 0.3,
        'carbsPer100': 14,
        'fatPer100': 0.2,
      });

      expect(decoded.brand, '');
      expect(decoded.imageUrl, isNull);
      expect(decoded.isFavourite, false);
      expect(decoded.isCustom, false);
    });

    test('caloriesFor/proteinFor/carbsFor/fatFor scale by serving size', () {
      const item = FoodItem(
        id: 'x',
        name: 'Rice',
        caloriesPer100: 130,
        proteinPer100: 2.7,
        carbsPer100: 28,
        fatPer100: 0.3,
      );

      expect(item.caloriesFor(200), 260);
      expect(item.proteinFor(200), closeTo(5.4, 0.001));
      expect(item.carbsFor(50), 14);
      expect(item.fatFor(50), closeTo(0.15, 0.001));
    });

    test('equality and hashCode are based on id only', () {
      const a = FoodItem(id: 'same', name: 'A', caloriesPer100: 1, proteinPer100: 1, carbsPer100: 1, fatPer100: 1);
      const b = FoodItem(id: 'same', name: 'B', caloriesPer100: 2, proteinPer100: 2, carbsPer100: 2, fatPer100: 2);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith updates isFavourite without affecting other fields', () {
      const item = FoodItem(
        id: 'x',
        name: 'Bread',
        caloriesPer100: 265,
        proteinPer100: 9,
        carbsPer100: 49,
        fatPer100: 3.2,
      );

      final updated = item.copyWith(isFavourite: true);

      expect(updated.isFavourite, true);
      expect(updated.name, item.name);
      expect(updated.caloriesPer100, item.caloriesPer100);
    });
  });
}
