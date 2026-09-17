import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// ── Table definitions ───────────────────────────────────────────────────────

class FoodEntries extends Table {
  TextColumn get id => text()();
  TextColumn get foodItemId => text()();
  TextColumn get foodName => text()();
  TextColumn get foodBrand => text().withDefault(const Constant(''))();
  RealColumn get servingGrams => real()();
  RealColumn get caloriesPer100 => real()();
  RealColumn get proteinPer100 => real()();
  RealColumn get carbsPer100 => real()();
  RealColumn get fatPer100 => real()();
  TextColumn get meal => text()();
  DateTimeColumn get loggedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WeightEntries extends Table {
  TextColumn get id => text()();
  RealColumn get kg => real()();
  DateTimeColumn get loggedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ActivityEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get caloriesBurned => integer()();
  IntColumn get durationMinutes => integer()();
  DateTimeColumn get loggedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomFoods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  RealColumn get caloriesPer100 => real()();
  RealColumn get proteinPer100 => real()();
  RealColumn get carbsPer100 => real()();
  RealColumn get fatPer100 => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Open Food Facts text searches, one row per normalised query. Results are
/// stored as the JSON the app already uses for favourites, so a cached hit
/// is the same [FoodItem] list a live search would have produced.
class SearchCacheEntries extends Table {
  TextColumn get normalisedQuery => text()();
  TextColumn get resultsJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {normalisedQuery};
}

/// Barcode lookups that found a product. Misses are not cached: a product
/// scanned today may well be in the database next week.
class BarcodeCacheEntries extends Table {
  TextColumn get barcode => text()();
  TextColumn get productJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {barcode};
}

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get servings => integer()();
  TextColumn get ingredientsJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  FoodEntries,
  WeightEntries,
  ActivityEntries,
  CustomFoods,
  Recipes,
  SearchCacheEntries,
  BarcodeCacheEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests: `AppDatabase.withExecutor(NativeDatabase.memory())`.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(searchCacheEntries);
            await m.createTable(barcodeCacheEntries);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'plate_simple_db');
  }

  // ── Food entries ──────────────────────────────────────────────────────────

  Future<List<FoodEntry>> allFoodEntries() =>
      select(foodEntries).get();

  Stream<List<FoodEntry>> watchFoodEntries() =>
      select(foodEntries).watch();

  Future<int> insertFoodEntry(FoodEntriesCompanion entry) =>
      into(foodEntries).insert(entry);

  Future<bool> deleteFoodEntry(String id) async {
    final count = await (delete(foodEntries)
          ..where((t) => t.id.equals(id)))
        .go();
    return count > 0;
  }

  Future<void> updateFoodEntryGrams(String id, double grams) async {
    await (update(foodEntries)..where((t) => t.id.equals(id)))
        .write(FoodEntriesCompanion(servingGrams: Value(grams)));
  }

  // ── Weight entries ────────────────────────────────────────────────────────

  Future<List<WeightEntry>> allWeightEntries() =>
      (select(weightEntries)
            ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
          .get();

  Future<int> insertWeightEntry(WeightEntriesCompanion entry) =>
      into(weightEntries).insert(entry);

  // ── Activity entries ──────────────────────────────────────────────────────

  Future<List<ActivityEntry>> allActivityEntries() =>
      select(activityEntries).get();

  Future<int> insertActivityEntry(ActivityEntriesCompanion entry) =>
      into(activityEntries).insert(entry);

  Future<bool> deleteActivityEntry(String id) async {
    final count = await (delete(activityEntries)
          ..where((t) => t.id.equals(id)))
        .go();
    return count > 0;
  }

  // ── Custom foods ──────────────────────────────────────────────────────────

  Future<List<CustomFood>> allCustomFoods() =>
      select(customFoods).get();

  Future<int> insertCustomFood(CustomFoodsCompanion food) =>
      into(customFoods).insert(food);

  Future<bool> deleteCustomFood(String id) async {
    final count = await (delete(customFoods)
          ..where((t) => t.id.equals(id)))
        .go();
    return count > 0;
  }

  // ── Search / barcode cache ────────────────────────────────────────────────

  Future<SearchCacheEntry?> searchCacheFor(String normalisedQuery) =>
      (select(searchCacheEntries)
            ..where((t) => t.normalisedQuery.equals(normalisedQuery)))
          .getSingleOrNull();

  Future<void> upsertSearchCache(SearchCacheEntriesCompanion entry) =>
      into(searchCacheEntries).insertOnConflictUpdate(entry);

  Future<BarcodeCacheEntry?> barcodeCacheFor(String barcode) =>
      (select(barcodeCacheEntries)..where((t) => t.barcode.equals(barcode)))
          .getSingleOrNull();

  Future<void> upsertBarcodeCache(BarcodeCacheEntriesCompanion entry) =>
      into(barcodeCacheEntries).insertOnConflictUpdate(entry);

  /// Removes cache rows fetched before [cutoff]. Returns rows deleted.
  Future<int> pruneCacheBefore(DateTime cutoff) async {
    final a = await (delete(searchCacheEntries)
          ..where((t) => t.fetchedAt.isSmallerThanValue(cutoff)))
        .go();
    final b = await (delete(barcodeCacheEntries)
          ..where((t) => t.fetchedAt.isSmallerThanValue(cutoff)))
        .go();
    return a + b;
  }

  // ── Recipes ───────────────────────────────────────────────────────────────

  Future<List<Recipe>> allRecipes() => select(recipes).get();

  Future<int> upsertRecipe(RecipesCompanion recipe) =>
      into(recipes).insertOnConflictUpdate(recipe);

  Future<bool> deleteRecipe(String id) async {
    final count = await (delete(recipes)..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}
