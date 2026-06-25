enum BiologicalSex { male, female }

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get label => const [
        'Sedentary (little or no exercise)',
        'Lightly active (1–3 days/week)',
        'Moderately active (3–5 days/week)',
        'Very active (6–7 days/week)',
        'Extra active (physical job + training)',
      ][index];

  double get multiplier =>
      const [1.2, 1.375, 1.55, 1.725, 1.9][index];
}

enum WeightGoal {
  lose,
  maintain,
  gain;

  String get label => const ['Lose weight', 'Maintain weight', 'Gain weight'][index];
  int get calorieAdjustment => const [-500, 0, 300][index];
}

class UserProfile {
  final int age;
  final BiologicalSex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final WeightGoal weightGoal;

  const UserProfile({
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.weightGoal,
  });

  // Mifflin-St Jeor
  double get bmr => sex == BiologicalSex.male
      ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
      : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

  double get tdee => bmr * activityLevel.multiplier;

  int get suggestedCalories =>
      (tdee + weightGoal.calorieAdjustment).clamp(1200, 6000).round();

  // 30% protein, 40% carbs, 30% fat
  int get suggestedProtein => (suggestedCalories * 0.30 / 4).round();
  int get suggestedCarbs => (suggestedCalories * 0.40 / 4).round();
  int get suggestedFat => (suggestedCalories * 0.30 / 9).round();

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'sex': sex.index,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activityLevel': activityLevel.index,
        'weightGoal': weightGoal.index,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        age: (j['age'] as num).toInt(),
        sex: BiologicalSex.values[(j['sex'] as num).toInt()],
        heightCm: (j['heightCm'] as num).toDouble(),
        weightKg: (j['weightKg'] as num).toDouble(),
        activityLevel:
            ActivityLevel.values[(j['activityLevel'] as num).toInt()],
        weightGoal: WeightGoal.values[(j['weightGoal'] as num).toInt()],
      );
}
