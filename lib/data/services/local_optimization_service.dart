import '../models/product.dart';
import '../models/optimization_result.dart';
import '../models/user.dart';
import 'csv_data_loader.dart';
import 'shopping_optimizer.dart';

/// Main service for local optimization that coordinates all components
class LocalOptimizationService {
  static List<Product>? _cachedProducts;

  /// Initialize the service by loading product data
  static Future<bool> initialize() async {
    try {
      // Load products from CSV
      List<Product> products = await CsvDataLoader.loadProductsFromCsv();

      if (products.isEmpty) {
        products = CsvDataLoader.getSampleProducts();
      }

      _cachedProducts = products;
      return true;
    } catch (e) {
      // Fallback to sample data
      _cachedProducts = CsvDataLoader.getSampleProducts();
      return false;
    }
  }

  /// Get cached products
  static List<Product> getProducts() {
    if (_cachedProducts == null) {
      _cachedProducts = CsvDataLoader.getSampleProducts();
    }
    return _cachedProducts!;
  }

  /// Run optimization with user profile
  static Future<OptimizationResult?> runOptimization({
    required User user,
    int days = 30,
  }) async {
    try {
      // Ensure products are loaded
      if (_cachedProducts == null) {
        await initialize();
      }

      // Run optimization
      OptimizationResult? result = ShoppingOptimizer.optimizeShopping(
        products: _cachedProducts!,
        age: user.age,
        gender: user.gender,
        weight: user.weight,
        height: user.height,
        activityLevel: user.activityLevel,
        goal: user.goal,
        budget: user.budget,
        days: days,
      );

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Run optimization with custom parameters
  static Future<OptimizationResult?> runOptimizationWithParams({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String activityLevel,
    required String goal,
    required double budget,
    int days = 30,
  }) async {
    try {
      // Ensure products are loaded
      if (_cachedProducts == null) {
        await initialize();
      }

      // Run optimization
      OptimizationResult? result = ShoppingOptimizer.optimizeShopping(
        products: _cachedProducts!,
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        activityLevel: activityLevel,
        goal: goal,
        budget: budget,
        days: days,
      );

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Get optimization statistics
  static Map<String, dynamic> getOptimizationStats() {
    if (_cachedProducts == null) {
      return {
        'total_products': 0,
        'categories': {},
        'price_range': {'min': 0, 'max': 0, 'avg': 0},
        'calories_range': {'min': 0, 'max': 0, 'avg': 0},
      };
    }

    List<Product> products = _cachedProducts!;

    // Category distribution
    Map<String, int> categories = {};
    for (Product product in products) {
      String category = product.mainGroup ?? 'other';
      categories[category] = (categories[category] ?? 0) + 1;
    }

    // Price statistics
    double minPrice =
        products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    double maxPrice =
        products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    double avgPrice =
        products.map((p) => p.price).reduce((a, b) => a + b) / products.length;

    // Calories statistics
    List<double> validCalories = products
        .where((p) => p.caloriesPer100g != null)
        .map((p) => p.caloriesPer100g!)
        .toList();

    double minCalories = validCalories.isNotEmpty
        ? validCalories.reduce((a, b) => a < b ? a : b)
        : 0;
    double maxCalories = validCalories.isNotEmpty
        ? validCalories.reduce((a, b) => a > b ? a : b)
        : 0;
    double avgCalories = validCalories.isNotEmpty
        ? validCalories.reduce((a, b) => a + b) / validCalories.length
        : 0;

    return {
      'total_products': products.length,
      'categories': categories,
      'price_range': {
        'min': minPrice,
        'max': maxPrice,
        'avg': avgPrice,
      },
      'calories_range': {
        'min': minCalories,
        'max': maxCalories,
        'avg': avgCalories,
      },
    };
  }

  /// Clear cached data
  static void clearCache() {
    _cachedProducts = null;
  }

  /// Check if service is ready
  static bool isReady() {
    return _cachedProducts != null && _cachedProducts!.isNotEmpty;
  }
}
