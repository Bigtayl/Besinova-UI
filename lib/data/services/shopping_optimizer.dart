import '../models/product.dart';
import '../models/optimization_result.dart';
import '../models/shopping_item.dart';
import '../models/shopping_result.dart';
import 'data_preprocessor.dart';
import 'dart:math';

/// Comprehensive shopping optimizer implementing all constraints from Python algorithm
class ShoppingOptimizer {
  /// Main optimization function with comprehensive constraints
  static OptimizationResult? optimizeShopping({
    required List<Product> products,
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String activityLevel,
    required String goal,
    required double budget,
    int days = 30,
  }) {
    try {
      print(
          "=== COMPREHENSIVE OPTIMIZATION SERVICE: Starting optimization ===");

      // Preprocess data
      List<Product> filteredProducts =
          DataPreprocessor.preprocessData(products);

      if (filteredProducts.isEmpty) {
        print("ERROR: No products available after preprocessing");
        return null;
      }

      // Calculate nutrition targets
      double tdee = _calculateTDEE(age, gender, weight, height, activityLevel);
      Map<String, double> macroTargets = _getMacroTargets(tdee, goal);

      double targetCalories = tdee * days;
      double targetProtein = macroTargets['protein']! * days;
      double targetFat = macroTargets['fat']! * days;
      double targetCarbs = macroTargets['carbs']! * days;

      print("=== OPTIMIZATION PARAMETERS ===");
      print("Budget: ${budget.toStringAsFixed(2)} TL");
      print("Required calories: ${targetCalories.toStringAsFixed(0)} kcal");
      print("Required protein: ${targetProtein.toStringAsFixed(0)} g");
      print("Required fat: ${targetFat.toStringAsFixed(0)} g");
      print("Required carbs: ${targetCarbs.toStringAsFixed(0)} g");
      print("Available products: ${filteredProducts.length}");

      // Category analysis
      print("=== CATEGORY ANALYSIS ===");
      Map<String, List<Product>> categoryProducts = {};
      for (String category in [
        'vegetables',
        'fruits',
        'dairy',
        'legumes',
        'meat_fish',
        'grains'
      ]) {
        categoryProducts[category] =
            filteredProducts.where((p) => p.mainGroup == category).toList();
        print("$category: ${categoryProducts[category]!.length} products");
      }

      // Run comprehensive optimization
      print("=== RUNNING COMPREHENSIVE OPTIMIZATION ===");
      Map<String, dynamic> result = _runComprehensiveOptimization(
        filteredProducts,
        categoryProducts,
        targetCalories,
        targetProtein,
        targetFat,
        targetCarbs,
        budget,
        days,
      );

      if (result['items'].isEmpty) {
        print("ERROR: No items selected in optimization");
        return null;
      }

      // Create shopping items
      List<ShoppingItem> shoppingItems =
          (result['items'] as List<Map<String, dynamic>>)
              .map((item) => ShoppingItem(
                    id: item['id'] ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: item['name'],
                    productName: item['name'],
                    market: item['market'],
                    quantity: item['quantity'],
                    pricePerUnit: item['price_per_unit'],
                    totalPrice: item['total_price'],
                    price: item['price_per_unit'],
                    weightPerUnit: item['weight_per_unit'],
                    totalWeight: item['total_weight'],
                    calories: item['calories'],
                    protein: item['protein'],
                    carbs: item['carbs'],
                    fat: item['fat'],
                    category: item['category'],
                    mainGroup: item['category'],
                    unit: 'adet',
                    imageUrl: item['image_url'] ?? '',
                    isChecked: false,
                  ))
              .toList();

      // Create shopping result
      ShoppingResult shoppingResult = ShoppingResult(
        totalCost: result['total_cost'],
        totalWeight: result['total_weight'],
        totalItems: result['total_items'],
        budgetUsage: (result['total_cost'] / budget) * 100,
        calories: result['achieved_calories'],
        protein: result['achieved_protein'],
        fat: result['achieved_fat'],
        carbs: result['achieved_carbs'],
      );

      // Create optimization result
      OptimizationResult optimizationResult = OptimizationResult(
        shoppingItems: shoppingItems,
        shoppingResult: shoppingResult,
      );

      print("SUCCESS: Comprehensive optimization completed successfully!");
      print("Selected ${shoppingItems.length} different products");
      print("Total cost: ${result['total_cost'].toStringAsFixed(2)} TL");
      print(
          "Budget usage: ${((result['total_cost'] / budget) * 100).toStringAsFixed(1)}%");
      print("Nutrition achieved:");
      print(
          "  Calories: ${result['achieved_calories'].toStringAsFixed(0)} / ${targetCalories.toStringAsFixed(0)} kcal (${((result['achieved_calories'] / targetCalories) * 100).toStringAsFixed(1)}%)");
      print(
          "  Protein: ${result['achieved_protein'].toStringAsFixed(0)} / ${targetProtein.toStringAsFixed(0)} g (${((result['achieved_protein'] / targetProtein) * 100).toStringAsFixed(1)}%)");
      print(
          "  Fat: ${result['achieved_fat'].toStringAsFixed(0)} / ${targetFat.toStringAsFixed(0)} g (${((result['achieved_fat'] / targetFat) * 100).toStringAsFixed(1)}%)");
      print(
          "  Carbs: ${result['achieved_carbs'].toStringAsFixed(0)} / ${targetCarbs.toStringAsFixed(0)} g (${((result['achieved_carbs'] / targetCarbs) * 100).toStringAsFixed(1)}%)");

      return optimizationResult;
    } catch (e) {
      print("ERROR: Error in optimization: $e");
      return null;
    }
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  static double _calculateTDEE(int age, String gender, double weight,
      double height, String activityLevel) {
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

    double tdee = bmr * (activityFactors[activityLevel.toLowerCase()] ?? 1.2);
    return tdee;
  }

  /// Get macro targets based on goal
  static Map<String, double> _getMacroTargets(double tdee, String goal) {
    // Adjust TDEE based on goal
    if (goal.toLowerCase().contains("gain")) {
      tdee += 200;
    } else if (goal.toLowerCase().contains("lose")) {
      tdee -= 200;
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
        (tdee * proteinRatio) / 4; // 4 calories per gram of protein
    double fatG = (tdee * fatRatio) / 9; // 9 calories per gram of fat
    double carbG = (tdee * carbRatio) / 4; // 4 calories per gram of carbs

    return {
      'protein': proteinG,
      'fat': fatG,
      'carbs': carbG,
    };
  }

  /// Run comprehensive optimization with all constraints
  static Map<String, dynamic> _runComprehensiveOptimization(
    List<Product> products,
    Map<String, List<Product>> categoryProducts,
    double targetCalories,
    double targetProtein,
    double targetFat,
    double targetCarbs,
    double budget,
    int days,
  ) {
    // Create a copy of products to avoid modification issues
    List<Product> availableProducts = List.from(products);
    Map<String, List<Product>> availableCategoryProducts = {};
    for (String category in categoryProducts.keys) {
      availableCategoryProducts[category] =
          List.from(categoryProducts[category] ?? []);
    }

    Map<int, int> selectedQuantities = {};
    double totalCost = 0.0;
    double totalWeight = 0.0;
    double achievedCalories = 0.0;
    double achievedProtein = 0.0;
    double achievedFat = 0.0;
    double achievedCarbs = 0.0;
    double totalPastaWeight = 0.0; // Track pasta weight
    double totalMeatWeight = 0.0; // Track meat weight

    // Phase 1: Ensure category diversity (at least 1 item from each category)
    print("Phase 1: Ensuring category diversity...");
    List<String> categories = [
      'vegetables',
      'fruits',
      'dairy',
      'legumes',
      'meat_fish',
      'grains'
    ];

    for (String category in categories) {
      List<Product> categoryItems = availableCategoryProducts[category] ?? [];
      if (categoryItems.isNotEmpty) {
        Product? bestProduct = _findBestProductForCategory(
            categoryItems, budget - totalCost, category);
        if (bestProduct != null) {
          selectedQuantities[bestProduct.id] = 1;
          totalCost += bestProduct.price;
          totalWeight += bestProduct.weightG ?? 1000;
          achievedCalories += bestProduct.caloriesPer100g ?? 0;
          achievedProtein += bestProduct.proteinPer100g ?? 0;
          achievedFat += bestProduct.fatPer100g ?? 0;
          achievedCarbs += bestProduct.carbsPer100g ?? 0;

          // Track pasta weight
          if (_isPastaProduct(bestProduct)) {
            totalPastaWeight +=
                (bestProduct.weightG ?? 1000) / 1000; // Convert to kg
          }

          // Track meat weight
          if (_isMeatProduct(bestProduct)) {
            totalMeatWeight +=
                (bestProduct.weightG ?? 1000) / 1000; // Convert to kg
          }

          print("  Added ${bestProduct.name} from $category");
        }
      }
    }

    // Phase 2: Fill nutritional gaps until at least 70% of budget is used
    print("Phase 2: Filling nutritional gaps...");
    int maxIterations = 2000;
    int iterations = 0;
    double minBudgetUsage = budget * 0.7; // At least 70% of budget
    double minMeatWeight = 5.0; // At least 5kg meat

    while (iterations < maxIterations && availableProducts.isNotEmpty) {
      // Calculate remaining nutritional needs
      double remainingCalories = max(0, targetCalories - achievedCalories);
      double remainingProtein = max(0, targetProtein - achievedProtein);
      double remainingFat = max(0, targetFat - achievedFat);
      double remainingCarbs = max(0, targetCarbs - achievedCarbs);
      double remainingBudget = budget - totalCost;

      // Check if we've met all targets and budget requirement
      bool budgetRequirementMet = totalCost >= minBudgetUsage;
      bool nutritionTargetsMet = remainingCalories <= 0 &&
          remainingProtein <= 0 &&
          remainingFat <= 0 &&
          remainingCarbs <= 0;
      bool meatRequirementMet = totalMeatWeight >= minMeatWeight;

      if (remainingBudget <= 0 ||
          (budgetRequirementMet && nutritionTargetsMet && meatRequirementMet)) {
        break;
      }

      // Find the best product to add based on nutritional needs
      Product? bestProduct = _findBestProductForNutrition(
        availableProducts,
        remainingBudget,
        remainingCalories,
        remainingProtein,
        remainingFat,
        remainingCarbs,
        selectedQuantities,
        totalPastaWeight, // Pass pasta weight constraint
        totalMeatWeight, // Pass meat weight for tracking
        minMeatWeight, // Pass minimum meat requirement
      );

      if (bestProduct == null) break;

      // Check pasta weight constraint
      if (_isPastaProduct(bestProduct)) {
        double productWeightKg = (bestProduct.weightG ?? 1000) / 1000;
        if (totalPastaWeight + productWeightKg > 2.5) {
          // Remove this product from consideration
          availableProducts.removeWhere((p) => p.id == bestProduct.id);
          continue;
        }
      }

      // Add the product
      int currentQty = selectedQuantities[bestProduct.id] ?? 0;
      int maxQty =
          min(5, _getMaxQuantityForProduct(bestProduct)); // Max 5 per item

      if (currentQty >= maxQty) {
        // Remove this product from consideration
        availableProducts.removeWhere((p) => p.id == bestProduct.id);
        continue;
      }

      selectedQuantities[bestProduct.id] = currentQty + 1;
      totalCost += bestProduct.price;
      totalWeight += bestProduct.weightG ?? 1000;
      achievedCalories += bestProduct.caloriesPer100g ?? 0;
      achievedProtein += bestProduct.proteinPer100g ?? 0;
      achievedFat += bestProduct.fatPer100g ?? 0;
      achievedCarbs += bestProduct.carbsPer100g ?? 0;

      // Track pasta weight
      if (_isPastaProduct(bestProduct)) {
        totalPastaWeight += (bestProduct.weightG ?? 1000) / 1000;
      }

      // Track meat weight
      if (_isMeatProduct(bestProduct)) {
        totalMeatWeight += (bestProduct.weightG ?? 1000) / 1000;
      }

      iterations++;

      if (iterations % 100 == 0) {
        print(
            "  Iteration $iterations: Cost ${totalCost.toStringAsFixed(2)} TL (${(totalCost / budget * 100).toStringAsFixed(1)}%), Calories ${achievedCalories.toStringAsFixed(0)} kcal, Meat: ${totalMeatWeight.toStringAsFixed(1)}kg");
      }
    }

    // Phase 3: Optimize quantities for better nutrition balance
    print("Phase 3: Optimizing quantities for better balance...");
    _optimizeQuantities(
      selectedQuantities,
      products, // Use original products list for lookup
      targetCalories,
      targetProtein,
      targetFat,
      targetCarbs,
      budget,
      minBudgetUsage,
      minMeatWeight,
    );

    // Recalculate totals after optimization
    totalCost = 0.0;
    totalWeight = 0.0;
    achievedCalories = 0.0;
    achievedProtein = 0.0;
    achievedFat = 0.0;
    achievedCarbs = 0.0;
    totalPastaWeight = 0.0;
    totalMeatWeight = 0.0;

    for (MapEntry<int, int> entry in selectedQuantities.entries) {
      Product? product = _findProductById(products, entry.key);
      if (product != null) {
        int qty = entry.value;
        totalCost += product.price * qty;
        totalWeight += (product.weightG ?? 1000) * qty;
        achievedCalories += (product.caloriesPer100g ?? 0) * qty;
        achievedProtein += (product.proteinPer100g ?? 0) * qty;
        achievedFat += (product.fatPer100g ?? 0) * qty;
        achievedCarbs += (product.carbsPer100g ?? 0) * qty;

        if (_isPastaProduct(product)) {
          totalPastaWeight += ((product.weightG ?? 1000) / 1000) * qty;
        }

        if (_isMeatProduct(product)) {
          totalMeatWeight += ((product.weightG ?? 1000) / 1000) * qty;
        }
      }
    }

    // Create result items (consolidated with quantities)
    List<Map<String, dynamic>> items = [];
    for (MapEntry<int, int> entry in selectedQuantities.entries) {
      Product? product = _findProductById(products, entry.key);
      if (product != null && entry.value > 0) {
        items.add({
          'id': product.id.toString(),
          'name': product.name,
          'market': product.market,
          'quantity': entry.value, // Integer quantity
          'price_per_unit': product.price,
          'total_price': product.price * entry.value,
          'weight_per_unit': product.weightG ?? 1000,
          'total_weight': (product.weightG ?? 1000) * entry.value,
          'calories': product.caloriesPer100g ?? 0,
          'protein': product.proteinPer100g ?? 0,
          'carbs': product.carbsPer100g ?? 0,
          'fat': product.fatPer100g ?? 0,
          'category': product.mainGroup ?? 'other',
          'image_url': product.imageUrl,
        });
      }
    }

    return {
      'items': items,
      'total_cost': totalCost,
      'total_weight': totalWeight,
      'total_items': selectedQuantities.values.fold(0, (sum, qty) => sum + qty),
      'unique_items': selectedQuantities.length,
      'achieved_calories': achievedCalories,
      'achieved_protein': achievedProtein,
      'achieved_fat': achievedFat,
      'achieved_carbs': achievedCarbs,
      'total_pasta_weight': totalPastaWeight,
      'total_meat_weight': totalMeatWeight,
      'budget_usage_percent': (totalCost / budget) * 100,
    };
  }

  /// Find best product for a specific category
  static Product? _findBestProductForCategory(
      List<Product> products, double remainingBudget, String category) {
    Product? bestProduct;
    double bestValue = 0.0;

    for (Product product in products) {
      if (product.price <= remainingBudget) {
        // Calculate value based on nutrition density and price
        double nutritionValue = (product.caloriesPer100g ?? 0) +
            (product.proteinPer100g ?? 0) * 4 +
            (product.carbsPer100g ?? 0) * 2 +
            (product.fatPer100g ?? 0) * 2;
        double value = nutritionValue / product.price;

        if (value > bestValue) {
          bestValue = value;
          bestProduct = product;
        }
      }
    }

    return bestProduct;
  }

  /// Find the best product for nutrition optimization
  static Product? _findBestProductForNutrition(
    List<Product> products,
    double remainingBudget,
    double remainingCalories,
    double remainingProtein,
    double remainingFat,
    double remainingCarbs,
    Map<int, int> selectedQuantities,
    double totalPastaWeight,
    double totalMeatWeight,
    double minMeatWeight,
  ) {
    Product? bestProduct;
    double bestScore = 0.0;

    for (Product product in products) {
      if (product.price > remainingBudget) continue;

      // Calculate nutritional contribution
      double caloriesContribution = product.caloriesPer100g ?? 0;
      double proteinContribution = product.proteinPer100g ?? 0;
      double fatContribution = product.fatPer100g ?? 0;
      double carbsContribution = product.carbsPer100g ?? 0;

      // Calculate how well this product fills the gaps
      double caloriesScore =
          remainingCalories > 0 ? caloriesContribution / remainingCalories : 0;
      double proteinScore =
          remainingProtein > 0 ? proteinContribution / remainingProtein : 0;
      double fatScore = remainingFat > 0 ? fatContribution / remainingFat : 0;
      double carbsScore =
          remainingCarbs > 0 ? carbsContribution / remainingCarbs : 0;

      double nutritionScore =
          caloriesScore + proteinScore + fatScore + carbsScore;

      // Price efficiency (lower price is better)
      double priceEfficiency = nutritionScore / product.price;

      // Variety bonus (prefer products we haven't selected much)
      int currentQty = selectedQuantities[product.id] ?? 0;
      double varietyBonus = 1.0 / (1.0 + currentQty * 0.5);

      // Bonus for pasta weight constraint
      double pastaBonus = 1.0;
      if (_isPastaProduct(product)) {
        double productWeightKg = (product.weightG ?? 1000) / 1000;
        if (totalPastaWeight + productWeightKg > 2.5) {
          pastaBonus = 0.0; // Exclude if it would exceed pasta limit
        }
      }

      // Bonus for meat weight constraint
      double meatBonus = 1.0;
      if (_isMeatProduct(product)) {
        double productWeightKg = (product.weightG ?? 1000) / 1000;
        if (totalMeatWeight + productWeightKg > minMeatWeight * 1.5) {
          // Slight penalty if we already have enough meat
          meatBonus = 0.8;
        }
      } else if (totalMeatWeight < minMeatWeight) {
        // Penalize non-meat products if we still need meat
        meatBonus = 0.5;
      }

      double totalScore =
          priceEfficiency * varietyBonus * pastaBonus * meatBonus;

      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestProduct = product;
      }
    }

    return bestProduct;
  }

  /// Get maximum quantity for a product based on category and constraints
  static int _getMaxQuantityForProduct(Product product) {
    String category = product.mainGroup ?? 'other';

    switch (category) {
      case 'vegetables':
        return 10; // More vegetables allowed
      case 'fruits':
        return 8; // Good amount of fruits
      case 'dairy':
        return 6; // Moderate dairy
      case 'legumes':
        return 5; // Moderate legumes
      case 'meat_fish':
        return 4; // Limited meat/fish
      case 'grains':
        return 6; // Moderate grains
      default:
        return 3; // Default limit
    }
  }

  /// Optimize quantities for better nutrition balance
  static void _optimizeQuantities(
    Map<int, int> selectedQuantities,
    List<Product> products,
    double targetCalories,
    double targetProtein,
    double targetFat,
    double targetCarbs,
    double budget,
    double minBudgetUsage,
    double minMeatWeight,
  ) {
    // Try to adjust quantities to better meet nutritional targets and budget requirement
    for (int i = 0; i < 3; i++) {
      // Limited iterations to prevent infinite loops
      bool improved = false;

      for (MapEntry<int, int> entry in selectedQuantities.entries) {
        Product? product = _findProductById(products, entry.key);
        if (product == null) continue;

        int currentQty = entry.value;

        // Try increasing quantity (max 5 per item)
        int maxQty = min(5, _getMaxQuantityForProduct(product));
        if (currentQty < maxQty) {
          double additionalCost = product.price;
          double additionalCalories = product.caloriesPer100g ?? 0;
          double additionalProtein = product.proteinPer100g ?? 0;
          double additionalFat = product.fatPer100g ?? 0;
          double additionalCarbs = product.carbsPer100g ?? 0;

          // Check if adding one more would improve nutrition balance
          double currentTotalCost = 0.0;
          double currentPastaWeight = 0.0;
          double currentMeatWeight = 0.0;

          for (MapEntry<int, int> qtyEntry in selectedQuantities.entries) {
            Product? qtyProduct = _findProductById(products, qtyEntry.key);
            if (qtyProduct != null) {
              currentTotalCost += qtyProduct.price * qtyEntry.value;

              if (_isPastaProduct(qtyProduct)) {
                currentPastaWeight +=
                    ((qtyProduct.weightG ?? 1000) / 1000) * qtyEntry.value;
              }

              if (_isMeatProduct(qtyProduct)) {
                currentMeatWeight +=
                    ((qtyProduct.weightG ?? 1000) / 1000) * qtyEntry.value;
              }
            }
          }

          // Check budget constraint and pasta weight constraint
          bool budgetOk = currentTotalCost + additionalCost <= budget;
          bool pastaOk = true;
          bool meatOk = true;

          if (_isPastaProduct(product)) {
            double productWeightKg = (product.weightG ?? 1000) / 1000;
            pastaOk = currentPastaWeight + productWeightKg <= 2.5;
          }

          if (_isMeatProduct(product)) {
            double productWeightKg = (product.weightG ?? 1000) / 1000;
            meatOk = currentMeatWeight + productWeightKg <=
                minMeatWeight * 2.0; // Allow some flexibility
          }

          if (budgetOk && pastaOk && meatOk) {
            selectedQuantities[product.id] = currentQty + 1;
            improved = true;
            break;
          }
        }
      }

      if (!improved) break;
    }
  }

  /// Safely find a product by ID
  static Product? _findProductById(List<Product> products, int id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if a product is a pasta product
  static bool _isPastaProduct(Product product) {
    String category = product.mainGroup ?? 'other';
    return category.toLowerCase() == 'grains' &&
        product.name.toLowerCase().contains('makarna');
  }

  /// Check if a product is a meat product
  static bool _isMeatProduct(Product product) {
    String category = product.mainGroup ?? 'other';
    return category.toLowerCase() == 'meat_fish';
  }
}
