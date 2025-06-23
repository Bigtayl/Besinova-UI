import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/models/product.dart';
import '../../data/models/optimization_result.dart';
import '../../data/models/shopping_item.dart';
import '../../data/services/optimization_service.dart';

/// Provider for managing optimization state and results
class OptimizationProvider extends ChangeNotifier {
  OptimizationResult? _optimizationResult;
  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  OptimizationResult? get optimizationResult => _optimizationResult;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get filtered shopping items by category
  List<ShoppingItem> getShoppingItemsByCategory(String category) {
    if (category == 'Tümü') {
      return _shoppingItems;
    }
    return _shoppingItems.where((item) => item.category == category).toList();
  }

  /// Get total cost of shopping items
  double get totalCost {
    return _shoppingItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Get total calories of shopping items
  double get totalCalories {
    return _shoppingItems.fold(0.0, (sum, item) => sum + (item.calories * item.quantity));
  }

  /// Get total protein of shopping items
  double get totalProtein {
    return _shoppingItems.fold(0.0, (sum, item) => sum + (item.protein * item.quantity));
  }

  /// Get total carbs of shopping items
  double get totalCarbs {
    return _shoppingItems.fold(0.0, (sum, item) => sum + (item.carbs * item.quantity));
  }

  /// Get total fat of shopping items
  double get totalFat {
    return _shoppingItems.fold(0.0, (sum, item) => sum + (item.fat * item.quantity));
  }

  /// Run optimization for the given user and products
  Future<void> runOptimization({
    required User user,
    required List<Product> products,
    int days = 30,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await OptimizationService.optimizeShopping(
        user: user,
        products: products,
        days: days,
      );

      _optimizationResult = result;
      _shoppingItems = List.from(result?.shoppingItems ?? []);
      
      notifyListeners();
    } catch (e) {
      _setError('Optimization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle item checked status
  void toggleItemChecked(String itemId) {
    final index = _shoppingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _shoppingItems[index] = _shoppingItems[index].copyWith(
        isChecked: !_shoppingItems[index].isChecked,
      );
      notifyListeners();
    }
  }

  /// Update item quantity
  void updateItemQuantity(String itemId, int quantity) {
    final index = _shoppingItems.indexWhere((item) => item.id == itemId);
    if (index != -1 && quantity > 0) {
      _shoppingItems[index] = _shoppingItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  /// Remove item from shopping list
  void removeItem(String itemId) {
    _shoppingItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Clear all items from shopping list
  void clearShoppingList() {
    _shoppingItems.clear();
    notifyListeners();
  }

  /// Get checked items
  List<ShoppingItem> get checkedItems {
    return _shoppingItems.where((item) => item.isChecked).toList();
  }

  /// Get unchecked items
  List<ShoppingItem> get uncheckedItems {
    return _shoppingItems.where((item) => !item.isChecked).toList();
  }

  /// Check all items
  void checkAllItems() {
    _shoppingItems = _shoppingItems.map((item) => item.copyWith(isChecked: true)).toList();
    notifyListeners();
  }

  /// Uncheck all items
  void uncheckAllItems() {
    _shoppingItems = _shoppingItems.map((item) => item.copyWith(isChecked: false)).toList();
    notifyListeners();
  }

  /// Get items by main group
  List<ShoppingItem> getItemsByMainGroup(String mainGroup) {
    return _shoppingItems.where((item) => item.mainGroup == mainGroup).toList();
  }

  /// Get main groups with item counts
  Map<String, int> get mainGroupCounts {
    final counts = <String, int>{};
    for (final item in _shoppingItems) {
      counts[item.mainGroup] = (counts[item.mainGroup] ?? 0) + 1;
    }
    return counts;
  }

  /// Get categories with item counts
  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final item in _shoppingItems) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Search items by name
  List<ShoppingItem> searchItems(String query) {
    if (query.isEmpty) return _shoppingItems;
    
    return _shoppingItems.where((item) => 
      item.productName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Filter items by price range
  List<ShoppingItem> filterByPriceRange(double minPrice, double maxPrice) {
    return _shoppingItems.where((item) => 
      item.price >= minPrice && item.price <= maxPrice
    ).toList();
  }

  /// Filter items by calorie range
  List<ShoppingItem> filterByCalorieRange(double minCalories, double maxCalories) {
    return _shoppingItems.where((item) => 
      item.calories >= minCalories && item.calories <= maxCalories
    ).toList();
  }

  /// Get budget utilization percentage
  double getBudgetUtilization(double budget) {
    if (budget <= 0) return 0.0;
    return (totalCost / budget) * 100;
  }

  /// Check if budget is exceeded
  bool isBudgetExceeded(double budget) {
    return totalCost > budget;
  }

  /// Get budget remaining
  double getBudgetRemaining(double budget) {
    return budget - totalCost;
  }

  /// Reset optimization state
  void reset() {
    _optimizationResult = null;
    _shoppingItems.clear();
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 