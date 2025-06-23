/// Service for calculating nutrition targets based on user profile
class NutritionCalculator {
  /// Calculate Total Daily Energy Expenditure (TDEE)
  static double calculateTdee({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String activityLevel,
  }) {
    // Basal Metabolic Rate (BMR) calculation using Mifflin-St Jeor Equation
    double bmr;
    if (gender.toLowerCase() == "male") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Activity level multipliers
    Map<String, double> activityFactors = {
      "sedentary": 1.2,
      "lightly active": 1.375,
      "moderately active": 1.55,
      "very active": 1.725,
      "extra active": 1.9
    };

    double activityFactor = activityFactors[activityLevel.toLowerCase()] ?? 1.2;
    double tdee = bmr * activityFactor;
    return tdee;
  }

  /// Get macro targets based on TDEE and goal
  static Map<String, double> getMacroTargets({
    required double tdee,
    required String goal,
  }) {
    // Adjust TDEE based on goal
    double adjustedTdee = tdee;
    if (goal.toLowerCase().contains("gain")) {
      adjustedTdee += 200;
    } else if (goal.toLowerCase().contains("lose")) {
      adjustedTdee -= 200;
    }

    // Macro ratios based on goal
    double proteinRatio, fatRatio, carbRatio;

    if (goal.toLowerCase().contains("sport")) {
      proteinRatio = 0.20;
      fatRatio = 0.25;
      carbRatio = 0.55;
    } else {
      proteinRatio = 0.15;
      fatRatio = 0.25;
      carbRatio = 0.60;
    }

    // Calculate macro targets in grams
    double proteinG =
        (adjustedTdee * proteinRatio) / 4; // 4 calories per gram of protein
    double fatG = (adjustedTdee * fatRatio) / 9; // 9 calories per gram of fat
    double carbG =
        (adjustedTdee * carbRatio) / 4; // 4 calories per gram of carbs

    return {
      'tdee': adjustedTdee,
      'protein_g': proteinG,
      'fat_g': fatG,
      'carb_g': carbG,
    };
  }

  /// Calculate nutrition targets for a specific number of days
  static Map<String, double> getDailyTargets({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String activityLevel,
    required String goal,
    int days = 30,
  }) {
    double tdee = calculateTdee(
      age: age,
      gender: gender,
      weight: weight,
      height: height,
      activityLevel: activityLevel,
    );

    Map<String, double> macroTargets = getMacroTargets(
      tdee: tdee,
      goal: goal,
    );

    return {
      'calories': macroTargets['tdee']! * days,
      'protein_g': macroTargets['protein_g']! * days,
      'fat_g': macroTargets['fat_g']! * days,
      'carb_g': macroTargets['carb_g']! * days,
    };
  }
}
