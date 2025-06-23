import '../models/product.dart';

/// Data preprocessing service that matches the Python preprocessing logic
class DataPreprocessor {
  /// Preprocess product data according to the Python algorithm
  static List<Product> preprocessData(List<Product> products) {
    List<Product> filteredProducts = products.where((product) {
      // Remove products with missing or invalid data
      if (product.price <= 0 ||
          product.caloriesPer100g == null ||
          product.caloriesPer100g! < 0 ||
          product.proteinPer100g == null ||
          product.proteinPer100g! < 0 ||
          product.carbsPer100g == null ||
          product.carbsPer100g! < 0 ||
          product.fatPer100g == null ||
          product.fatPer100g! < 0) {
        return false;
      }

      // Exclude beverages
      if (product.category?.toLowerCase().contains('içecek') == true) {
        return false;
      }

      // Exclude noodles
      if (product.name.toLowerCase().contains('noodle') ||
          product.itemCategory?.toLowerCase().contains('noodle') == true) {
        return false;
      }

      // Exclude liver and heart products
      if (product.name.toLowerCase().contains('ciğer') ||
          product.name.toLowerCase().contains('yürek') ||
          product.name.toLowerCase().contains('liver') ||
          product.name.toLowerCase().contains('heart')) {
        return false;
      }

      // Exclude products containing 'çabuk' or 'bardak' (Turkish only)
      if (product.name.toLowerCase().contains('çabuk') ||
          product.name.toLowerCase().contains('bardak')) {
        return false;
      }

      // Exclude Berliner and Kruvasan products
      if (product.name.toLowerCase().contains('berliner') ||
          product.name.toLowerCase().contains('kruvasan') ||
          product.name.toLowerCase().contains('croissant')) {
        return false;
      }

      // Exclude products containing 'pilavı' and 'çikolata'
      if (product.name.toLowerCase().contains('pilavı') ||
          product.name.toLowerCase().contains('çikolata')) {
        return false;
      }

      // Apply weight and price filters
      if ((product.weightG ?? 1000) > 5000) return false; // Max 5kg per item
      if (product.price > 1000) return false; // Max 1000 TL per item
      if ((product.caloriesPer100g ?? 0) <= 0)
        return false; // Must have calories

      return true;
    }).toList();

    // Map categories using the same logic as Python
    for (Product product in filteredProducts) {
      product = product.copyWith(mainGroup: _mapMainGroup(product));
    }

    // Exclude granola items
    filteredProducts = filteredProducts
        .where((product) => product.mainGroup != 'exclude')
        .toList();

    return filteredProducts;
  }

  /// Map product to main group category (same as Python logic)
  static String _mapMainGroup(Product product) {
    String itemCategory = (product.itemCategory ?? '').toLowerCase();
    String name = product.name.toLowerCase();

    // Exclude granola items
    if (itemCategory.contains('granola') || name.contains('granola')) {
      return 'exclude';
    }

    // Vegetables
    if (itemCategory.contains('sebze') ||
        itemCategory.contains('domates') ||
        itemCategory.contains('biber') ||
        itemCategory.contains('salatalık') ||
        itemCategory.contains('patates') ||
        itemCategory.contains('soğan') ||
        itemCategory.contains('havuç') ||
        name.contains('domates') ||
        name.contains('biber') ||
        name.contains('salatalık') ||
        name.contains('patates') ||
        name.contains('soğan') ||
        name.contains('havuç') ||
        name.contains('kabak')) {
      return 'vegetables';
    }

    // Fruits
    if (itemCategory.contains('meyve') ||
        itemCategory.contains('elma') ||
        itemCategory.contains('muz') ||
        itemCategory.contains('portakal') ||
        itemCategory.contains('armut') ||
        itemCategory.contains('çilek') ||
        name.contains('elma') ||
        name.contains('muz') ||
        name.contains('portakal') ||
        name.contains('armut') ||
        name.contains('çilek') ||
        name.contains('kayısı') ||
        name.contains('şeftali')) {
      return 'fruits';
    }

    // Dairy
    if (itemCategory.contains('süt') ||
        itemCategory.contains('kahvalt') ||
        itemCategory.contains('peynir') ||
        itemCategory.contains('yoğurt') ||
        itemCategory.contains('süt ürünleri') ||
        name.contains('peynir') ||
        name.contains('yoğurt') ||
        name.contains('süt') ||
        name.contains('kaymak') ||
        name.contains('krema')) {
      return 'dairy';
    }

    // Legumes
    if (itemCategory.contains('bakliyat') ||
        itemCategory.contains('fasulye') ||
        itemCategory.contains('mercimek') ||
        itemCategory.contains('nohut') ||
        itemCategory.contains('bezelye') ||
        name.contains('fasulye') ||
        name.contains('mercimek') ||
        name.contains('nohut') ||
        name.contains('bezelye') ||
        name.contains('barbunya')) {
      return 'legumes';
    }

    // Meat/Fish
    if (itemCategory.contains('et') ||
        itemCategory.contains('balık') ||
        itemCategory.contains('tavuk') ||
        itemCategory.contains('kıyma') ||
        itemCategory.contains('sucuk') ||
        name.contains('tavuk') ||
        name.contains('balık') ||
        name.contains('kıyma') ||
        name.contains('sucuk') ||
        name.contains('salam') ||
        name.contains('pastırma')) {
      return 'meat_fish';
    }

    // Grains
    if (itemCategory.contains('temel gıda') ||
        itemCategory.contains('ekmek') ||
        itemCategory.contains('bulgur') ||
        itemCategory.contains('pirinç') ||
        itemCategory.contains('makarna') ||
        itemCategory.contains('un') ||
        name.contains('ekmek') ||
        name.contains('bulgur') ||
        name.contains('pirinç') ||
        name.contains('makarna') ||
        name.contains('un') ||
        name.contains('börek')) {
      return 'grains';
    }

    return 'other';
  }

  /// Analyze categories and print statistics
  static void analyzeCategories(List<Product> products) {
    Map<String, int> categoryCounts = {};

    for (Product product in products) {
      String category = product.mainGroup ?? 'other';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Return the category counts instead of printing
    categoryCounts;
  }

  /// Check nutrition feasibility
  static Map<String, bool> checkNutritionFeasibility(
      List<Product> products, Map<String, double> targets) {
    double totalCaloriesAvailable =
        products.map((p) => p.caloriesPer100g ?? 0).reduce((a, b) => a + b) * 5;
    double totalProteinAvailable =
        products.map((p) => p.proteinPer100g ?? 0).reduce((a, b) => a + b) * 5;
    double totalFatAvailable =
        products.map((p) => p.fatPer100g ?? 0).reduce((a, b) => a + b) * 5;
    double totalCarbsAvailable =
        products.map((p) => p.carbsPer100g ?? 0).reduce((a, b) => a + b) * 5;

    return {
      'calories': totalCaloriesAvailable >= targets['calories']!,
      'protein': totalProteinAvailable >= targets['protein_g']!,
      'fat': totalFatAvailable >= targets['fat_g']!,
      'carbs': totalCarbsAvailable >= targets['carb_g']!,
    };
  }

  /// Check budget feasibility
  static Map<String, double> checkBudgetFeasibility(
      List<Product> products, double budget) {
    double minCost =
        products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    double maxCost =
        products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    double avgCost =
        products.map((p) => p.price).reduce((a, b) => a + b) / products.length;

    return {
      'minCost': minCost,
      'maxCost': maxCost,
      'avgCost': avgCost,
      'budget': budget,
      'minBudgetNeeded': budget * 0.70,
    };
  }
}
