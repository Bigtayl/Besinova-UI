import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../models/shopping_result.dart';
import '../models/optimization_result.dart';

/// Service for handling shopping optimization via Render server API
class OptimizationService {
  static const String _baseUrl = 'https://shopping-optimizer-api.onrender.com';
  static bool _isInitialized = false;

  /// Initialize the optimization service
  static Future<bool> initialize() async {
    try {
      // Test the server connection
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isInitialized = data['data_loaded'] == true;
        return _isInitialized;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Optimize shopping list based on user profile
  static Future<OptimizationResult?> optimizeShopping({
    required User user,
    List<Product>? products,
    int days = 30,
  }) async {
    try {
      // Force gender mapping with explicit logging
      String mappedGender;
      if (user.gender.toLowerCase().contains('erkek')) {
        mappedGender = 'male';
      } else if (user.gender.toLowerCase().contains('kadın')) {
        mappedGender = 'female';
      } else {
        mappedGender = 'male';
      }

      final params = {
        'age': user.age,
        'gender': mappedGender,
        'weight': user.weight,
        'height': user.height,
        'activity': _mapActivityLevel(user.activityLevel),
        'goal': _mapGoal(user.goal),
        'budget': user.budget,
        'days': days,
      };

      final result = await _callOptimizationAPI(params);
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Optimize shopping list with custom parameters
  static Future<OptimizationResult?> optimizeShoppingWithParams({
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
      final params = {
        'age': age,
        'gender': _mapGender(gender),
        'weight': weight,
        'height': height,
        'activity': _mapActivityLevel(activityLevel),
        'goal': _mapGoal(goal),
        'budget': budget,
        'days': days,
      };

      final result = await _callOptimizationAPI(params);
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Call the Render API for optimization
  static Future<OptimizationResult?> _callOptimizationAPI(
      Map<String, dynamic> params) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/optimize'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(params),
          )
          .timeout(const Duration(seconds: 35)); // 35 second timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOptimizationResult(data);
      } else {
        final errorData = json.decode(response.body);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Parse the API response into OptimizationResult
  static OptimizationResult? _parseOptimizationResult(
      Map<String, dynamic> data) {
    try {
      final optimizationData = data['optimization_results'];
      final items = optimizationData['items'] as List;

      // Create shopping items from API response
      final List<ShoppingItem> shoppingItems = [];
      final List<Product> optimizedProducts = [];

      for (var item in items) {
        final shoppingItem = ShoppingItem(
          id: '${item['name']}_${item['market']}_${item['quantity']}', // Generate unique ID
          name: item['name'] ?? '',
          productName: item['name'] ?? '',
          market: item['market'] ?? '',
          quantity: item['quantity'] ?? 1,
          pricePerUnit: (item['price_per_unit'] is num)
              ? (item['price_per_unit'] as num).toDouble()
              : 0.0,
          totalPrice: (item['total_price'] is num)
              ? (item['total_price'] as num).toDouble()
              : 0.0,
          price: (item['price_per_unit'] is num)
              ? (item['price_per_unit'] as num).toDouble()
              : 0.0,
          weightPerUnit: (item['weight_per_unit'] is num)
              ? (item['weight_per_unit'] as num).toInt()
              : 1000,
          totalWeight: (item['total_weight'] is num)
              ? (item['total_weight'] as num).toInt()
              : 1000,
          calories: (item['calories'] is num)
              ? (item['calories'] as num).toDouble()
              : 0.0,
          protein: (item['protein'] is num)
              ? (item['protein'] as num).toDouble()
              : 0.0,
          carbs:
              (item['carbs'] is num) ? (item['carbs'] as num).toDouble() : 0.0,
          fat: (item['fat'] is num) ? (item['fat'] as num).toDouble() : 0.0,
          category: item['category'] ?? '',
          mainGroup: item['category'] ?? '',
          unit: 'piece',
          imageUrl: item['image_url'] ?? '', // Add image URL from server
        );

        final product = Product(
          id: item['id'] ?? 0,
          name: item['name'] ?? '',
          market: item['market'] ?? '',
          price: (item['price_per_unit'] is num)
              ? (item['price_per_unit'] as num).toDouble()
              : 0.0,
          imageUrl: item['image_url'] ?? '', // Add image URL from server
          category: item['category'] ?? '',
          caloriesPer100g: (item['calories'] is num)
              ? (item['calories'] as num).toDouble()
              : null,
          proteinPer100g: (item['protein'] is num)
              ? (item['protein'] as num).toDouble()
              : null,
          carbsPer100g:
              (item['carbs'] is num) ? (item['carbs'] as num).toDouble() : null,
          fatPer100g:
              (item['fat'] is num) ? (item['fat'] as num).toDouble() : null,
          createdAt: DateTime.now(),
        );

        shoppingItems.add(shoppingItem);
        optimizedProducts.add(product);
      }

      // Calculate nutrition totals
      final totalCalories = shoppingItems.fold(
          0.0, (sum, item) => sum + (item.calories * item.quantity));
      final totalProtein = shoppingItems.fold(
          0.0, (sum, item) => sum + (item.protein * item.quantity));
      final totalFat = shoppingItems.fold(
          0.0, (sum, item) => sum + (item.fat * item.quantity));
      final totalCarbs = shoppingItems.fold(
          0.0, (sum, item) => sum + (item.carbs * item.quantity));

      // Create shopping result
      final shoppingResult = ShoppingResult(
        totalCost: optimizationData['total_cost'].toDouble(),
        totalWeight: optimizationData['total_weight'].toDouble(),
        totalItems: optimizationData['total_items'].toInt(),
        budgetUsage: optimizationData['budget_usage'].toDouble(),
        calories: totalCalories,
        protein: totalProtein,
        fat: totalFat,
        carbs: totalCarbs,
      );

      return OptimizationResult(
        shoppingResult: shoppingResult,
        shoppingItems: shoppingItems,
      );
    } catch (e) {
      return null;
    }
  }

  /// Map activity level to API format
  static String _mapActivityLevel(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedanter':
        return 'sedentary';
      case 'hafif aktif':
        return 'lightly active';
      case 'orta aktif':
        return 'moderately active';
      case 'çok aktif':
        return 'very active';
      case 'ekstra aktif':
        return 'extra active';
      default:
        return 'moderately active';
    }
  }

  /// Map goal to API format
  static String _mapGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'kilo almak':
        return 'gaining weight';
      case 'sporcu için besin önerisi':
        return 'doing sports';
      case 'kilo vermek':
        return 'losing weight';
      case 'sağlıklı olmak':
        return 'being healthy';
      default:
        return 'being healthy';
    }
  }

  /// Map gender to API format
  static String _mapGender(String gender) {
    final lowerGender = gender.toLowerCase().trim();

    // Handle various possible formats
    if (lowerGender.contains('erkek') || lowerGender.contains('male')) {
      return 'male';
    } else if (lowerGender.contains('kadın') ||
        lowerGender.contains('female')) {
      return 'female';
    } else {
      return 'male'; // Default fallback
    }
  }

  /// Get optimization statistics
  static Map<String, dynamic> getOptimizationStats() {
    return {
      'server_connected': _isInitialized,
      'server_url': _baseUrl,
      'last_optimization': null,
    };
  }

  /// Check if optimization service is ready
  static bool isReady() {
    return _isInitialized;
  }

  /// Get available products (not available with server API)
  static List<Product> getProducts() {
    return [];
  }

  /// Clear optimization cache
  static void clearCache() {
    // No cache to clear with server API
  }
}
