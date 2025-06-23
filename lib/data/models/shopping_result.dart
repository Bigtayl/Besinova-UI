/// ShoppingResult model representing optimization results
class ShoppingResult {
  final double totalCost;
  final double budgetUsage;
  final int totalItems;
  final double totalWeight;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const ShoppingResult({
    required this.totalCost,
    required this.budgetUsage,
    required this.totalItems,
    required this.totalWeight,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  /// Creates a ShoppingResult from JSON data
  factory ShoppingResult.fromJson(Map<String, dynamic> json) => ShoppingResult(
        totalCost: (json['totalCost'] ?? json['total_cost']) as double,
        budgetUsage: (json['budgetUsage'] ?? json['budget_usage']) as double,
        totalItems: (json['totalItems'] ?? json['total_items']) as int,
        totalWeight: (json['totalWeight'] ?? json['total_weight']) as double,
        calories: (json['calories'] ?? 0.0) as double,
        protein: (json['protein'] ?? 0.0) as double,
        fat: (json['fat'] ?? 0.0) as double,
        carbs: (json['carbs'] ?? 0.0) as double,
      );

  /// Converts ShoppingResult to JSON data
  Map<String, dynamic> toJson() => {
        'totalCost': totalCost,
        'budgetUsage': budgetUsage,
        'totalItems': totalItems,
        'totalWeight': totalWeight,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      };

  /// Creates a copy of this ShoppingResult with updated fields
  ShoppingResult copyWith({
    double? totalCost,
    double? budgetUsage,
    int? totalItems,
    double? totalWeight,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) =>
      ShoppingResult(
        totalCost: totalCost ?? this.totalCost,
        budgetUsage: budgetUsage ?? this.budgetUsage,
        totalItems: totalItems ?? this.totalItems,
        totalWeight: totalWeight ?? this.totalWeight,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        fat: fat ?? this.fat,
        carbs: carbs ?? this.carbs,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShoppingResult && other.totalCost == totalCost;

  @override
  int get hashCode => totalCost.hashCode;

  @override
  String toString() =>
      'ShoppingResult(totalCost: $totalCost, budgetUsage: $budgetUsage, totalItems: $totalItems, totalWeight: $totalWeight, calories: $calories, protein: $protein, fat: $fat, carbs: $carbs)';
} 