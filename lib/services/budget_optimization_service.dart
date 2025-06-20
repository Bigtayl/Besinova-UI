// budget_optimization_service.dart
// Bütçe bazlı besin optimizasyonu servisi. Kullanıcının bütçesine göre besinleri optimize eder.

import '../models/product.dart';

/// Bütçe bazlı besin optimizasyonu servisi
class BudgetOptimizationService {
  /// Kullanıcının bütçesine göre besinleri optimize eder
  ///
  /// [products] - Tüm mevcut ürünler
  /// [budget] - Kullanıcının aylık bütçesi
  /// [preferences] - Kullanıcının besin tercihleri (opsiyonel)
  ///
  /// Returns: Bütçeye uygun optimize edilmiş ürün listesi
  List<Product> optimizeProductsForBudget({
    required List<Product> products,
    required double budget,
    List<String>? preferences,
  }) {
    if (products.isEmpty || budget <= 0) {
      return [];
    }

    // Ürünleri fiyat/kalite oranına göre sırala
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort((a, b) {
      // Basit bir kalite skoru hesapla (fiyat düşük, kalite yüksek = iyi)
      final aScore = _calculateQualityScore(a, preferences);
      final bScore = _calculateQualityScore(b, preferences);
      return bScore.compareTo(aScore); // Yüksek skorlu ürünler önce
    });

    // Bütçeye uygun ürünleri seç
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

  /// Ürünün kalite skorunu hesaplar
  double _calculateQualityScore(Product product, List<String>? preferences) {
    double score = 1.0;

    // Fiyat faktörü (düşük fiyat = yüksek skor)
    if (product.price > 0) {
      score *= (10000 /
          product.price); // 10000 TL'ye göre normalize et (güncellenmiş)
    }

    // Kullanıcı tercihleri varsa bonus puan ver
    if (preferences != null && preferences.isNotEmpty) {
      final productName = product.name.toLowerCase();
      for (final preference in preferences) {
        if (productName.contains(preference.toLowerCase())) {
          score *= 1.5; // Tercih edilen ürünlere %50 bonus
          break;
        }
      }
    }

    // Market faktörü (bazı marketler daha güvenilir olabilir)
    final market = product.market.toLowerCase();
    if (market.contains('migros') || market.contains('carrefour')) {
      score *= 1.2; // Büyük marketlere %20 bonus
    }

    return score;
  }

  /// Bütçe kullanım oranını hesaplar
  double calculateBudgetUsage({
    required List<Product> selectedProducts,
    required double budget,
  }) {
    if (budget <= 0) return 0.0;

    final totalCost = selectedProducts.fold<double>(
        0.0, (sum, product) => sum + product.price);

    return (totalCost / budget) * 100;
  }

  /// Bütçe önerileri oluşturur
  List<String> generateBudgetSuggestions({
    required double budget,
    required List<Product> selectedProducts,
  }) {
    final suggestions = <String>[];
    final totalCost = selectedProducts.fold<double>(
        0.0, (sum, product) => sum + product.price);

    if (totalCost > budget) {
      suggestions
          .add('Bütçenizi aştınız! Daha uygun fiyatlı alternatifler önerilir.');
    } else if (totalCost < budget * 0.5) {
      suggestions.add(
          'Bütçenizin yarısından azını kullandınız. Daha fazla besin çeşitliliği ekleyebilirsiniz.');
    } else if (totalCost < budget * 0.8) {
      suggestions.add('Bütçenizi verimli kullanıyorsunuz!');
    } else {
      suggestions.add('Bütçenizi maksimum verimle kullandınız!');
    }

    return suggestions;
  }

  /// Kategori bazlı bütçe dağılımı önerir
  Map<String, double> suggestBudgetDistribution({
    required double budget,
    required List<Product> products,
  }) {
    // Kategori bazlı bütçe dağılımı
    final distribution = <String, double>{
      'Protein': budget * 0.3, // %30 protein
      'Karbonhidrat': budget * 0.25, // %25 karbonhidrat
      'Yağ': budget * 0.15, // %15 yağ
      'Sebze/Meyve': budget * 0.2, // %20 sebze/meyve
      'Diğer': budget * 0.1, // %10 diğer
    };

    return distribution;
  }
}
