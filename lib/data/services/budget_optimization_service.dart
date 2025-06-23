import '../../core/constants/app_constants.dart';
import '../models/product.dart';

/// Service for budget-based product optimization
class BudgetOptimizationService {
  /// Optimize products for a given budget
  ///
  /// [products] - All available products
  /// [budget] - User's monthly budget
  /// [preferences] - User's food preferences (optional)
  ///
  /// Returns: Budget-optimized product list
  List<Product> optimizeProductsForBudget({
    required List<Product> products,
    required double budget,
    List<String>? preferences,
  }) {
    if (products.isEmpty || budget <= 0) {
      return [];
    }

    // Sort products by price/quality ratio
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort((a, b) {
      final aScore = _calculateQualityScore(a, preferences);
      final bScore = _calculateQualityScore(b, preferences);
      return bScore.compareTo(aScore); // Higher scores first
    });

    // Select products that fit the budget
    final optimizedProducts = <Product>[];
    double remainingBudget = budget;

    for (final product in sortedProducts) {
      if (product.price <= remainingBudget) {
        optimizedProducts.add(product);
        remainingBudget -= product.price;
      }
    }

    return optimizedProducts;
  }

  /// Calculate quality score for a product
  double _calculateQualityScore(Product product, List<String>? preferences) {
    double score = 1.0;

    // Price factor (lower price = higher score)
    if (product.price > 0) {
      score *= (AppConstants.priceNormalizationFactor / product.price);
    }

    // User preferences bonus
    if (preferences != null && preferences.isNotEmpty) {
      final productName = product.name.toLowerCase();
      for (final preference in preferences) {
        if (productName.contains(preference.toLowerCase())) {
          score *= AppConstants.preferenceBonusMultiplier;
          break;
        }
      }
    }

    // Market factor (some markets may be more reliable)
    final market = product.market.toLowerCase();
    if (market.contains('migros') || market.contains('carrefour')) {
      score *= AppConstants.marketBonusMultiplier;
    }

    return score;
  }

  /// Calculate budget usage percentage
  double calculateBudgetUsage({
    required List<Product> selectedProducts,
    required double budget,
  }) {
    if (budget <= 0) return 0.0;

    final totalCost = selectedProducts.fold<double>(
      0.0,
      (sum, product) => sum + product.price,
    );

    return (totalCost / budget) * 100;
  }

  /// Generate budget suggestions
  List<String> generateBudgetSuggestions({
    required double budget,
    required List<Product> selectedProducts,
  }) {
    final suggestions = <String>[];
    final totalCost = selectedProducts.fold<double>(
      0.0,
      (sum, product) => sum + product.price,
    );

    if (totalCost > budget) {
      suggestions.add(
        'Bütçenizi aştınız! Daha uygun fiyatlı alternatifler önerilir.',
      );
    } else if (totalCost < budget * 0.5) {
      suggestions.add(
        'Bütçenizin yarısından azını kullandınız. Daha fazla besin çeşitliliği ekleyebilirsiniz.',
      );
    } else if (totalCost < budget * 0.8) {
      suggestions.add('Bütçenizi verimli kullanıyorsunuz!');
    } else {
      suggestions.add('Bütçenizi maksimum verimle kullandınız!');
    }

    return suggestions;
  }

  /// Suggest budget distribution by category
  Map<String, double> suggestBudgetDistribution({
    required double budget,
    required List<Product> products,
  }) {
    return {
      'Protein': budget * AppConstants.proteinBudgetPercentage,
      'Karbonhidrat': budget * AppConstants.carbsBudgetPercentage,
      'Yağ': budget * AppConstants.fatBudgetPercentage,
      'Sebze/Meyve': budget * AppConstants.vegetablesFruitsBudgetPercentage,
      'Diğer': budget * AppConstants.otherBudgetPercentage,
    };
  }
}
