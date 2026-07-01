/// Household serving units the user can log with, besides plain grams.
///
/// Volume/piece units convert to grams with a fixed approximation (foods vary,
/// but this is far friendlier than forcing everyone to think in grams). The
/// nutrition math always runs on the resolved gram amount.
enum ServingUnit { grams, tablespoon, teaspoon, cup, piece }

extension ServingUnitData on ServingUnit {
  /// Approximate grams in one of this unit.
  double get gramsPerUnit => switch (this) {
        ServingUnit.grams => 1,
        ServingUnit.tablespoon => 15, // ~1 US/metric tbsp
        ServingUnit.teaspoon => 5, // ~1 tsp
        ServingUnit.cup => 240, // ~1 cup
        ServingUnit.piece => 50, // rough "1 item"
      };

  /// Sensible starting quantity when the unit is selected.
  double get defaultQuantity => this == ServingUnit.grams ? 100 : 1;

  /// Whether the gram equivalent is only approximate (worth showing "≈ N g").
  bool get isApproximate => this != ServingUnit.grams;
}
